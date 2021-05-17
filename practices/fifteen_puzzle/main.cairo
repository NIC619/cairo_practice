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

    local loc0 : Location
    assert loc0.row = 0
    assert loc0.col = 2
    local loc1 : Location
    assert loc1.row = 1
    assert loc1.col = 2
    local loc2 : Location
    assert loc2.row = 1
    assert loc2.col = 3
    local loc3 : Location
    assert loc3.row = 2
    assert loc3.col = 3
    local loc4 : Location
    assert loc4.row = 3
    assert loc4.col = 3

    local tile0 = 3
    local tile1 = 7
    local tile2 = 8
    local tile3 = 12

    # Get the value of the frame pointer register (fp) so that
    # we can use the address of loc0.
    let (__fp__, _) = get_fp_and_pc()
    check_solution(loc_list=&loc0, tile_list=&tile0, n_steps=4)
    return ()
end