## StarkWare Cairo lang practice

### Setup
Ref: [Cairo doc - Setting up the environment](https://www.cairo-lang.org/docs/quickstart.html)

- install python3.7 (using virtual env or not)
- install prerequesite libraries: `sudo apt install -y libgmp3-dev`(ubuntu) or `brew install gmp`(mac)
- install python packages: `pip3 install ecdsa fastecdsa sympy`
    - **NOTE**: Cairo was tested with python3.7. To make it work with python3.6, you will have to install contextvars: `pip3 install contextvars`
- download [Cairo python package](https://github.com/starkware-libs/cairo-lang/releases/tag/v0.2.0) and install via `pip3 install cairo-lang-0.2.0.zip`

### Compile and run

#### 1. StarkNet contracts
- create a cairo file `test.cairo`
- compile: `starknet-compile test.cairo --output test_compiled.json --abi=test_compiled_abi.json`
- deploy the contract: `starknet deploy --contract test_compiled.json --network=alpha`
- query tx status: `starknet tx_status --id=XXXXX --network=alpha`
- query storage in contract: `starknet call --address=0xabcdef...... --abi test_compiled_abi.json --function get_XXX`
- invoke the contract: `starknet invoke --address=0xabcdef...... --abi test_compiled_abi.json --function do_XXX --inputs A B C --network=alpha`

#### 2. Cairo
- create a cairo file `test.cairo`
- compile: `cairo-compile test.cairo --output test_compiled.json`
- run the program: `cairo-run --program=test_compiled.json --print_output --print_info --relocate_prints`
    - tracer can be enabled by adding `--tracer` flag to `cairo_run`, after tracer is enabled, open `http://localhost:8100/` in browser