%lang starknet
%builtins pedersen

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.core.storage.storage import Storage

@storage_var
func ans() -> (res : felt):
end

@view
func get_ans{
        storage_ptr : Storage*, pedersen_ptr : HashBuiltin*}(
        ) -> (res : felt):
    let (res) = ans.read()
    return (res)
end

@external
func compute_sqrt{storage_ptr : Storage*, pedersen_ptr : HashBuiltin*}(
        number : felt):
    [ap] = number; ap++
    [ap - 1] = [ap] * [ap]
    ans.write([ap])

    return ()
end

# Invoking `compute_sqrt` will result in tx being rejected:
# {
#     "tx_failure_reason": {
#         "code": "TRANSACTION_FAILED",
#         "error_message": "Error at pc=0:61:\nUnknown value for memory cell at address 1:10.\nCairo traceback (most recent call last):\nUnknown location (pc=0:71)"
#     },
#     "tx_status": "REJECTED"
# }