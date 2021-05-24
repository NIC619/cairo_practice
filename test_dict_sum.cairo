%builtins output range_check

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.squash_dict import squash_dict

struct KeyValue:
    member key : felt
    member value : felt
end

# Builds a DictAccess list for the computation of the cumulative
# sum for each key.
func build_dict(list : KeyValue*, size, dict : DictAccess*) -> (
        dict : DictAccess*):
    if size == 0:
        return (dict=dict)
    end

    %{
        # Get list key and list value
        LIST_KEY_OFFSET = ids.KeyValue.key
        LIST_VALUE_OFFSET = ids.KeyValue.value
        list_key_addr = ids.list.address_ + LIST_KEY_OFFSET
        list_key = memory[list_key_addr]
        list_value_addr = ids.list.address_ + LIST_VALUE_OFFSET
        list_value = memory[list_value_addr]

        # Get dict prev_value addr
        DICT_PREV_VALUE_OFFSET = ids.DictAccess.prev_value
        dict_prev_value_addr = ids.dict.address_ + DICT_PREV_VALUE_OFFSET

        # Populate ids.dict.prev_value using cumulative_sums...
        # Add list.value to cumulative_sums[list.key]...
        if list_key in cumulative_sums:
            memory[dict_prev_value_addr] = cumulative_sums[list_key]
            cumulative_sums[list_key] += list_value
        else:
            memory[dict_prev_value_addr] = 0
            cumulative_sums[list_key] = list_value

    %}
    # Copy list.key to dict.key...
    assert dict.key = list.key
    # Verify that dict.new_value = dict.prev_value + list.value...
    assert dict.new_value = dict.prev_value + list.value
    # Call recursively to build_dict()...
    return build_dict(list=list + KeyValue.SIZE, size=size - 1, dict=dict + DictAccess.SIZE)
end

# Verifies that the initial values were 0, and writes the final
# values to result.
func verify_and_output_squashed_dict(
        squashed_dict : DictAccess*,
        squashed_dict_end : DictAccess*, result : KeyValue*) -> (
        result : KeyValue*):
    tempvar diff = squashed_dict_end - squashed_dict
    if diff == 0:
        return (result=result)
    end

    # Verify prev_value is 0...
    assert squashed_dict.prev_value = 0
    # Copy key to result.key...
    assert result.key = squashed_dict.key
    # Copy new_value to result.value...
    assert result.value = squashed_dict.new_value
    # Call recursively to verify_and_output_squashed_dict...
    return verify_and_output_squashed_dict(
        squashed_dict=squashed_dict + DictAccess.SIZE,
        squashed_dict_end=squashed_dict_end,
        result=result + KeyValue.SIZE)
end

# Given a list of KeyValue, sums the values, grouped by key,
# and returns a list of pairs (key, sum_of_values).
func sum_by_key{range_check_ptr}(list : KeyValue*, size) -> (
        result : KeyValue*, result_size):
    %{
        # Initialize cumulative_sums with an empty dictionary.
        # This variable will be used by ``build_dict`` to hold
        # the current sum for each key.
        cumulative_sums = {}
    %}
    # Allocate memory for dict, squashed_dict and res...
    alloc_locals
    let (local dict_start : DictAccess*) = alloc()
    let (local squashed_dict : DictAccess*) = alloc()
    let (local result : KeyValue*) = alloc()
    local result_size

    # Call build_dict()...
    let (dict_end) = build_dict(
        list=list,
        size=size,
        dict=dict_start)
    # Call squash_dict()...
    let (squashed_dict_end : DictAccess*) = squash_dict(
        dict_accesses=dict_start,
        dict_accesses_end=dict_end,
        squashed_dict=squashed_dict)
    # Store range_check_ptr in a local variable to make it
    # accessible after the call to verify_and_output_squashed_dict().
    local range_check_ptr = range_check_ptr


    # Call verify_and_output_squashed_dict()...
    let (result_end) = verify_and_output_squashed_dict(
        squashed_dict=squashed_dict,
        squashed_dict_end=squashed_dict_end,
        result=result)
    assert result_size = (result_end - result) / 2
    return (result=result, result_size=result_size)
end

func main{output_ptr : felt*, range_check_ptr}():
    alloc_locals

    local loc_list : KeyValue*
    local size

    %{
        # The verifier doesn't care where those lists are
        # allocated or what values they contain, so we use a hint
        # to populate them.
        locations = program_input['loc_list']

        # Sanity check (only the prover runs this check).
        assert len(locations) % 2 == 0

        ids.loc_list = loc_list = segments.add()
        for i, val in enumerate(locations):
            memory[loc_list + i] = val

        ids.size = len(locations) // 2
    %}

    let (result: KeyValue*, result_size) = sum_by_key(list=loc_list, size=size)
    serialize_word(result_size)
    serialize_word(result.key)
    serialize_word(result.value)
    return ()
end