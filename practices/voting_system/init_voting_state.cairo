from starkware.cairo.common.dict import (
    DictAccess, dict_new)

from practices.voting_system.data_struct import VotingState

func init_voting_state() -> (state : VotingState):
    alloc_locals
    local state : VotingState
    assert state.n_yes_votes = 0
    assert state.n_no_votes = 0
    %{
        public_keys = [
            int(pub_key, 16)
            for pub_key in program_input['public_keys']]
        initial_dict = dict(enumerate(public_keys))
    %}
    let (dict : DictAccess*) = dict_new()
    assert state.public_key_tree_start = dict
    assert state.public_key_tree_end = dict
    return (state=state)
end