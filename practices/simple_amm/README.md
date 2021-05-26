### Compile and run
- compile: `cairo-compile main.cairo --output amm_compiled.json`
- run the program: `cairo-run --program=amm_compiled.json --print_output --layout=small --program_input=amm_input.json`
    - output should be:
    ```
    Swap: Account 5 gave 10 tokens of type token_a and received 90 tokens of type token_b.
    Swap: Account 0 gave 10 tokens of type token_a and received 75 tokens of type token_b.
    Program output:
        100
        1000
        120
        835
        1525995302570384126242713246787576393592941654328044962264804620003580146919
        1134357528922022223420621430912271931318105966572115905728401979526314542570
    ```
