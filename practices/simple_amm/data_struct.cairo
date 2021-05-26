from starkware.cairo.common.dict import DictAccess

# The maximum amount of each token that belongs to the AMM.
const MAX_BALANCE = %[ 2**64 - 1 %]

struct Account:
    member public_key : felt
    member token_a_balance : felt
    member token_b_balance : felt
end

struct AmmState:
    # A dictionary that tracks the accounts' state.
    member account_dict_start : DictAccess*
    member account_dict_end : DictAccess*
    # The amount of the tokens currently in the AMM.
    # Must be in the range [0, MAX_BALANCE].
    member token_a_balance : felt
    member token_b_balance : felt
end

# Represents a swap transaction between a user and the AMM.
struct SwapTransaction:
    member account_id : felt
    member token_a_amount : felt
end

# The output of the AMM program.
struct AmmBatchOutput:
    # The balances of the AMM before applying the batch.
    member token_a_before : felt
    member token_b_before : felt
    # The balances of the AMM after applying the batch.
    member token_a_after : felt
    member token_b_after : felt
    # The account Merkle roots before and after applying
    # the batch.
    member account_root_before : felt
    member account_root_after : felt
end