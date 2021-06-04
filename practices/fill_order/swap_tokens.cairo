from starkware.cairo.common.cairo_builtins import (
    HashBuiltin, SignatureBuiltin)
from starkware.cairo.common.math import (
    assert_nn_le, assert_not_equal, unsigned_div_rem)

from practices.fill_order.data_struct import (
    Account, State, MAX_BALANCE, SwapTransaction)
from practices.fill_order.update_account import update_account
from practices.fill_order.verify_tx_signature import verify_tx_signature

func swap{
        range_check_ptr,
        pedersen_ptr : HashBuiltin*,
        ecdsa_ptr : SignatureBuiltin*}(
        state : State, transaction : SwapTransaction*) -> (
        state : State):
    alloc_locals

    tempvar amount_a = transaction.token_a_amount
    tempvar amount_b = transaction.token_b_amount

    # Check that account id are not the same
    assert_not_equal(
        transaction.taker_account_id,
        transaction.maker_account_id)
    # Check that amount_a and amount_b are in range.
    assert_nn_le(amount_a, MAX_BALANCE)
    assert_nn_le(amount_b, MAX_BALANCE)

    # Update the users' account.
    let (state, pub_key_a) = update_account(
        state=state,
        account_id=transaction.taker_account_id,
        amount_a_diff=-amount_a,
        amount_b_diff=amount_b)

    let (state, pub_key_b) = update_account(
        state=state,
        account_id=transaction.maker_account_id,
        amount_a_diff=amount_a,
        amount_b_diff=-amount_b)

    verify_tx_signature(
        transaction,
        pub_key_a,
        pub_key_b)

    %{
        # Print the transaction values using a hint, for
        # debugging purposes.
        print(
            f'Taker (id: {ids.transaction.taker_account_id}) '
            f'swap {ids.amount_a} token a for '
            f'{ids.amount_b} token b from maker (id: {ids.transaction.maker_account_id}).')
    %}

    return (state=state)
end

func transaction_loop{
        range_check_ptr,
        pedersen_ptr : HashBuiltin*,
        ecdsa_ptr : SignatureBuiltin*}(
        state : State, transactions : SwapTransaction**,
        n_transactions) -> (state : State):
    if n_transactions == 0:
        return (state=state)
    end

    let first_transaction : SwapTransaction* = [transactions]
    let (state) = swap(
        state=state, transaction=first_transaction)

    return transaction_loop(
        state=state,
        transactions=transactions + 1,
        n_transactions=n_transactions - 1)
end