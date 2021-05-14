%builtins output

from starkware.cairo.common.alloc import alloc

# Computes the product of the memory elements at addresses:
#   arr + 0, arr + 1, ..., arr + (size - 1).
func array_product(arr : felt*, size) -> (prod):
    if size == 1:
        return (prod=[arr])
    end

    # size is not zero.
    let (prod_of_rest) = array_product(arr=arr + 1, size=size - 1)
    return (prod=[arr] * prod_of_rest)
end

func main{output_ptr: felt*}():
    const ARRAY_SIZE = 3

    # Allocate an array.
    let (array_ptr) = alloc()
    # Populate some values in the array.
    assert [array_ptr] = 1
    assert [array_ptr + 1] = 2
    assert [array_ptr + 2] = 3

    let (prod) = array_product(arr=array_ptr, size=ARRAY_SIZE)
    # Output sum
    assert [output_ptr] = prod
    let output_ptr = output_ptr + 1

    return ()
end