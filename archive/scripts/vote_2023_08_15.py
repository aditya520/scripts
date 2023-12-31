"""
Voting {id} 15/08/2023 for IPFS description upload (test net only)
Vote {rejected | passed & executed} on ${date+time}, block ${blockNumber}
"""

import time

from typing import Dict

from brownie.network.transaction import TransactionReceipt
from brownie import web3  # type: ignore

from utils.voting import bake_vote_items, confirm_vote_script, create_vote

from utils.config import (
    get_deployer_account,
    get_is_live,
    get_priority_fee,
    contracts,
)

from utils.easy_track import set_motions_count_limit
from utils.ipfs import upload_vote_ipfs_description, calculate_vote_ipfs_description

description = """
**Motion 1:** RockLogic Slashing Incident Staker Compensation for smth, [snapshot passed](https://www.notion.so/Bug-Bounty-github-docs-link-to-compromised-github-account-719b3f2b628346db86ce9b23c36b02ee?pvs=21) data.

Specification

1. Transfer **13.45978634** stETH from Insurance fund to Agent
2. Set **13.45978634** stETH as the allowance of Burner over the Agent's tokens
3. Grant `REQUEST_BURN_MY_STETH_ROLE` to Agent
4. Request to burn **13.45978634** stETH for cover
5. Renounce `REQUEST_BURN_MY_STETH_ROLE` from Agent

 **Motion 2:** Add stETH Gas Supply factories

Specification

6. Add Gas Supply top up EVM script factory for stETH `0x200dA0b6a9905A377CF8D469664C65dB267009d1`
7. Add Gas Supply add recipient EVM script factory for stETH `0x48c135Ff690C2Aa7F5B11C539104B5855A4f9252`
8. Add Gas Supply remove recipient EVM script factory for stETH `0x7E8eFfAb3083fB26aCE6832bFcA4C377905F97d7`

format examples:
CID with MD - `bafkreif6kvb3yxbhqrlgwf6jp2hegt6qg3f5a4m2njgiro7ynn5n4ynlza`
CID without MD - bafkreif6kvb3yxbhqrlgwf6jp2hegt6qg3f5a4m2njgiro7ynn5n4ynlza or bafkreif6kvb3yxbhqrlgwf6jp2hegt6qg3f5a4m2njgiro7ynn5n4ynlzb

address with MD - `0x200dA0b6a9905A377CF8D469664C65dB267009d1`
address without MD - 0x200dA0b6a9905A377CF8D469664C65dB267009d1 or 0x200dA0b6a9905A377CF8D469664C65dB267009d2

👉 This vote was created only to show how to use the new beautiful description.
⚠️ This vote change Easy Track motions amount to the same amount. Description is only for example.

"""


def start_vote(tx_params: Dict[str, str], silent: bool) -> bool | list[int | TransactionReceipt | None]:
    """Prepare and run voting."""

    easy_track = contracts.easy_track
    motions_count_limit = easy_track.motionsCountLimit()

    call_script_items = [
        # Set max EasyTrack motions limit to 21
        set_motions_count_limit(motions_count_limit),
    ]

    vote_desc_items = [
        f"1) Set exact same Easy Track motions amount limit: set motionsCountLimit to {motions_count_limit}",
    ]

    vote_items = bake_vote_items(vote_desc_items, call_script_items)

    if silent:
        desc_ipfs = calculate_vote_ipfs_description(description)
    else:
        desc_ipfs = upload_vote_ipfs_description(description)

    return confirm_vote_script(vote_items, silent, desc_ipfs) and list(
        create_vote(vote_items, tx_params, desc_ipfs=desc_ipfs)
    )


def main():
    tx_params = {"from": get_deployer_account()}
    if get_is_live():
        tx_params["priority_fee"] = get_priority_fee()

    vote_id, _ = start_vote(tx_params=tx_params, silent=False)

    vote_id >= 0 and print(f"Vote created: {vote_id}.")

    time.sleep(5)  # hack for waiting thread #2.
