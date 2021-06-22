%lang starknet
%builtins pedersen

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.core.storage.storage import Storage

@storage_var
func map(index : felt) -> (res : felt):
end

func process_array_loop{storage_ptr : Storage*, pedersen_ptr : HashBuiltin*}(array : felt*, length : felt):
    if length == 0:
        return ()
    end

    map.write(index=length, value=[array])

    return process_array_loop(array=array + 1, length=length - 1)
end

@external
func process_array{storage_ptr : Storage*, pedersen_ptr : HashBuiltin*}(array : felt*, length : felt):
    process_array_loop(array=array, length=length)
    return ()
end

# This contract can not be successfully compiled. Error: starknet/test_array_input.cairo:22:81: Unsupported argument type felt*.