%builtins output pedersen

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2

# Implicit arguments: addresses of the output and pedersen
# builtins.
func main{output_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    local preimage
    %{ ids.preimage = program_input['preimage'] %}

    let (digest) = hash2{hash_ptr=pedersen_ptr}(preimage, 0)
    assert [output_ptr] = digest
    let output_ptr = output_ptr + 1

    return ()
end