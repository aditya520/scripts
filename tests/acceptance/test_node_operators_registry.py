import pytest
from brownie import ZERO_ADDRESS, interface, web3, reverts  # type: ignore

from utils.config import (
    contracts,
    NODE_OPERATORS_REGISTRY,
    NODE_OPERATORS_REGISTRY_IMPL,
    NODE_OPERATORS_REGISTRY_ARAGON_APP_ID,
    CURATED_STAKING_MODULE_STUCK_PENALTY_DELAY,
    CURATED_STAKING_MODULE_OPERATORS_COUNT,
    CURATED_STAKING_MODULE_OPERATORS_ACTIVE_COUNT,
    CURATED_STAKING_MODULE_TYPE,
)


@pytest.fixture(scope="module")
def contract() -> interface.NodeOperatorsRegistry:
    return interface.NodeOperatorsRegistry(NODE_OPERATORS_REGISTRY)


def test_links(contract):
    assert contract.getLocator() == contracts.lido_locator


def test_aragon(contract):
    proxy = interface.AppProxyUpgradeable(contract)
    assert proxy.implementation() == NODE_OPERATORS_REGISTRY_IMPL
    assert contract.kernel() == contracts.kernel
    assert contract.appId() == NODE_OPERATORS_REGISTRY_ARAGON_APP_ID
    assert contract.hasInitialized() == True
    assert contract.isPetrified() == False


def test_role_keccaks(contract):
    assert contract.MANAGE_SIGNING_KEYS() == web3.keccak(text="MANAGE_SIGNING_KEYS").hex()
    assert contract.SET_NODE_OPERATOR_LIMIT_ROLE() == web3.keccak(text="SET_NODE_OPERATOR_LIMIT_ROLE").hex()
    assert contract.MANAGE_NODE_OPERATOR_ROLE() == web3.keccak(text="MANAGE_NODE_OPERATOR_ROLE").hex()
    assert contract.STAKING_ROUTER_ROLE() == web3.keccak(text="STAKING_ROUTER_ROLE").hex()


def test_versioned(contract):
    assert contract.getContractVersion() == 2


def test_initialize(contract):
    with reverts("INIT_ALREADY_INITIALIZED"):
        contract.initialize(
            contracts.lido_locator,
            CURATED_STAKING_MODULE_TYPE,
            CURATED_STAKING_MODULE_STUCK_PENALTY_DELAY,
            {"from": contracts.voting},
        )


def test_finalize_upgrade(contract):
    with reverts("UNEXPECTED_CONTRACT_VERSION"):
        contract.finalizeUpgrade_v2(
            contracts.lido_locator,
            CURATED_STAKING_MODULE_TYPE,
            CURATED_STAKING_MODULE_STUCK_PENALTY_DELAY,
            {"from": contracts.voting},
        )


def test_petrified():
    contract = interface.NodeOperatorsRegistry(NODE_OPERATORS_REGISTRY_IMPL)
    with reverts("INIT_ALREADY_INITIALIZED"):
        contract.initialize(
            contracts.lido_locator,
            CURATED_STAKING_MODULE_TYPE,
            CURATED_STAKING_MODULE_STUCK_PENALTY_DELAY,
            {"from": contracts.voting},
        )

    with reverts("CONTRACT_NOT_INITIALIZED"):
        contract.finalizeUpgrade_v2(
            contracts.lido_locator,
            CURATED_STAKING_MODULE_TYPE,
            CURATED_STAKING_MODULE_STUCK_PENALTY_DELAY,
            {"from": contracts.voting},
        )


def test_nor_state(contract):
    node_operators_count = contract.getNodeOperatorsCount()
    assert node_operators_count == CURATED_STAKING_MODULE_OPERATORS_COUNT
    assert contract.getActiveNodeOperatorsCount() == CURATED_STAKING_MODULE_OPERATORS_ACTIVE_COUNT
    assert contract.getNonce() >= 7315
    assert contract.getStuckPenaltyDelay() == CURATED_STAKING_MODULE_STUCK_PENALTY_DELAY
    assert contract.getType() == _str_to_bytes32("curated-onchain-v1")

    summary = contract.getStakingModuleSummary()
    assert summary["totalExitedValidators"] >= 145
    assert summary["totalDepositedValidators"] >= 177397
    assert summary["depositableValidatorsCount"] > 0

    for id in range(node_operators_count):
        assert contract.getTotalSigningKeyCount(id) > 0
        node_operator = contract.getNodeOperator(id, True)

        assert node_operator["active"] == True
        assert node_operator["name"] is not None
        assert node_operator["name"] != ""
        assert node_operator["rewardAddress"] != ZERO_ADDRESS

        assert node_operator["totalVettedValidators"] > 0

        assert node_operator["totalVettedValidators"] <= node_operator["totalAddedValidators"]
        # counts could inc but not dec
        if id == 2:
            assert node_operator["totalExitedValidators"] == 252
        elif id == 4:
            assert node_operator["totalExitedValidators"] == 174
        elif id == 5:
            assert node_operator["totalExitedValidators"] == 36
        elif id == 12:
            assert node_operator["totalExitedValidators"] == 2300
        elif id == 21:
            assert node_operator["totalExitedValidators"] == 125
        elif id == 22:
            assert node_operator["totalExitedValidators"] == 11
        else:
            assert node_operator["totalExitedValidators"] == 0, f"totalExitedValidators is positive for node {id}"

        assert node_operator["totalAddedValidators"] > 0

        assert node_operator["totalDepositedValidators"] > 0

        assert node_operator["totalDepositedValidators"] <= node_operator["totalAddedValidators"]

        node_operator_summary = contract.getNodeOperatorSummary(id)
        exited_node_operators = [12]  # vote 23-05-23
        if id in exited_node_operators:
            assert (
                node_operator_summary["isTargetLimitActive"] is True
            ), f"isTargetLimitActive is inactive for node {id}"
        else:
            assert node_operator_summary["isTargetLimitActive"] is False, f"isTargetLimitActive is active for node {id}"
        assert node_operator_summary["targetValidatorsCount"] == 0
        assert node_operator_summary["stuckValidatorsCount"] == 0
        assert node_operator_summary["refundedValidatorsCount"] == 0
        assert node_operator_summary["stuckPenaltyEndTimestamp"] == 0
        # counts could inc but not dec
        if id == 2:
            assert node_operator_summary["totalExitedValidators"] == 252
        elif id == 4:
            assert node_operator_summary["totalExitedValidators"] == 174
        elif id == 5:
            assert node_operator_summary["totalExitedValidators"] == 36
        elif id == 12:
            assert node_operator_summary["totalExitedValidators"] == 2300
        elif id == 21:
            assert node_operator_summary["totalExitedValidators"] == 125
        elif id == 22:
            assert node_operator_summary["totalExitedValidators"] == 11
        else:
            assert (
                node_operator_summary["totalExitedValidators"] == 0
            ), f"totalExitedValidators is positive for node {id}"

        assert node_operator_summary["totalDepositedValidators"] > 0
        assert node_operator_summary["depositableValidatorsCount"] is not None


def _str_to_bytes32(s: str) -> str:
    return "0x{:0<64}".format(s.encode("utf-8").hex())
