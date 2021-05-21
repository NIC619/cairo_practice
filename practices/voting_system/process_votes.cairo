from starkware.cairo.common.cairo_builtins import (
    HashBuiltin, SignatureBuiltin)
from starkware.cairo.common.dict import dict_update
from starkware.cairo.common.math import assert_not_zero

from practices.voting_system.data_struct import (
    VoteInfo, VotingState)
from practices.voting_system.verify_vote_signature import verify_vote_signature

func process_vote{
        pedersen_ptr : HashBuiltin*,
        ecdsa_ptr : SignatureBuiltin*, state : VotingState}(
        vote_info_ptr : VoteInfo*):
    alloc_locals

    # Verify that pub_key != 0.
    assert_not_zero(vote_info_ptr.pub_key)

    # Verify the signature's validity.
    verify_vote_signature(vote_info_ptr=vote_info_ptr)

    # Update the public key dict.
    let public_key_tree_end = state.public_key_tree_end
    dict_update{dict_ptr=public_key_tree_end}(
        key=vote_info_ptr.voter_id,
        prev_value=vote_info_ptr.pub_key,
        new_value=0)

    # Generate the new state.
    local new_state : VotingState
    assert new_state.public_key_tree_start = (
        state.public_key_tree_start)
    assert new_state.public_key_tree_end = (
        public_key_tree_end)

    # Update the counters.
    tempvar vote = vote_info_ptr.vote
    if vote == 0:
        # Vote "No".
        assert new_state.n_yes_votes = state.n_yes_votes
        assert new_state.n_no_votes = state.n_no_votes + 1
    else:
        # Make sure that in this case vote=1.
        assert vote = 1

        # Vote "Yes".
        assert new_state.n_yes_votes = state.n_yes_votes + 1
        assert new_state.n_no_votes = state.n_no_votes
    end

    # Update the state.
    let state = new_state
    return ()
end

func process_votes{
        pedersen_ptr : HashBuiltin*,
        ecdsa_ptr : SignatureBuiltin*, state : VotingState}(
        votes : VoteInfo*, n_votes : felt):
    if n_votes == 0:
        return ()
    end

    process_vote(vote_info_ptr=votes)

    process_votes(
        votes=votes + VoteInfo.SIZE, n_votes=n_votes - 1)
    return ()
end