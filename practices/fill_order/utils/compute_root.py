import os
import json
import sys
import copy

DIR = os.path.dirname(__file__)

from starkware.cairo.lang.vm.crypto import pedersen_hash
from starkware.cairo.common.small_merkle_tree import MerkleTree

def state_transition(pre_state, transactions):
    accounts = pre_state["accounts"]
    for transaction in transactions:
        token_a_sender_id = str(transaction["token_a_sender_account_id"])
        token_a_send_amount = transaction["token_a_amount"]
        token_b_sender_id = str(transaction["token_b_sender_account_id"])
        token_b_send_amount = transaction["token_b_amount"]

        token_a_sender = accounts[token_a_sender_id]
        token_a_sender_balance = token_a_sender["token_a_balance"]
        assert token_a_sender_balance >= token_a_send_amount

        token_b_sender = accounts[token_b_sender_id]
        token_b_sender_balance = token_b_sender["token_b_balance"]
        assert token_b_sender_balance >= token_b_send_amount

        accounts[token_a_sender_id]["token_a_balance"] -= token_a_send_amount
        accounts[token_a_sender_id]["token_b_balance"] += token_b_send_amount
        accounts[token_b_sender_id]["token_a_balance"] += token_a_send_amount
        accounts[token_b_sender_id]["token_b_balance"] -= token_b_send_amount
    post_state = pre_state
    post_state["accounts"] = accounts
    return post_state

def hash_account(pub_key, balances):
    res = int(pub_key, 16)
    for balance in balances:
        res = pedersen_hash(res, balance)
    return res

def compute_account_id_and_hashes(accounts):
    account_ids = []
    account_hashes = []
    for acct_id, acct in accounts.items():
        account_ids.append(int(acct_id))
        balances = []
        balances.append(int(acct["token_a_balance"]))
        balances.append(int(acct["token_b_balance"]))
        # print(f'account id {acct_id}: {acct["public_key"]}, {balances}')
        account_hashes.append(hash_account(acct["public_key"], balances))
    # print(f'account hashes: {account_hashes}')
    return account_ids, account_hashes

def compute_merkle_root(account_ids, account_hashes):
    tree = MerkleTree(tree_height=10, default_leaf=0)
    account_hash_pairs = list(zip(account_ids, account_hashes))
    # print(f'account hash pairs: {account_hash_pairs}')
    print(f'tree root: {tree.compute_merkle_root(account_hash_pairs)}')

def main():
    file_name = input("input file name: ")
    file_path = os.path.join(DIR, "../" + file_name + ".json")
    input_data = json.load(open(file_path))
    pre_state = input_data["pre_state"]

    print("pre_state:")
    account_ids, account_hashes = compute_account_id_and_hashes(pre_state["accounts"])    
    compute_merkle_root(account_ids, account_hashes)

    transactions = input_data["transactions"]

    post_state = state_transition(copy.deepcopy(pre_state), transactions)

    print("\npost_state:")
    account_ids, account_hashes = compute_account_id_and_hashes(post_state["accounts"])    
    compute_merkle_root(account_ids, account_hashes)

    input_data["post_state"] = post_state
    with open(file_path, "w") as f:
        json.dump(input_data, f, indent=4)
        f.write("\n")

if __name__ == "__main__":
    sys.exit(main())