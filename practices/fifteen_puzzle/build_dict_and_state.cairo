from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.squash_dict import squash_dict

from practices.fifteen_puzzle.verify_location_list import Location

func build_dict(
        loc_list : Location*, tile_list : felt*, n_steps,
        dict : DictAccess*) -> (dict : DictAccess*):
    if n_steps == 0:
        # When there are no more steps, just return the dict
        # pointer.
        return (dict=dict)
    end

    # Set the key to the current tile being moved.
    assert dict.key = [tile_list]

    # Its previous location should be where the empty tile is
    # going to be.
    let next_loc : Location* = loc_list + Location.SIZE
    assert dict.prev_value = 4 * next_loc.row + next_loc.col

    # Its next location should be where the empty tile is
    # now.
    assert dict.new_value = 4 * loc_list.row + loc_list.col

    # Call build_dict recursively.
    return build_dict(
        loc_list=next_loc,
        tile_list=tile_list + 1,
        n_steps=n_steps - 1,
        dict=dict + DictAccess.SIZE)
end

# Final state ("solved" configuration)
func finalize_state(dict : DictAccess*, idx) -> (
        dict : DictAccess*):
    if idx == 0:
        return (dict=dict)
    end

    assert dict.key = idx
    assert dict.prev_value = idx - 1
    assert dict.new_value = idx - 1

    # Call finalize_state recursively.
    return finalize_state(
        dict=dict + DictAccess.SIZE, idx=idx - 1)
end

# Initial state
func output_initial_values{output_ptr : felt*}(
        squashed_dict : DictAccess*, n):
    if n == 0:
        return ()
    end

    # print tile number
    serialize_word(squashed_dict.key)
    # print tile location, i.e., 4*row + col
    serialize_word(squashed_dict.prev_value)

    # Call output_initial_values recursively.
    return output_initial_values(
        squashed_dict=squashed_dict + DictAccess.SIZE, n=n - 1)
end