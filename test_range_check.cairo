%builtins range_check

func check_bound{range_check_ptr : felt*}(input: felt, bound: felt):
    [range_check_ptr] = input
    assert [range_check_ptr + 1] = bound - input

    let range_check_ptr = range_check_ptr + 2
    return()
end

func main{range_check_ptr : felt*}():
    check_bound(0, 1000)
    check_bound(1, 1000)
    check_bound(1000, 1000)
    check_bound(1001, 1000)
    return ()
end

