import os
import json
import sys

DIR = os.path.dirname(__file__)

from starkware.crypto.signature.signature import (
    pedersen_hash, sign)

def read_keys():
    file_name = "keys.json"
    file_path = os.path.join(DIR, file_name)
    return json.load(open(file_path))

def read_txs(file_name):
    file_path = os.path.join(DIR, file_name)
    input_data = json.load(open(file_path))
    return input_data["transactions"]

def compute_tx_hash(sender_a_id, a_amount, sender_b_id, b_amount):
    a_hash = pedersen_hash(int(sender_a_id), a_amount)
    b_hash = pedersen_hash(int(sender_b_id), b_amount)
    return pedersen_hash(a_hash, b_hash)

def main():
    keys = read_keys()
    file_name = input("input file name: ")
    file_path = os.path.join(DIR, "../" + file_name + ".json")
    input_data = json.load(open(file_path))
    txs = input_data["transactions"]

    for tx in txs:
        token_a_sender_id = str(tx["token_a_sender_account_id"])
        token_a_send_amount = tx["token_a_amount"]
        token_b_sender_id = str(tx["token_b_sender_account_id"])
        token_b_send_amount = tx["token_b_amount"]
        tx_hash = compute_tx_hash(
            token_a_sender_id,
            token_a_send_amount,
            token_b_sender_id,
            token_b_send_amount)

        r, s = sign(
            msg_hash=tx_hash,
            priv_key=keys[token_a_sender_id]["private_key"])
        tx["r_a"] = hex(r)
        tx["s_a"] = hex(s)

        r, s = sign(
            msg_hash=tx_hash,
            priv_key=keys[token_b_sender_id]["private_key"])
        tx["r_b"] = hex(r)
        tx["s_b"] = hex(s)

    input_data["transactions"] = txs
    with open(file_path, "w") as f:
        json.dump(input_data, f, indent=4)
        f.write("\n")

if __name__ == "__main__":
    sys.exit(main())