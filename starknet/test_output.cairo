%lang starknet
%builtins output

@external
func print{output_ptr : felt*}():
    assert [output_ptr] = 50
    let output_ptr = output_ptr + 1
    return ()
end

# The invoke transaction is accepted onchain but currently no way to verify the outputs or facts