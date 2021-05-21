from starkware.cairo.common.cairo_builtins import (
    HashBuiltin, SignatureBuiltin)
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.signature import (
    verify_ecdsa_signature)

from practices.voting_system.data_struct import VoteInfo

# The identifier that represents what we're voting for.
# This will appear in the user's signature to distinguish
# between different polls.
const POLL_ID = 10018

func verify_vote_signature{
        pedersen_ptr : HashBuiltin*,
        ecdsa_ptr : SignatureBuiltin*}(
        vote_info_ptr : VoteInfo*):
    let (message) = hash2{hash_ptr=pedersen_ptr}(
        x=POLL_ID, y=vote_info_ptr.vote)

    verify_ecdsa_signature(
        message=message,
        public_key=vote_info_ptr.pub_key,
        signature_r=vote_info_ptr.r,
        signature_s=vote_info_ptr.s)
    return ()
end