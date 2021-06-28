### Compile and run
- compile: `cairo-compile voting.cairo --output voting_compiled.json`
- gen first batch of votes: `python gen_votes.py`
- run the program w/ first batch of votes: `cairo-run --program=voting_compiled.json --print_output --layout=small --program_input=voting_input.json`
    - output should be:
    ```
    Program output:
    1
    2
    1591806306193441240739433996824056703232153712683022312894504906643112470393
    -1397522753299492751557547967820826962898231398543673030347416450104778351221
    ```
- gen second batch of votes: `python gen_next_batch_votes.py`
- run the program w/ second batch of votes: `cairo-run --program=voting_compiled.json --print_output --layout=small --program_input=voting_input2.json`
    - output should be:
    ```
    Program output:
    1
    0
    -1397522753299492751557547967820826962898231398543673030347416450104778351221
    -628706650786693403852552424323387050556189030546827265857028820447499605255
    ```