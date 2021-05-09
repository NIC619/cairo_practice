%builtins output pedersen

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2

# H(H(x, y), z)
func hash2_2{pedersen_ptr : HashBuiltin*}(x, y, z) -> (res):
    let res = hash2{hash_ptr=pedersen_ptr}(x, y)
    let res = hash2{hash_ptr=pedersen_ptr}(res.result, z)

    return (res=res.result)
end

# Implicit arguments: addresses of the output and pedersen
# builtins.
func main{output_ptr, pedersen_ptr : HashBuiltin*}():
    let (res) = hash2_2(0, 0, 1)
    assert [output_ptr] = res

    # Manually update the output builtin pointer.
    let output_ptr = output_ptr + 1

    # output_ptr and pedersen_ptr will be implicitly returned.
    return ()
end