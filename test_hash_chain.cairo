%builtins output pedersen

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2

# Given [x, y, z, ...]
# Compute H(H(H(x, y), z), ...)
func hash_chain{pedersen_ptr : HashBuiltin*}(array_ptr: felt*, size) -> (res: felt):
    if size == 2:
        return hash2{hash_ptr=pedersen_ptr}([array_ptr], [array_ptr + 1])
    end

    # array_ptr is not incremented because in the end of the recursion,
    # hash of the first two elements are computed instead of the last two
    let res: felt = hash_chain(array_ptr, size - 1)
    
    # return H(res, last_element)
    return hash2{hash_ptr=pedersen_ptr}(x=res, y=[array_ptr + size - 1])
end

# Implicit arguments: addresses of the output and pedersen
# builtins.
func main{output_ptr, pedersen_ptr : HashBuiltin*}():
    const ARRAY_SIZE = 3

    # Allocate an array.
    let (array_ptr) = alloc()
    # Populate some values in the array.
    assert [array_ptr] = 0
    assert [array_ptr + 1] = 1
    assert [array_ptr + 2] = 0
    let res: felt = hash_chain(array_ptr, size=ARRAY_SIZE)

    %{
        print(f'PRIME = {PRIME}\nres % PRIME = {ids.res}')
    %}
    assert [output_ptr] = res

    # Manually update the output builtin pointer.
    let output_ptr = output_ptr + 1

    # output_ptr and pedersen_ptr will be implicitly returned.
    return ()
end

# Hash Chain samples
# H(0, 0) = -1528516508317877792526642961614204972800040744393150604467269738882277939197
# H(0, 1) = -1617362706135511974035592974010491807323883405129499077211459671574759629502
# H(1, 0) = 1089549915800264549621536909767699778745926517555586332772759280702396009108
# H(1,1) = 1321142004022994845681377299801403567378503530250467610343381590909832171180
# H(H(0, 0), 1) = 34429948809931494800361881368895479931292362438536085579934342311090929174
# H(H(1, 0), 0) = -1786134237006832531420281490756311293842603981952701045851732209311404786613
# H(H(1, 1), 0) = -2455958557602757457818534060077331474260472571891809679990867710845045982