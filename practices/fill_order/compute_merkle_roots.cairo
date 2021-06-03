from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.dict import (
    DictAccess, dict_new, dict_squash, dict_update)
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.small_merkle_tree import (
    small_merkle_tree)

from practices.fill_order.data_struct import (
    Account, State)

const LOG_N_ACCOUNTS = 10

# Returns a hash committing to the account's state using the
# following formula:
#   H(H(public_key, token_a_balance), token_b_balance).
# where H is the Pedersen hash function.
func hash_account{pedersen_ptr : HashBuiltin*}(
        account : Account*) -> (res : felt):
    let res = account.public_key
    let (res) = hash2{hash_ptr=pedersen_ptr}(
        res, account.token_a_balance)
    let (res) = hash2{hash_ptr=pedersen_ptr}(
        res, account.token_b_balance)
    return (res=res)
end

# For each entry in the input dict (represented by dict_start
# and dict_end) write an entry to the output dict (represented by
# hash_dict_start and hash_dict_end) after applying hash_account
# on prev_value and new_value and keeping the same key.
func hash_dict_values{pedersen_ptr : HashBuiltin*}(
        dict_start : DictAccess*, dict_end : DictAccess*,
        hash_dict_start : DictAccess*) -> (
        hash_dict_end : DictAccess*):
    if dict_start == dict_end:
        return (hash_dict_end=hash_dict_start)
    end

    # Compute the hash of the account before and after the
    # change.
    let (prev_hash) = hash_account(
        account=cast(dict_start.prev_value, Account*))
    let (new_hash) = hash_account(
        account=cast(dict_start.new_value, Account*))

    # Add an entry to the output dict.
    dict_update{dict_ptr=hash_dict_start}(
        key=dict_start.key,
        prev_value=prev_hash,
        new_value=new_hash)
    return hash_dict_values(
        dict_start=dict_start + DictAccess.SIZE,
        dict_end=dict_end,
        hash_dict_start=hash_dict_start)
end

# Computes the Merkle roots before and after the batch.
# Hint argument: initial_account_dict should be a dictionary
# from account_id to an address in memory of the Account struct.
func compute_merkle_roots{
        pedersen_ptr : HashBuiltin*, range_check_ptr}(
        state : State) -> (root_before, root_after):
    alloc_locals

    # Squash the account dictionary.
    let (squashed_dict_start, squashed_dict_end) = dict_squash(
        dict_accesses_start=state.account_dict_start,
        dict_accesses_end=state.account_dict_end)
    local range_check_ptr = range_check_ptr

    # Hash the dict values.
    %{
        from starkware.crypto.signature.signature import pedersen_hash

        initial_dict = {}
        for account_id, account in initial_account_dict.items():
            public_key = memory[
                account + ids.Account.public_key]
            token_a_balance = memory[
                account + ids.Account.token_a_balance]
            token_b_balance = memory[
                account + ids.Account.token_b_balance]
            initial_dict[account_id] = pedersen_hash(
                pedersen_hash(public_key, token_a_balance),
                token_b_balance)
    %}
    let (local hash_dict_start : DictAccess*) = dict_new()
    let (hash_dict_end) = hash_dict_values(
        dict_start=squashed_dict_start,
        dict_end=squashed_dict_end,
        hash_dict_start=hash_dict_start)

    # Compute the two Merkle roots.
    let (root_before, root_after) = small_merkle_tree{
        hash_ptr=pedersen_ptr}(
        squashed_dict_start=hash_dict_start,
        squashed_dict_end=hash_dict_end,
        height=LOG_N_ACCOUNTS)

    return (root_before=root_before, root_after=root_after)
end