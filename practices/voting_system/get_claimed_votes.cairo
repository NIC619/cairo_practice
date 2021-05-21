from starkware.cairo.common.alloc import alloc

from practices.voting_system.data_struct import VoteInfo

# Returns a list of VoteInfo instances representing the claimed
# votes.
# The validity of the returned data is not guaranteed and must
# be verified by the caller.
func get_claimed_votes() -> (votes : VoteInfo*, n : felt):
    alloc_locals
    local n
    let (votes : VoteInfo*) = alloc()
    %{
        ids.n = len(program_input['votes'])
        public_keys = [
            int(pub_key, 16) for pub_key in program_input['public_keys']
        ]
        for i, vote in enumerate(program_input['votes']):
            # Get the address of the i-th vote.
            base_addr = ids.votes.address_ + ids.VoteInfo.SIZE * i
            memory[base_addr + ids.VoteInfo.voter_id] = vote['voter_id']
            memory[base_addr + ids.VoteInfo.pub_key] = public_keys[vote['voter_id']]
            memory[base_addr + ids.VoteInfo.vote] = vote['vote']
            memory[base_addr + ids.VoteInfo.r] = int(vote['r'], 16)
            memory[base_addr + ids.VoteInfo.s] = int(vote['s'], 16)
    %}
    return (votes=votes, n=n)
end