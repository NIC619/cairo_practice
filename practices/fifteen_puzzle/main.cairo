%builtins output range_check

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.squash_dict import squash_dict

from practices.fifteen_puzzle.verify_location_list import Location, verify_location_list
from practices.fifteen_puzzle.build_dict_and_state import build_dict, finalize_state, output_initial_values

func check_solution{output_ptr : felt*, range_check_ptr}(
        loc_list : Location*, tile_list : felt*, n_steps):
    alloc_locals

    # Start by verifying that loc_list is valid.
    verify_location_list(loc_list=loc_list, n_steps=n_steps)

    # Allocate memory for the dict and the squashed dict.
    let (local dict_start : DictAccess*) = alloc()
    let (local squashed_dict : DictAccess*) = alloc()

    let (dict_end) = build_dict(
        loc_list=loc_list,
        tile_list=tile_list,
        n_steps=n_steps,
        dict=dict_start)

    let (dict_end) = finalize_state(dict=dict_end, idx=15)

    let (squashed_dict_end : DictAccess*) = squash_dict(
        dict_accesses=dict_start,
        dict_accesses_end=dict_end,
        squashed_dict=squashed_dict)

    # Store range_check_ptr in a local variable to make it
    # accessible after the call to output_initial_values().
    local range_check_ptr = range_check_ptr

    # Verify that the squashed dict has exactly 15 entries.
    # This will guarantee that all the values in the tile list
    # are in the range 1-15.
    assert squashed_dict_end - squashed_dict = 15 *
        DictAccess.SIZE

    output_initial_values(squashed_dict=squashed_dict, n=15)

    # Output the initial location of the empty tile.
    serialize_word(4 * loc_list.row + loc_list.col)

    # Output the number of steps.
    serialize_word(n_steps)

    return ()
end

func main{output_ptr : felt*, range_check_ptr}():
    alloc_locals

    # Declare two variables that will point to the two lists and
    # another variable that will contain the number of steps.
    local loc_list : Location*
    local tile_list : felt*
    local n_steps

    %{
        # The verifier doesn't care where those lists are
        # allocated or what values they contain, so we use a hint
        # to populate them.
        locations = program_input['loc_list']
        tiles = program_input['tile_list']

        ids.loc_list = loc_list = segments.add()
        for i, val in enumerate(locations):
            memory[loc_list + i] = val

        ids.tile_list = tile_list = segments.add()
        for i, val in enumerate(tiles):
            memory[tile_list + i] = val

        ids.n_steps = len(tiles)

        # Sanity check (only the prover runs this check).
        assert len(locations) == 2 * (len(tiles) + 1)
    %}

    check_solution(
        loc_list=loc_list, tile_list=tile_list, n_steps=n_steps)
    return ()
end