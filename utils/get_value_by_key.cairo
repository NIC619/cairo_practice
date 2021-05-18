from starkware.cairo.common.math import assert_nn_le

struct KeyValue:
    member key : felt
    member value : felt
end

# Returns the value associated with the given key.
func get_value_by_key{range_check_ptr}(
        list : KeyValue*, size, key) -> (value):
    alloc_locals
    local idx
    %{
        # Populate idx using a hint.
        ENTRY_SIZE = ids.KeyValue.SIZE
        KEY_OFFSET = ids.KeyValue.key
        VALUE_OFFSET = ids.KeyValue.value
        for i in range(ids.size):
            addr = ids.list.address_ + ENTRY_SIZE * i + \
                KEY_OFFSET
            if memory[addr] == ids.key:
                ids.idx = i
                break
        else:
            raise Exception(
                f'Key {ids.key} was not found in the list.')
    %}

    # Verify that we have the correct key.
    let item : KeyValue* = list + KeyValue.SIZE * idx
    assert item.key = key

    # Verify that the index is in range (0 <= idx <= size - 1).
    assert_nn_le(a=idx, b=size - 1)

    # Return the corresponding value.
    return (value=item.value)
end