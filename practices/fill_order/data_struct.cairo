from starkware.cairo.common.dict import DictAccess

# The maximum amount of token.
const MAX_BALANCE = %[ 2**64 - 1 %]

struct Account:
    member public_key : felt
    member token_a_balance : felt
    member token_b_balance : felt
end

struct State:
    # A dictionary that tracks the accounts' state.
    member account_dict_start : DictAccess*
    member account_dict_end : DictAccess*
end

# Represents a swap transaction between two users.
struct SwapTransaction:
    member taker_account_id : felt
    member token_a_amount : felt
    member r_a : felt
    member s_a : felt
    member maker_account_id : felt
    member token_b_amount : felt
    member r_b : felt
    member s_b : felt
end

# The output of the program.
struct BatchOutput:
    # The account Merkle roots before and after applying
    # the batch.
    member account_root_before : felt
    member account_root_after : felt
end