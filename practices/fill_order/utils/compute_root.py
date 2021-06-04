import os
import json
import sys
import copy

DIR = os.path.dirname(__file__)

from starkware.cairo.lang.vm.crypto import pedersen_hash
from starkware.cairo.common.small_merkle_tree import MerkleTree

BPS = 10000
FEE_BPS = 30

def state_transition(pre_state, transactions):
    accounts = pre_state["accounts"]
    fee = pre_state["fee"]
    for transaction in transactions:
        taker_id = str(transaction["taker_account_id"])
        token_a_send_amount = transaction["token_a_amount"]
        maker_id = str(transaction["maker_account_id"])
        token_b_send_amount = transaction["token_b_amount"]

        taker = accounts[taker_id]
        taker_balance = taker["token_a_balance"]
        assert taker_balance >= token_a_send_amount

        maker = accounts[maker_id]
        maker_balance = maker["token_b_balance"]
        assert maker_balance >= token_b_send_amount

        fee_b_amount = (token_b_send_amount * FEE_BPS) // BPS
        
        accounts[taker_id]["token_a_balance"] -= token_a_send_amount
        accounts[taker_id]["token_b_balance"] += (token_b_send_amount - fee_b_amount)
        accounts[maker_id]["token_a_balance"] += token_a_send_amount
        accounts[maker_id]["token_b_balance"] -= token_b_send_amount
        fee["token_b_balance"] += fee_b_amount
    post_state = pre_state
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