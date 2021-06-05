### Compile and run
- compile: `cairo-compile practices/fill_order/main.cairo --output fill_order_compiled.json`
- generate keys file: `python practices/fill_order/utils/gen_keys.py`
- generate input files, example:
```json
{
    "pre_state": {
        "fee": {
            "token_a_balance": 1,
            "token_b_balance": 1
        },
        "accounts": {
            "0": {
                "public_key": "0x1c3eb6d67f833a9dac3766b2f22d31299875884f3fc84ebc70c322e8fb18112",
                "token_a_balance": 1000000,
                "token_b_balance": 5000000
            },
            "5": {
                "public_key": "0x4cb42f213ed6dcfadb7b987fd31b2260334cbe404315708d17a2404fbadb11e",
                "token_a_balance": 7500000,
                "token_b_balance": 200000
            }
        }
    },
    "transactions": [
        {
            "taker_account_id": 0,
            "token_a_amount": 100000,
            "maker_account_id": 5,
            "token_b_amount": 10000,
        },
        {
            "taker_account_id": 5,
            "token_a_amount": 500000,
            "maker_account_id": 0,
            "token_b_amount": 30000,
        }
    ]
}
``` 
- generate transaction signatures: `python practices/fill_order/utils/gen_tx_signatures.py`
    - this will add "r_a", "s_a", "r_b" and "s_b" to `first_batch_input.json`
- run the program with first batch of transactions: `cairo-run --program=fill_order_compiled.json --print_output --layout=small --program_input=practices/fill_order/first_batch_input.json --cairo_pie_output practices/fill_order/fill_order_pie`
    - output should be:
    ```
    Taker (id: 0) swap 100000 token a for 10000 token b from maker (id: 5).
    Taker (id: 5) swap 500000 token a for 30000 token b from maker (id: 0).
    Program output:
        30
        90
        -1793547045450189420465008794399193691118550335168646972065475902807832761418
        -658335224952559810746362139420985511635567786865116305324955372878154660426
    ```
    - `30` and `90` are the fees collected
    - `-1793547045450189420465008794399193691118550335168646972065475902807832761418` is the pre state root
    - `-658335224952559810746362139420985511635567786865116305324955372878154660426` is the post state root
    - you can run `python practices/fill_order/utils/compute_root.py` and input `first_batch_input` to see the produced pre/post state tree roots
        - output should be:
        ```
        input file name: first_batch_input
        pre_state:
        tree root: 1824955743215941793232313988695876414504556880162949727907616153328039259063

        post_state:
        tree root: 2960167563713571402950960643674084593987539428466480394648136683257717360055
        ```
        - note that the pre state tree roots (`-1793547045450189420465008794399193691118550335168646972065475902807832761418 (mod p)` and `1824955743215941793232313988695876414504556880162949727907616153328039259063 (mod p)`) are the same
            - same for post state roots
        - this script will also generate a post state in `first_batch_input.json`, you can use this post state as the pre state for `second_batch_input.json` and add your transactions
    - `--cairo_pie_output` will output a cairo pie file which contains the information you need to generate proof
        - this pie file can be sent to SHARP with command `cairo-sharp submit --cairo_pie PIE_FILE_NAME`
    - you can run `python practices/fill_order/utils/compute_output_and_fact.py` to output program hash, program output and the fact for this round of execution
        - NOTE: program hash will be the same as long as the cairo program remains unchanged, however, fact will change based on the outputs each time
