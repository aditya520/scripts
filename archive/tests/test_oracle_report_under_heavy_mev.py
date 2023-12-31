import math
import pytest
from brownie import interface, chain
from scripts.vote_2022_11_10 import start_vote

from utils.config import contracts, lido_dao_execution_layer_rewards_vault


LIDO_EXECUTION_LAYER_REWARDS_VAULT = lido_dao_execution_layer_rewards_vault
TOTAL_BASIS_POINTS = 10000
EL_REWARDS_FEE_WITHDRAWAL_LIMIT = 2


@pytest.fixture(scope="module")
def stranger(accounts):
    return accounts[0]


@pytest.fixture(scope="module")
def eth_whale(accounts):
    return accounts.at("0x00000000219ab540356cBB839Cbe05303d7705Fa", force=True)


@pytest.fixture(scope="module")
def lido_oracle():
    return contracts.lido_oracle


@pytest.fixture(scope="module")
def lido_execution_layer_rewards_vault():
    return interface.LidoExecutionLayerRewardsVault(LIDO_EXECUTION_LAYER_REWARDS_VAULT)


@pytest.fixture(scope="module", autouse=True)
def autoexecute_vote(vote_id_from_env, helpers, accounts, dao_voting, ldo_holder):
    # START VOTE
    vote_id: int = vote_id_from_env or start_vote({"from": ldo_holder}, silent=True)[0]

    helpers.execute_vote(vote_id=vote_id, accounts=accounts, dao_voting=dao_voting, skip_time=3 * 60 * 60 * 24)


def test_report_beacon_with_el_rewards(
    lido,
    lido_oracle,
    lido_execution_layer_rewards_vault,
    eth_whale,
):
    el_reward = 1_000_000 * 10**18
    beacon_balance_delta = 500 * 10**18

    el_balance_before = lido_execution_layer_rewards_vault.balance()
    # prepare EL rewards
    eth_whale.transfer(lido_execution_layer_rewards_vault, el_reward)
    el_balance_after = lido_execution_layer_rewards_vault.balance()
    assert (el_balance_after - el_balance_before) == el_reward

    epochsPerFrame, _, _, _ = lido_oracle.getBeaconSpec()

    print(f" Oracle report after the break")
    expectedEpoch = lido_oracle.getExpectedEpochId()
    # we waited 3 days for voting to be executed so we need to shift epochId on 3 frames
    expectedEpoch += epochsPerFrame * 3  # 3 days for the voting

    prev_report = lido.getBeaconStat().dict()
    beacon_validators = prev_report["beaconValidators"]
    beacon_balance = prev_report["beaconBalance"] + beacon_balance_delta
    buffered_ether_before = lido.getBufferedEther()
    tvl_before = lido.getTotalPooledEther()
    max_allowed_el_reward = (
        (tvl_before + beacon_balance_delta) * lido.getELRewardsWithdrawalLimit() // TOTAL_BASIS_POINTS
    )
    before_share_price = lido.getPooledEthByShares(10**27)

    reporters = lido_oracle.getOracleMembers()
    quorum = lido_oracle.getQuorum()

    for reporter in reporters[:quorum]:
        lido_oracle.reportBeacon(expectedEpoch, beacon_balance // 10**9, beacon_validators, {"from": reporter})

    assert lido.getBufferedEther() == buffered_ether_before + max_allowed_el_reward
    # see LidoOracle.sol#690
    assert (
        lido.getTotalPooledEther() - tvl_before
    ) * 10000 * 365 <= lido_oracle.getAllowedBeaconBalanceAnnualRelativeIncrease() * 10000 * 365 * tvl_before
    after_share_price = lido.getPooledEthByShares(10**27)
    real_change = (after_share_price / before_share_price - 1.0) * 10000.0
    # 2.75bp on rebase
    assert math.isclose(1115 / 365 * 0.9, real_change, rel_tol=1e-2, abs_tol=0.0), "unexpected change"

    for days in range(1, 10):
        print(f" Following oracle reports: {days}")
        chain.sleep(24 * 60 * 60)
        chain.mine()
        expectedEpoch = lido_oracle.getExpectedEpochId()

        prev_report = lido.getBeaconStat().dict()
        beacon_balance = prev_report["beaconBalance"] + beacon_balance_delta
        buffered_ether_before = lido.getBufferedEther()
        tvl_before = lido.getTotalPooledEther()
        max_allowed_el_reward = (
            (tvl_before + beacon_balance_delta) * lido.getELRewardsWithdrawalLimit() // TOTAL_BASIS_POINTS
        )
        before_share_price = lido.getPooledEthByShares(10**27)

        reporters = lido_oracle.getOracleMembers()
        quorum = lido_oracle.getQuorum()

        for reporter in reporters[:quorum]:
            lido_oracle.reportBeacon(expectedEpoch, beacon_balance // 10**9, beacon_validators, {"from": reporter})

        assert lido.getBufferedEther() == buffered_ether_before + max_allowed_el_reward
        # see LidoOracle.sol#690
        assert (
            lido.getTotalPooledEther() - tvl_before
        ) * 10000 * 365 <= lido_oracle.getAllowedBeaconBalanceAnnualRelativeIncrease() * 10000 * 365 * tvl_before
        after_share_price = lido.getPooledEthByShares(10**27)
        real_change = (after_share_price / before_share_price - 1.0) * 10000.0
        # 2.75bp on rebase
        assert math.isclose(1115 / 365 * 0.9, real_change, rel_tol=1e-2, abs_tol=0.0), "unexpected change"
