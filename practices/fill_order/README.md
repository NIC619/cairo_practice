### Compile and run
- compile: `cairo-compile practices/fill_order/main.cairo --output fill_order_compiled.json`
- generate keys file: `python practices/fill_order/utils/gen_keys.py`
- generate input files, example:
```json
{
    "pre_state": {
        "accounts": {
            "0": {
                "public_key": "0x1c3eb6d67f833a9dac3766b2f22d31299875884f3fc84ebc70c322e8fb18112",
                "token_a_balance": 100,
                "token_b_balance": 500
            },
            "5": {
                "public_key": "0x4cb42f213ed6dcfadb7b987fd31b2260334cbe404315708d17a2404fbadb11e",
                "token_a_balance": 750,
                "token_b_balance": 20
            }
        }
    },
    "transactions": [
        {
            "taker_account_id": 0,
            "token_a_amount": 10,
            "maker_account_id": 5,
            "token_b_amount": 1,
        },
        {
            "taker_account_id": 5,
            "token_a_amount": 50,
            "maker_account_id": 0,
            "token_b_amount": 3,
        }
    ]
}
``` 
- generate transaction signatures: `python practices/fill_order/utils/gen_tx_signatures.py`
    - this will add "r_a", "s_a", "r_b" and "s_b" to `first_batch_input.json`
- run the program with first batch of transactions: `cairo-run --program=fill_order_compiled.json --print_output --layout=small --program_input=practices/fill_order/first_batch_input.json`
    - output should be:
    ```
    Taker (id: 0) swap 10 token a for 1 token b from maker (id: 5).
    Taker (id: 5) swap 50 token a for 3 token b from maker (id: 0).
    Program output:
        1623843059552719529035128991656293157653125704527498585135265290095705290904
        -1753022439135998450053725626254703968621217431619206483100904701965514789763
    ```
    - you can run `python practices/fill_order/utils/compute_root.py` and input `first_batch_input` to see the produced pre/post state tree roots
        - output should be:
        ```
        input file name: first_batch_input
        pre_state:
        tree root: 1623843059552719529035128991656293157653125704527498585135265290095705290904

        post_state:
        tree root: 1865480349530132763643597156840366137001889783712390216872187354170357230718
        ```
        - note that the post state tree roots (`-1753022439135998450053725626254703968621217431619206483100904701965514789763 (mod p)` and `1865480349530132763643597156840366137001889783712390216872187354170357230718 (mod p)`) are the same
        - this script will also generate a post state in `first_batch_input.json`, you can use this post state as the pre state for `second_batch_input.json` and add your transactions
