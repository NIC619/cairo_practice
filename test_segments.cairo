from starkware.cairo.common.alloc import alloc

func main():
    alloc_locals

    # `segments.gen_arg` takes an array of values and creates a new memory segment initialized with those values.
    # It returns a pointer to the new segment. For example:
    local x : felt*
    %{ ids.x = segments.gen_arg([1, 2, 3]) %}
    assert [x] = 1
    assert [x + 1] = 2
    assert [x + 2] = 3

    # But that’s not all – segments.gen_arg() works recursively,
    # so any element of the input array can be an array itself:
    local y : felt** # y is a list of lists.
    %{ ids.y = segments.gen_arg([[1, 2], [3, 4]]) %}
    assert [[y]] = 1
    assert [[y] + 1] = 2
    assert [[y + 1]] = 3
    assert [[y + 1] + 1] = 4

    # By the way, another similar utility function is segments.write_arg().
    # It behaves like segments.gen_arg(), except that it gets the pointer
    # to write to rather than allocating a new memory segment:
    let (vec : felt*) = alloc()
    # Here, an address was already assigned to vec.
    %{ segments.write_arg(ids.vec, [1, 2, 3]) %}
    ap += 2
    assert [vec] = 1
    assert [vec + 1] = 2
    assert [vec + 2] = 3

    return ()
end