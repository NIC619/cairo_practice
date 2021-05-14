%builtins output

from starkware.cairo.common.alloc import alloc

# Computes the sum of the memory elements at addresses:
#   arr + 0, arr + 1, ..., arr + (size - 1).
func array_sum(arr : felt*, size) -> (sum):
    if size == 0:
        return (sum=0)
    end

    # size is not zero.
    let (sum_of_rest) = array_sum(arr=arr + 1, size=size - 1)
    return (sum=[arr] + sum_of_rest)
end

func main{output_ptr: felt*}():
    const ARRAY_SIZE = 3

    # Allocate an array.
    let (array_ptr) = alloc()
    # Populate some values in the array.
    assert [array_ptr] = 1
    assert [array_ptr + 1] = 2
    assert [array_ptr + 2] = 3

    let (sum) = array_sum(arr=array_ptr, size=ARRAY_SIZE)
    # Output sum
    assert [output_ptr] = sum
    let output_ptr = output_ptr + 1

    return ()
end