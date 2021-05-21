%builtins output pedersen range_check ecdsa

from starkware.cairo.common.cairo_builtins import (
    HashBuiltin, SignatureBuiltin)
from starkware.cairo.common.dict import dict_squash
from starkware.cairo.common.small_merkle_tree import (
    small_merkle_tree)

from practices.voting_system.data_struct import (
    BatchOutput, VoteInfo, VotingState)
from practices.voting_system.get_claimed_votes import get_claimed_votes
from practices.voting_system.init_voting_state import init_voting_state
from practices.voting_system.process_votes import process_votes
from practices.voting_system.verify_vote_signature import verify_vote_signature

func main{
        output_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr, ecdsa_ptr : SignatureBuiltin*}():
    alloc_locals

    const LOG_N_VOTERS = 10

    let output = cast(output_ptr, BatchOutput*)
    let output_ptr = output_ptr + BatchOutput.SIZE

    let (votes, n_votes) = get_claimed_votes()
    let (state) = init_voting_state()
    process_votes{state=state}(votes=votes, n_votes=n_votes)
    local pedersen_ptr : HashBuiltin* = pedersen_ptr
    local ecdsa_ptr : SignatureBuiltin* = ecdsa_ptr

    # Write the "yes" and "no" counts to the output.
    assert output.n_yes_votes = state.n_yes_votes
    assert output.n_no_votes = state.n_no_votes

    # Squash the dict.
    let (squashed_dict_start, squashed_dict_end) = dict_squash(
        dict_accesses_start=state.public_key_tree_start,
        dict_accesses_end=state.public_key_tree_end)
    local range_check_ptr = range_check_ptr

    # Compute the two Merkle roots.
    let (root_before, root_after) = small_merkle_tree{
        hash_ptr=pedersen_ptr}(
        squashed_dict_start=squashed_dict_start,
        squashed_dict_end=squashed_dict_end,
        height=LOG_N_VOTERS)

    # Write the Merkle roots to the output.
    assert output.public_keys_root_before = root_before
    assert output.public_keys_root_after = root_after

    return ()
end