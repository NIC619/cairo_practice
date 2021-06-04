from starkware.cairo.common.cairo_builtins import (
    HashBuiltin, SignatureBuiltin)
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.signature import (
    verify_ecdsa_signature)

from practices.fill_order.data_struct import SwapTransaction

# Returns a hash committing to the transaction using the
# following formula:
#   H(H(token_a_sender, token_a_amount), H(token_b_sender, token_b_amount)).
# where H is the Pedersen hash function.
func hash_transaction{pedersen_ptr : HashBuiltin*}(
        transaction : SwapTransaction*) -> (res : felt):
    let (a_hash) = hash2{hash_ptr=pedersen_ptr}(
        transaction.token_a_sender_account_id,
        transaction.token_a_amount)
    let (b_hash) = hash2{hash_ptr=pedersen_ptr}(
        transaction.token_b_sender_account_id,
        transaction.token_b_amount)
    let (res) = hash2{hash_ptr=pedersen_ptr}(
        a_hash, b_hash)
    return (res=res)
end

func verify_tx_signature{
        pedersen_ptr : HashBuiltin*,
        ecdsa_ptr : SignatureBuiltin*}(
        transaction : SwapTransaction*, pub_key_a, pub_key_b):
    let (message) = hash_transaction(transaction)

    # Verify a and b's signature
    verify_ecdsa_signature(
        message=message,
        public_key=pub_key_a,
        signature_r=transaction.r_a,
        signature_s=transaction.s_a)
    verify_ecdsa_signature(
        message=message,
        public_key=pub_key_b,
        signature_r=transaction.r_b,
        signature_s=transaction.s_b)
    return ()
end