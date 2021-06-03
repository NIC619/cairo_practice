from starkware.cairo.common.math import (
    assert_nn_le, assert_not_equal, unsigned_div_rem)

from practices.fill_order.data_struct import (
    Account, State, MAX_BALANCE, SwapTransaction)
from practices.fill_order.update_account import update_account

func swap{range_check_ptr}(
        state : State, transaction : SwapTransaction*) -> (
        state : State):
    alloc_locals

    tempvar amount_a = transaction.token_a_amount
    tempvar amount_b = transaction.token_b_amount

    # Check that account id are not the same
    assert_not_equal(
        transaction.token_a_sender_account_id,
        transaction.token_b_sender_account_id)
    # Check that amount_a and amount_b are in range.
    assert_nn_le(amount_a, MAX_BALANCE)
    assert_nn_le(amount_b, MAX_BALANCE)

    # Update the users' account.
    let (state, pub_key_a) = update_account(
        state=state,
        account_id=transaction.token_a_sender_account_id,
        amount_a_diff=-amount_a,
        amount_b_diff=amount_b)

    # TODO:
    # Here you should verify the user has signed on a message
    # specifying that they would like to sell 'amount_a' tokens of
    # type token_a. You should use the public key returned by
    # update_account().

    let (state, pub_key_b) = update_account(
        state=state,
        account_id=transaction.token_b_sender_account_id,
        amount_a_diff=amount_a,
        amount_b_diff=-amount_b)

    # TODO:
    # Also verify user b' message

    %{
        # Print the transaction values using a hint, for
        # debugging purposes.
        print(
            f'Swap: Account {ids.transaction.token_a_sender_account_id} '
            f'gave {ids.amount_a} tokens of type token_a and '
            f'received {ids.amount_b} tokens of type token_b.')
        
        print(
            f'Swap: Account {ids.transaction.token_b_sender_account_id} '
            f'gave {ids.amount_b} tokens of type token_a and '
            f'received {ids.amount_a} tokens of type token_b.')
    %}

    return (state=state)
end

func transaction_loop{range_check_ptr}(
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