from starkware.cairo.common.math import (
    assert_nn_le, unsigned_div_rem)

from practices.simple_amm.data_struct import (
    Account, AmmState, MAX_BALANCE, SwapTransaction)
from practices.simple_amm.modify_account import modify_account

func swap{range_check_ptr}(
        state : AmmState, transaction : SwapTransaction*) -> (
        state : AmmState):
    alloc_locals

    tempvar a = transaction.token_a_amount
    tempvar x = state.token_a_balance
    tempvar y = state.token_b_balance

    # Check that a is in range.
    assert_nn_le(a, MAX_BALANCE)

    # Compute the amount of token_b the user will get:
    #   b = (y * a) / (x + a).
    let (b, _) = unsigned_div_rem(y * a, x + a)
    # Make sure that b is also in range.
    assert_nn_le(b, MAX_BALANCE)

    # Update the user's account.
    let (state, key) = modify_account(
        state=state,
        account_id=transaction.account_id,
        diff_a=-a,
        diff_b=b)

    # Here you should verify the user has signed on a message
    # specifying that they would like to sell 'a' tokens of
    # type token_a. You should use the public key returned by
    # modify_account().

    # Compute the new balances of the AMM and make sure they
    # are in range.
    tempvar new_x = x + a
    tempvar new_y = y - b
    assert_nn_le(new_x, MAX_BALANCE)
    assert_nn_le(new_y, MAX_BALANCE)

    # Update the state.
    local new_state : AmmState
    assert new_state.account_dict_start = (
        state.account_dict_start)
    assert new_state.account_dict_end = state.account_dict_end
    assert new_state.token_a_balance = new_x
    assert new_state.token_b_balance = new_y

    %{
        # Print the transaction values using a hint, for
        # debugging purposes.
        print(
            f'Swap: Account {ids.transaction.account_id} '
            f'gave {ids.a} tokens of type token_a and '
            f'received {ids.b} tokens of type token_b.')
    %}

    return (state=new_state)
end

func transaction_loop{range_check_ptr}(
        state : AmmState, transactions : SwapTransaction**,
        n_transactions) -> (state : AmmState):
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