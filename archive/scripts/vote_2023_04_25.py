"""
Voting 25/04/2023.

1. Increase Easy Track motions amount limit: set motionsCountLimit to 20
2. Change the on-chain name of node operator with id 1 from 'Certus One' to 'jumpcrypto'
3. Change the on-chain name of node operator with id 21 from 'ConsenSys Codefi' to 'Consensys'
4. Change the on-chain name of node operator with id 8 from 'SkillZ' to 'Kiln'
5. Change the reward address of node operator with id 8 from 0xe080E860741b7f9e8369b61645E68AD197B1e74C to 0xD6B7d52E15678B9195F12F3a6D6cb79dcDcCb690

The vote REJECTED.
"""

import time

from typing import Dict, Tuple, Optional, List

from brownie import interface
from brownie.network.transaction import TransactionReceipt
from utils.voting import bake_vote_items, confirm_vote_script, create_vote

from utils.config import (
    get_deployer_account,
    lido_dao_node_operators_registry,
)
from utils.node_operators import (
    encode_set_node_operator_name,
    encode_set_node_operator_reward_address
)

from utils.easy_track import (
    set_motions_count_limit
)


def start_vote(tx_params: Dict[str, str], silent: bool = False) -> Tuple[int, Optional[TransactionReceipt]]:
    """Prepare and run voting."""

    motionsCountLimit = 20

    NO_registry = interface.NodeOperatorsRegistry(lido_dao_node_operators_registry)

    CertusOne_Jumpcrypto_id = 1
    CertusOne_Jumpcrypto_new_name = "jumpcrypto"

    ConsenSysCodefi_Consensys_id = 21
    ConsenSysCodefi_Consensys_new_name = "Consensys"

    SkillZ_Kiln_id = 8
    SkillZ_Kiln_new_name = "Kiln"
    SkillZ_Kiln_new_address = "0xD6B7d52E15678B9195F12F3a6D6cb79dcDcCb690"

    call_script_items = [
        # 1. Increase Easy Track motions amount limit: set motionsCountLimit to 20
        set_motions_count_limit(motionsCountLimit),
        # 2. Change the on-chain name of node operator with id 1 from 'Certus One' to 'jumpcrypto'
        encode_set_node_operator_name(CertusOne_Jumpcrypto_id, CertusOne_Jumpcrypto_new_name, NO_registry),
        # 3. Change the on-chain name of node operator with id 21 from 'ConsenSys Codefi' to 'Consensys'
        encode_set_node_operator_name(ConsenSysCodefi_Consensys_id, ConsenSysCodefi_Consensys_new_name, NO_registry),
        # 4. Change the on-chain name of node operator with id 8 from 'SkillZ' to 'Kiln'
        encode_set_node_operator_name(SkillZ_Kiln_id, SkillZ_Kiln_new_name, NO_registry),
        # 5. Change the reward address of node operator with id 8 from 0xe080E860741b7f9e8369b61645E68AD197B1e74C to 0xD6B7d52E15678B9195F12F3a6D6cb79dcDcCb690
        encode_set_node_operator_reward_address(SkillZ_Kiln_id, SkillZ_Kiln_new_address, NO_registry)
    ]

    vote_desc_items = [
        "1) Increase Easy Track motions amount limit: set motionsCountLimit to 20",
        "2) Change the on-chain name of node operator with id 1 from 'Certus One' to 'jumpcrypto'",
        "3) Change the on-chain name of node operator with id 21 from 'ConsenSys Codefi' to 'Consensys'",
        "4) Change the on-chain name of node operator with id 8 from 'SkillZ' to 'Kiln'",
        "5) Change the reward address of node operator with id 8 from 0xe080E860741b7f9e8369b61645E68AD197B1e74C to 0xD6B7d52E15678B9195F12F3a6D6cb79dcDcCb690",
    ]

    vote_items = bake_vote_items(vote_desc_items, call_script_items)

    return confirm_vote_script(vote_items, silent) and create_vote(vote_items, tx_params)


def main():
    vote_id, _ = start_vote({"from": get_deployer_account(), "priority_fee": "4 gwei"})

    vote_id >= 0 and print(f"Vote created: {vote_id}.")

    time.sleep(5)  # hack for waiting thread #2.
