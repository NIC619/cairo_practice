## StarkWare Cairo lang practice

### Setup
Ref: [Cairo doc - Setting up the environment](https://www.cairo-lang.org/docs/quickstart.html)

- install python3.7 (using virtual env or not)
- install prerequesite libraries: `sudo apt install -y libgmp3-dev`(ubuntu) or `brew install gmp`(mac)
- install python packages: `pip3 install ecdsa fastecdsa sympy`
    - **NOTE**: Cairo was tested with python3.7. To make it work with python3.6, you will have to install contextvars: `pip3 install contextvars`
- download [Cairo python package](https://github.com/starkware-libs/cairo-lang/releases/tag/v0.1.0) and install via `pip3 install cairo-lang-0.1.0.zip`

### Compile and run
- create a cairo file `test.cairo`
- compile: `cairo-compile test.cairo --output test_compiled.json`
- run the program: `cairo-run --program=test_compiled.json --print_output --print_info --relocate_prints`
    - tracer can be enabled by adding `--tracer` flag to `cairo_run`, after tracer is enabled, open `http://localhost:8100/` in browser