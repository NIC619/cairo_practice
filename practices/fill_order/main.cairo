%builtins output pedersen range_check ecdsa

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import (
    HashBuiltin, SignatureBuiltin)
from starkware.cairo.common.dict import (
    DictAccess, dict_new, dict_squash, dict_update)

from practices.fill_order.compute_merkle_roots import compute_merkle_roots
from practices.fill_order.data_struct import (
    Account, MerkleRootsOutput, State, MAX_BALANCE, SwapTransaction)
from practices.fill_order.swap_tokens import transaction_loop


func get_transactions() -> (
        transactions : SwapTransaction**, n_transactions : felt):
    alloc_locals
    local transactions : SwapTransaction**
    local n_transactions : felt
    %{
        transactions = [
            [
                transaction['taker_account_id'],
                transaction['token_a_amount'],
                int(transaction['r_a'], 16),
                int(transaction['s_a'], 16),
                transaction['maker_account_id'],
                transaction['token_b_amount'],
                int(transaction['r_b'], 16),
                int(transaction['s_b'], 16),
            ]
            for transaction in program_input['transactions']
        ]
        ids.transactions = segments.gen_arg(transactions)
        ids.n_transactions = len(transactions)
    %}
    return (
        transactions=transactions,
        n_transactions=n_transactions)
end

func get_account_dict() -> (account_dict : DictAccess*):
    alloc_locals
    %{
        pre_state = program_input['pre_state']
        account = pre_state['accounts']
        initial_dict = {
            int(account_id_str): segments.gen_arg([
                int(info['public_key'], 16),
                info['token_a_balance'],
                info['token_b_balance'],
            ])
            for account_id_str, info in account.items()
        }

        # Save a copy initial account dict for
        # compute_merkle_roots.
        initial_account_dict = dict(initial_dict)
    %}

    # Initialize the account dictionary.
    let (account_dict) = dict_new()
    return (account_dict=account_dict)
end

func main{
        output_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr, ecdsa_ptr : SignatureBuiltin*}():
    alloc_locals

    # Create the initial state.
    local state : State

    let (account_dict) = get_account_dict()
    assert state.account_dict_start = account_dict
    assert state.account_dict_end = account_dict

    # Execute the transactions.
    let (transactions, n_transactions) = get_transactions()
    let (state : State) = transaction_loop(
        state=state,
        transactions=transactions,
        n_transactions=n_transactions)      
    local output_ptr : felt* = output_ptr

    local ecdsa_ptr : SignatureBuiltin* = ecdsa_ptr

    let output = cast(output_ptr, MerkleRootsOutput*)
    let output_ptr = output_ptr + MerkleRootsOutput.SIZE

    # Write the Merkle roots to the output.
    let (root_before, root_after) = compute_merkle_roots(
        state=state)
    assert output.account_root_before = root_before
    assert output.account_root_after = root_after

    return ()
end