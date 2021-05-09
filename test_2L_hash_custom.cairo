%builtins output pedersen

from starkware.cairo.common.cairo_builtins import HashBuiltin

# H(x, y)
func hash2(pedersen_ptr : HashBuiltin*, x, y) -> (pedersen_ptr : HashBuiltin*, res):
    let hash = pedersen_ptr
    hash.x = x
    hash.y = y

    return (pedersen_ptr=pedersen_ptr + HashBuiltin.SIZE, res=hash.result)
end

# H(H(x, y), z)
func hash2_2(pedersen_ptr : HashBuiltin*, x, y, z) -> (pedersen_ptr : HashBuiltin*, res):
    let hash = pedersen_ptr
    hash.x = x
    hash.y = y
    tempvar res_1 = hash.result
    let pedersen_ptr = pedersen_ptr + HashBuiltin.SIZE
    let hash_2 = pedersen_ptr
    hash_2.x = res_1
    hash_2.y = z

    return (pedersen_ptr=pedersen_ptr + HashBuiltin.SIZE, res=hash_2.result)
end

func main{output_ptr : felt*, pedersen_ptr : HashBuiltin*}():
    # Use hash2 to compute H(H(x, y), z)
    # 1. H(x, y)
    let (pedersen_ptr, res) = hash2(pedersen_ptr, 0, 0)
    assert [output_ptr] = res
    let output_ptr = output_ptr + 1
    # 2. H(H(x, y), z)
    let (pedersen_ptr, res) = hash2(pedersen_ptr, res, 1)
    assert [output_ptr] = res
    let output_ptr = output_ptr + 1

    # Use hash2_2 to compute H(H(x, y), z)
    let (pedersen_ptr, res) = hash2_2(pedersen_ptr, 0, 0, 1)
    assert [output_ptr] = res
    let output_ptr = output_ptr + 1
    
    assert [output_ptr - 1] = [output_ptr - 2]
    
    return()
end


