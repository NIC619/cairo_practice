import sys

from starkware.cairo.common.hash_chain import compute_hash_chain
from starkware.cairo.lang.vm.crypto import pedersen_hash


def main():
    data = [1, 2, 3]
    res = compute_hash_chain(data)
    assert res == pedersen_hash(1, pedersen_hash(2, 3))
    print(f'result of hashchain {data}: {res}')

if __name__ == '__main__':
    sys.exit(main())