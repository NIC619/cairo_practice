### Compile and run
- compile: `cairo-compile practices/fill_order/main.cairo --output fill_order_compiled.json`
- generate keys file: `python practices/fill_order/utils/gen_keys.py`
- generate input files, example:
```json
{
    "pre_state": {
        "fees": {
            "99": 0,
            "133": 0
        },
        "accounts": {
            "0": {
                "public_key": "0x1c3eb6d67f833a9dac3766b2f22d31299875884f3fc84ebc70c322e8fb18112",
                "token_balances": {
                    "99": 1000000,
                    "133": 5000000
                }
            },
            "5": {
                "public_key": "0x4cb42f213ed6dcfadb7b987fd31b2260334cbe404315708d17a2404fbadb11e",
                "token_balances": {
                    "99": 7500000,
                    "133": 200000
                }
            },
            "8": {
                "public_key": "0x529196a1456a35d3ee9138dd7355cb6416fe40deade3adab76f2e66554400ef",
                "token_balances": {
                    "99": 45000,
                    "133": 11100
                }
            }
        }
    },
    "transactions": [
        {
            "taker_account_id": 0,
            "taker_token_id": 99,
            "taker_token_amount": 400000,
            "maker_account_id": 5,
            "maker_token_id": 133,
            "maker_token_amount": 70000,
            "r_a": "0x21d530871b3c181d6c03538e96d884f2044c57339af11920b17a68f1c7dad94",
            "s_a": "0x5c5c49d3ab22706022c12f0e439aa3511450af06b61e4e8a1680413e135e58a",
            "r_b": "0x619bbe2ced8165f0556acb0e62be46fdad7d37816d3c14656808e80de262bc",
            "s_b": "0x2d84adc1aca82b89875ce77bc3d4f85a106315e663278d8b817cf072fa93361"
        },
        {
            "taker_account_id": 5,
            "taker_token_id": 99,
            "taker_token_amount": 190000,
            "maker_account_id": 0,
            "maker_token_id": 133,
            "maker_token_amount": 12000,
            "r_a": "0x3d63dacb9b539612c1bf1924eaa6bc6309090389df4fa4358362e7d9d84912e",
            "s_a": "0x1e110fc2ea20e931a9d19fa5d820407632c0071e7ca641ce2a0017faea07e6c",
            "r_b": "0x6ea7dc49b3c4c5bcf79b98bf895276f6ceda8c88327c9614c320c92bfeddb97",
            "s_b": "0x7e708d2a7e71b2b6fafef518842d6849af601ef015cd449b0223ab211681cc9"
        }
    ]
}
``` 
- generate transaction signatures: `python practices/fill_order/utils/gen_tx_signatures.py`
    - this will add "r_a", "s_a", "r_b" and "s_b" to `first_batch_input.json`
- run the program with first batch of transactions: `cairo-run --program=fill_order_compiled.json --print_output --layout=small --program_input=practices/fill_order/first_batch_input.json --cairo_pie_output practices/fill_order/fill_order_pie`
    - output should be:
    ```
    Order data:
    --------------------------------------------
    Taker: 0
    Taker token: 99
    Taker token amount: 400000
    Maker: 5
    Maker token: 133
    Maker token amount: 70000
    --------------------------------------------
    fee charged for maker token (133): 210
    update taker (0) account
    token 99 balance before: 1000000
    token 99 balance after: 600000
    token 133 balance before: 5000000
    token 133 balance after: 5069790
    update maker (5) account
    token 99 balance before: 7500000
    token 99 balance after: 7900000
    token 133 balance before: 200000
    token 133 balance after: 130000
    Order data:
    --------------------------------------------
    Taker: 5
    Taker token: 99
    Taker token amount: 190000
    Maker: 0
    Maker token: 133
    Maker token amount: 12000
    --------------------------------------------
    fee charged for maker token (133): 36
    update taker (5) account
    token 99 balance before: 7900000
    token 99 balance after: 7710000
    token 133 balance before: 130000
    token 133 balance after: 141964
    update maker (0) account
    token 99 balance before: 600000
    token 99 balance after: 790000
    token 133 balance before: 5069790
    token 133 balance after: 5057790
    Program output:
        210
        36
        -104853145814742110168993247012925585787191107073470760429852543341862106182
        -1366500469229165540160001907124508045981242018234589343985034629748046879123
    ```
    - `210` and `36` are the fees collected
    - `-104853145814742110168993247012925585787191107073470760429852543341862106182` is the pre state root
    - `-1366500469229165540160001907124508045981242018234589343985034629748046879123` is the post state root
    - you can run `python practices/fill_order/utils/compute_root.py` and input `first_batch_input` to see the produced pre/post state tree roots
        - output should be:
        ```
        input file name: first_batch_input
        pre_state:
        tree root: 3513649642851389103528329536082144519835916108258125939543239512794009914299

        post_state:
        tree root: 2252002319436965673537320875970562059641865197097007355988057426387825141358
        ```
        - note that the pre state tree roots (`-104853145814742110168993247012925585787191107073470760429852543341862106182 (mod p)` and `3513649642851389103528329536082144519835916108258125939543239512794009914299 (mod p)`) from both the Cairo program and the script are the same
            - the same applies to post state roots
        - this script will also generate a post state in `first_batch_input.json`, you can use this post state as the pre state for `second_batch_input.json` and add your transactions
    - `--cairo_pie_output` will output a cairo pie file which contains the information you need to generate proof
        - this pie file can be sent to SHARP with command `cairo-sharp submit --cairo_pie PIE_FILE_NAME`
    - you can run `python practices/fill_order/utils/compute_output_and_fact.py` to output program hash, program output and the fact for this round of execution
        - NOTE: program hash will be the same as long as the cairo program remains unchanged, however, fact will change based on the outputs each time
