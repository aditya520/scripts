import pytest

from brownie import chain, ZERO_ADDRESS

from typing import NewType, Tuple
from utils.config import contracts
from utils.test.oracle_report_helpers import ONE_DAY, SHARE_RATE_PRECISION, oracle_report
from utils.import_current_votes import is_there_any_vote_scripts, start_and_execute_votes
from utils.test.helpers import ETH

from utils.test.extra_data import (
    ExtraDataService,
)

StakingModuleId = NewType("StakingModuleId", int)
NodeOperatorId = NewType("NodeOperatorId", int)
NodeOperatorGlobalIndex = Tuple[StakingModuleId, NodeOperatorId]

def node_operator_gindex(module_id, node_operator_id) -> NodeOperatorGlobalIndex:
    return module_id, node_operator_id

@pytest.fixture(scope="module", autouse=is_there_any_vote_scripts())
def autoexecute_vote(helpers, vote_ids_from_env, accounts):
    if vote_ids_from_env:
        helpers.execute_votes(accounts, vote_ids_from_env, contracts.voting, topup="0.5 ether")
    else:
        start_and_execute_votes(contracts.voting, helpers)


@pytest.fixture()
def steth_holder(accounts):
    whale = "0x176F3DAb24a159341c0509bB36B833E7fdd0a132"
    contracts.lido.transfer(accounts[0], ETH(101), {"from": whale})
    return accounts[0]
