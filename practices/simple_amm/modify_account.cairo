from starkware.cairo.common.dict import dict_read, dict_write
from starkware.cairo.common.math import assert_nn_le
from starkware.cairo.common.registers import get_fp_and_pc

from practices.simple_amm.data_struct import (
    Account, AmmState, MAX_BALANCE)

func modify_account{range_check_ptr}(
        state : AmmState, account_id, diff_a, diff_b) -> (
        state : AmmState, key):
    alloc_locals

    # Define a reference to state.account_dict_end so that we
    # can use it as an implicit argument to the dict functions.
    let account_dict_end = state.account_dict_end

    # Retrieve the pointer to the current state of the account.
    let (local old_account : Account*) = dict_read{
        dict_ptr=account_dict_end}(key=account_id)

    # Compute the new account values.
    tempvar new_token_a_balance = (
        old_account.token_a_balance + diff_a)
    tempvar new_token_b_balance = (
        old_account.token_b_balance + diff_b)

    # Verify that the new balances are positive.
    assert_nn_le(new_token_a_balance, MAX_BALANCE)
    assert_nn_le(new_token_b_balance, MAX_BALANCE)

    # Create a new Account instance.
    local new_account : Account
    assert new_account.public_key = old_account.public_key
    assert new_account.token_a_balance = new_token_a_balance
    assert new_account.token_b_balance = new_token_b_balance

    # Perform the account update.
    let (__fp__, _) = get_fp_and_pc()
    dict_write{dict_ptr=account_dict_end}(
        key=account_id, new_value=cast(&new_account, felt))

    # Construct and return the new state.
    local new_state : AmmState
    assert new_state.account_dict_start = (
        state.account_dict_start)
    assert new_state.account_dict_end = account_dict_end
    assert new_state.token_a_balance = state.token_a_balance
    assert new_state.token_b_balance = state.token_b_balance

    return (state=new_state, key=old_account.public_key)
end