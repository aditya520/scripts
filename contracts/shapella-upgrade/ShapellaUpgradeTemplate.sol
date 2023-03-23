// SPDX-FileCopyrightText: 2023 Lido <info@lido.fi>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;


interface IAccessControlEnumerable {
    function grantRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
}

interface IVersioned {
    function getContractVersion() external view returns (uint256);
}

interface IPausableUntil {
    function isPaused() external view returns (bool);
    function getResumeSinceTimestamp() external view returns (uint256);
    function PAUSE_INFINITELY() external view returns (uint256);

    // The following methods actually belong to the oracle but are identical
    function PAUSE_ROLE() external view returns (bytes32);
    function RESUME_ROLE() external view returns (bytes32);
    function resume() external;
}

interface IOssifiableProxy {
    function proxy__upgradeTo(address newImplementation) external;
    function proxy__changeAdmin(address newAdmin) external;
    function proxy__getAdmin() external view returns (address);
    function proxy__getImplementation() external view returns (address);
}

interface IBaseOracle is IAccessControlEnumerable, IVersioned {
    function getConsensusContract() external view returns (address);
}

interface IAccountingOracle is IBaseOracle, IOssifiableProxy {
    function initialize(address admin, address consensusContract, uint256 consensusVersion) external;
}

interface IBurner is IAccessControlEnumerable {
    function REQUEST_BURN_SHARES_ROLE() external view returns (bytes32);
}

interface IDepositSecurityModule {
    function getOwner() external view returns (address);
    function setOwner(address newValue) external;
    function getGuardianQuorum() external view returns (uint256);
    function getGuardians() external view returns (address[] memory);
    function addGuardians(address[] memory addresses, uint256 newQuorum) external;
    function getMaxDeposits() external view returns (uint256);
    function getPauseIntentValidityPeriodBlocks() external view returns (uint256);
    function getMinDepositBlockDistance() external view returns (uint256);
}

interface IHashConsensus is IAccessControlEnumerable {
    function MANAGE_MEMBERS_AND_QUORUM_ROLE() external view returns (bytes32);
    function addMember(address addr, uint256 quorum) external;
    function getFrameConfig() external view returns (uint256 initialEpoch, uint256 epochsPerFrame, uint256 fastLaneLengthSlots);
    function updateInitialEpoch(uint256 initialEpoch) external;
}

interface ILido is IVersioned {
    function finalizeUpgrade_v2(address lidoLocator, address eip712StETH) external;
}

interface ILidoLocator is IOssifiableProxy {
    function accountingOracle() external view returns(address);
    function depositSecurityModule() external view returns(address);
    function elRewardsVault() external view returns(address);
    function legacyOracle() external view returns(address);
    function lido() external view returns(address);
    function oracleReportSanityChecker() external view returns(address);
    function burner() external view returns(address);
    function stakingRouter() external view returns(address);
    function treasury() external view returns(address);
    function validatorsExitBusOracle() external view returns(address);
    function withdrawalQueue() external view returns(address);
    function withdrawalVault() external view returns(address);
    function postTokenRebaseReceiver() external view returns(address);
    function oracleDaemonConfig() external view returns(address);
}

interface ILegacyOracle is IVersioned {
    function finalizeUpgrade_v4(address accountingOracle) external;
}

interface ILidoOracle {
    function getVersion() external view returns (uint256);
    function getOracleMembers() external view returns (address[] memory);
    function getQuorum() external view returns (uint256);
    function getLastCompletedEpochId() external view returns (uint256);
}

interface INodeOperatorsRegistry is IVersioned {
    function finalizeUpgrade_v2(address locator, bytes32 stakingModuleType, uint256 stuckPenaltyDelay) external;
}

interface IOracleDaemonConfig is IAccessControlEnumerable {
    function CONFIG_MANAGER_ROLE() external view returns (bytes32);
    function get(string calldata _key) external view returns (bytes memory);
}

interface IOracleReportSanityChecker is IAccessControlEnumerable {
    function ALL_LIMITS_MANAGER_ROLE() external view returns (bytes32);
    function CHURN_VALIDATORS_PER_DAY_LIMIT_MANGER_ROLE() external view returns (bytes32);
    function ONE_OFF_CL_BALANCE_DECREASE_LIMIT_MANAGER_ROLE() external view returns (bytes32);
    function ANNUAL_BALANCE_INCREASE_LIMIT_MANAGER_ROLE() external view returns (bytes32);
    function SHARE_RATE_DEVIATION_LIMIT_MANAGER_ROLE() external view returns (bytes32);
    function MAX_VALIDATOR_EXIT_REQUESTS_PER_REPORT_ROLE() external view returns (bytes32);
    function MAX_ACCOUNTING_EXTRA_DATA_LIST_ITEMS_COUNT_ROLE() external view returns (bytes32);
    function MAX_NODE_OPERATORS_PER_EXTRA_DATA_ITEM_COUNT_ROLE() external view returns (bytes32);
    function REQUEST_TIMESTAMP_MARGIN_MANAGER_ROLE() external view returns (bytes32);
    function MAX_POSITIVE_TOKEN_REBASE_MANAGER_ROLE() external view returns (bytes32);
}

interface IStakingRouter is IVersioned, IAccessControlEnumerable, IOssifiableProxy {
    function MANAGE_WITHDRAWAL_CREDENTIALS_ROLE() external view returns (bytes32);
    function STAKING_MODULE_PAUSE_ROLE() external view returns (bytes32);
    function STAKING_MODULE_RESUME_ROLE() external view returns (bytes32);
    function STAKING_MODULE_MANAGE_ROLE() external view returns (bytes32);
    function REPORT_EXITED_VALIDATORS_ROLE() external view returns (bytes32);
    function UNSAFE_SET_EXITED_VALIDATORS_ROLE() external view returns (bytes32);
    function REPORT_REWARDS_MINTED_ROLE() external view returns (bytes32);
    function initialize(address admin, address lido, bytes32 withdrawalCredentials) external;
    function addStakingModule(
        string calldata name,
        address stakingModuleAddress,
        uint256 targetShare,
        uint256 stakingModuleFee,
        uint256 treasuryFee
    ) external;
}

interface IValidatorsExitBusOracle is IBaseOracle, IPausableUntil, IOssifiableProxy {
    function initialize(address admin, address consensusContract, uint256 consensusVersion, uint256 lastProcessingRefSlot) external;
}


interface IWithdrawalQueue is IAccessControlEnumerable, IPausableUntil, IVersioned, IOssifiableProxy {
    function FINALIZE_ROLE() external view returns (bytes32);
    function ORACLE_ROLE() external view returns (bytes32);
    function initialize(address _admin) external;
}

interface IWithdrawalsManagerProxy {
    function proxy_getAdmin() external view returns (address);
    function implementation() external view returns (address);
}

interface IWithdrawalVault is IVersioned, IWithdrawalsManagerProxy {
    function initialize() external;
}

/**
* @title Shapella Lido Upgrade Template
*
* @dev Auxiliary contracts which performs binding of already deployed Shapella upgrade contracts.
* Must be used by means of two calls:
*   - `startUpgrade()` before updating implementation of Aragon apps
*   - `finishUpgrade()` after updating implementation of Aragon apps
* The required initial on-chain state is checked in `assertCorrectInitialState()`
*/
contract ShapellaUpgradeTemplate {

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    uint256 public constant NOT_INITIALIZED_CONTRACT_VERSION = 0;

    uint256 public constant _accountingOracleConsensusVersion = 1;
    uint256 public constant _validatorsExitBusOracleConsensusVersion = 1;
    string public constant NOR_STAKING_MODULE_NAME = "curated-onchain-v1";
    bytes32 public constant _nodeOperatorsRegistryStakingModuleType = bytes32("curated-onchain-v1");
    uint256 public constant _nodeOperatorsRegistryStuckPenaltyDelay = 172800;
    bytes32 public constant _withdrawalCredentials = 0x010000000000000000000000dc62f9e8c34be08501cdef4ebde0a280f576d762;
    uint256 public constant NOR_STAKING_MODULE_TARGET_SHARE_BP = 10000; // 100%
    uint256 public constant NOR_STAKING_MODULE_MODULE_FEE_BP = 500; // 5%
    uint256 public constant NOR_STAKING_MODULE_TREASURY_FEE_BP = 500; // 5%
    uint256 public constant VEBO_LAST_PROCESSING_REF_SLOT = 0;

    ILidoLocator public constant _locator = ILidoLocator(0x1eDf09b5023DC86737b59dE68a8130De878984f5);
    IHashConsensus public constant _hashConsensusForAccountingOracle = IHashConsensus(0x8EA83346E60261DdF1fA3B64056B096e337541b2);
    IHashConsensus public constant _hashConsensusForValidatorsExitBusOracle = IHashConsensus(0x8D4bCbc063da5A813FC13c3f4c817afcA7cb1eD6);
    address public constant _eip712StETH = 0xB4300103FfD326f77FfB3CA54248099Fb29C3b9e;
    address public constant _voting = 0xbc0B67b4553f4CF52a913DE9A6eD0057E2E758Db;
    address public constant _agent = 0x4333218072D5d7008546737786663c38B4D561A4;
    INodeOperatorsRegistry public constant _nodeOperatorsRegistry = INodeOperatorsRegistry(0x9D4AF1Ee19Dad8857db3a45B0374c81c8A1C6320);
    address public constant _gateSeal = 0x75A77AE52d88999D0b12C6e5fABB1C1ef7E92638;
    address public constant _withdrawalQueueImplementation = 0x265be9738fA32B29180867E07eaf1d6fa02a34dB;
    address public constant _stakingRouterImplementation = 0x249565350CcaD707bB68cE9980B366751649F4cd;
    address public constant _accountingOracleImplementation = 0x8C55A49639b456F98E1A8D7DAa3b29B378CADc8b;
    address public constant _validatorsExitBusOracleImplementation = 0x304F1B78B975AB79B479AdA70cE2Fc9A5a1A2a54;
    address public constant _dummyImplementation = 0x6A03b1BbB79460169a205eFBCBc77ebE1011bCf8;
    address public constant _locatorImplementation = 0xa55bBf0245890fC5F5A231778732b8966300a80e;
    address public constant _withdrawalVaultImplementation = 0x297Eb629655C8c488Eb26442cF4dfC8A7Cc32fFb;
    address public constant _previousDepositSecurityModule = 0x7DC1C1ff64078f73C98338e2f17D1996ffBb2eDe;

    uint256 public constant EXPECTED_FINAL_LIDO_VERSION = 2;
    uint256 public constant EXPECTED_FINAL_NODE_OPERATORS_REGISTRY_VERSION = 2;
    uint256 public constant EXPECTED_FINAL_LEGACY_ORACLE_VERSION = 4;
    uint256 public constant EXPECTED_FINAL_ACCOUNTING_ORACLE_VERSION = 1;
    uint256 public constant EXPECTED_FINAL_STAKING_ROUTER_VERSION = 1;
    uint256 public constant EXPECTED_FINAL_VALIDATORS_EXIT_BUS_ORACLE_VERSION = 1;
    uint256 public constant EXPECTED_FINAL_WITHDRAWAL_QUEUE_VERSION = 1;
    uint256 public constant EXPECTED_FINAL_WITHDRAWAL_VAULT_VERSION = 1;

    uint256 public constant EXPECTED_DSM_MAX_DEPOSITS_PER_BLOCK = 150;
    uint256 public constant EXPECTED_DSM_MIN_DEPOSIT_BLOCK_DISTANCE = 5;
    uint256 public constant EXPECTED_DSM_PAUSE_INTENT_VALIDITY_PERIOD_BLOCKS = 6646;

    //
    // STRUCTURED STORAGE
    //
    bool public isUpgradeStarted;
    bool public isUpgradeFinished;

    function assertCorrectInitialState() external view {
        _assertCorrectInitialState();
    }

    /// Need to be called before LidoOracle implementation is upgraded to LegacyOracle
    function startUpgrade() external {
        _startUpgrade();
    }

    function finishUpgrade() external {
        _finishUpgrade();
    }

    /// Perform basic checks to revert the entire upgrade if something gone wrong
    function assertUpgradeIsFinishedCorrectly() external view {
        _assertUpgradeIsFinishedCorrectly();
    }

    function revertIfUpgradeNotFinished() external view {
        if (!isUpgradeFinished) {
            revert UpgradeIsNotFinished();
        }
    }

    function _startUpgrade() internal {
        if (msg.sender != _voting) revert OnlyVotingCanUpgrade();
        if (isUpgradeStarted) revert CanOnlyStartOnce();
        isUpgradeStarted = true;

        _locator.proxy__upgradeTo(_locatorImplementation);

        _assertCorrectInitialState();

        // Upgrade proxy implementation
        _upgradeProxyImplementations();

        // Need to have the implementations already attached at this moment
        _assertCorrectInitialNonAdminRoleHolders();

        _withdrawalVault().initialize();

        _initializeWithdrawalQueue();

        _initializeAccountingOracle();

        _initializeValidatorsExitBus();

        _migrateLidoOracleCommitteeMembers();

        _initializeStakingRouter();

        _migrateDSMGuardians();

        // Need to have the implementations and proxy contracts initialize at this moment
        _assertProxyOZAccessControlContractsAdmin(address(this));
    }

    function _assertCorrectInitialState() internal view {
        if (ILidoOracle(address(_legacyOracle())).getVersion() != 3) revert LidoOracleMustNotBeUpgradedToLegacyYet();

        _assertAdminsOfProxies(address(this));
        if (_withdrawalVault().proxy_getAdmin() != _voting) revert WrongProxyAdmin(address(_withdrawalVault()));

        _assertInitialProxyImplementations();

        // Check roles of non-proxy contracts (can do without binding implementations)
        _assertNonProxyOZAccessControlContractsAdmin(address(this));

        if (_depositSecurityModule().getOwner() != address(this)) revert WrongDsmOwner();

        _assertSingleOZRoleHolder(_burner(), DEFAULT_ADMIN_ROLE, address(this));

        _assertOracleDaemonConfigInitialState();
        _assertOracleReportSanityCheckerInitialState();
        _assertCorrectDSMParameters();
    }

    function _assertCorrectDSMParameters() internal view {
        IDepositSecurityModule dsm = _depositSecurityModule();
        if (
            dsm.getMaxDeposits() != EXPECTED_DSM_MAX_DEPOSITS_PER_BLOCK
         || dsm.getPauseIntentValidityPeriodBlocks() != EXPECTED_DSM_PAUSE_INTENT_VALIDITY_PERIOD_BLOCKS
         || dsm.getMinDepositBlockDistance() != EXPECTED_DSM_MIN_DEPOSIT_BLOCK_DISTANCE
        ) {
            revert IncorrectDepositSecurityModuleParameters(address(dsm));
        }
    }

    function _upgradeProxyImplementations() internal {
        _accountingOracle().proxy__upgradeTo(_accountingOracleImplementation);
        _validatorsExitBusOracle().proxy__upgradeTo(_validatorsExitBusOracleImplementation);
        _stakingRouter().proxy__upgradeTo(_stakingRouterImplementation);
        _withdrawalQueue().proxy__upgradeTo(_withdrawalQueueImplementation);
    }

    function _assertNonProxyOZAccessControlContractsAdmin(address admin) internal view {
        _assertSingleOZRoleHolder(_hashConsensusForAccountingOracle, DEFAULT_ADMIN_ROLE, admin);
        _assertSingleOZRoleHolder(_hashConsensusForValidatorsExitBusOracle, DEFAULT_ADMIN_ROLE, admin);
        _assertSingleOZRoleHolder(_burner(), DEFAULT_ADMIN_ROLE, admin);
    }

    function _assertProxyOZAccessControlContractsAdmin(address admin) internal view {
        _assertSingleOZRoleHolder(_accountingOracle(), DEFAULT_ADMIN_ROLE, admin);
        _assertSingleOZRoleHolder(_stakingRouter(), DEFAULT_ADMIN_ROLE, admin);
        _assertSingleOZRoleHolder(_validatorsExitBusOracle(), DEFAULT_ADMIN_ROLE, admin);
        _assertSingleOZRoleHolder(_withdrawalQueue(), DEFAULT_ADMIN_ROLE, admin);
    }

    function _assertAdminsOfProxies(address admin) internal view {
        _assertProxyAdmin(_accountingOracle(), admin);
        _assertProxyAdmin(_locator, admin);
        _assertProxyAdmin(_stakingRouter(), admin);
        _assertProxyAdmin(_validatorsExitBusOracle(), admin);
        _assertProxyAdmin(_withdrawalQueue(), admin);
    }

    function _assertProxyAdmin(IOssifiableProxy proxy, address admin) internal view {
        if (proxy.proxy__getAdmin() != admin) revert WrongProxyAdmin(address(proxy));
    }

    function _assertOracleReportSanityCheckerInitialState() internal view {
        IOracleReportSanityChecker checker = _oracleReportSanityChecker();
        _assertSingleOZRoleHolder(checker, DEFAULT_ADMIN_ROLE, _agent);
        _assertZeroRoleHolders(checker, checker.ALL_LIMITS_MANAGER_ROLE());
        _assertZeroRoleHolders(checker, checker.CHURN_VALIDATORS_PER_DAY_LIMIT_MANGER_ROLE());
        _assertZeroRoleHolders(checker, checker.ONE_OFF_CL_BALANCE_DECREASE_LIMIT_MANAGER_ROLE());
        _assertZeroRoleHolders(checker, checker.ANNUAL_BALANCE_INCREASE_LIMIT_MANAGER_ROLE());
        _assertZeroRoleHolders(checker, checker.SHARE_RATE_DEVIATION_LIMIT_MANAGER_ROLE());
        _assertZeroRoleHolders(checker, checker.MAX_VALIDATOR_EXIT_REQUESTS_PER_REPORT_ROLE());
        _assertZeroRoleHolders(checker, checker.MAX_ACCOUNTING_EXTRA_DATA_LIST_ITEMS_COUNT_ROLE());
        _assertZeroRoleHolders(checker, checker.MAX_NODE_OPERATORS_PER_EXTRA_DATA_ITEM_COUNT_ROLE());
        _assertZeroRoleHolders(checker, checker.REQUEST_TIMESTAMP_MARGIN_MANAGER_ROLE());
        _assertZeroRoleHolders(checker, checker.MAX_POSITIVE_TOKEN_REBASE_MANAGER_ROLE());
    }

    function _assertOracleDaemonConfigInitialState() internal view {
        IOracleDaemonConfig config = _oracleDaemonConfig();
        _assertSingleOZRoleHolder(config, DEFAULT_ADMIN_ROLE, _agent);
        _assertZeroRoleHolders(config, config.CONFIG_MANAGER_ROLE());

    }

    function _assertInitialProxyImplementations() internal view {
        if (_withdrawalVault().implementation() != _withdrawalVaultImplementation) revert WrongInitialImplementation(address(_withdrawalVault()));
        _assertInitialDummyImplementation(_accountingOracle());
        _assertInitialDummyImplementation(_stakingRouter());
        _assertInitialDummyImplementation(_validatorsExitBusOracle());
        _assertInitialDummyImplementation(_withdrawalQueue());
    }

    function _assertInitialDummyImplementation(IOssifiableProxy proxy) internal view {
        if (proxy.proxy__getImplementation() != _dummyImplementation) revert WrongInitialImplementation(address(proxy));
    }

    function _assertSingleOZRoleHolder(IAccessControlEnumerable accessControlled, bytes32 role, address holder) internal view {
        if (accessControlled.getRoleMemberCount(role) != 1
         || accessControlled.getRoleMember(role, 0) != holder
        ) {
            revert WrongSingleRoleHolder(address(accessControlled), role);
        }
    }

    function _assertCorrectInitialNonAdminRoleHolders() internal view {
        _assertSingleOZRoleHolder(_burner(), _burner().REQUEST_BURN_SHARES_ROLE(), address(_lido()));

        _assertZeroRoleHolders(_accountingOracle(), DEFAULT_ADMIN_ROLE);

        _assertZeroRoleHolders(_stakingRouter(), DEFAULT_ADMIN_ROLE);
        _assertZeroRoleHolders(_stakingRouter(), _stakingRouter().STAKING_MODULE_PAUSE_ROLE());
        _assertZeroRoleHolders(_stakingRouter(), _stakingRouter().STAKING_MODULE_RESUME_ROLE());
        _assertZeroRoleHolders(_stakingRouter(), _stakingRouter().REPORT_EXITED_VALIDATORS_ROLE());
        _assertZeroRoleHolders(_stakingRouter(), _stakingRouter().REPORT_REWARDS_MINTED_ROLE());

        _assertZeroRoleHolders(_validatorsExitBusOracle(), DEFAULT_ADMIN_ROLE);
        _assertZeroRoleHolders(_validatorsExitBusOracle(), _validatorsExitBusOracle().PAUSE_ROLE());

        _assertZeroRoleHolders(_withdrawalQueue(), DEFAULT_ADMIN_ROLE);
        _assertZeroRoleHolders(_withdrawalQueue(), _withdrawalQueue().PAUSE_ROLE());
        _assertZeroRoleHolders(_withdrawalQueue(), _withdrawalQueue().FINALIZE_ROLE());
        _assertZeroRoleHolders(_withdrawalQueue(), _withdrawalQueue().ORACLE_ROLE());
    }

    function _assertZeroRoleHolders(IAccessControlEnumerable accessControlled, bytes32 role) internal view {
        if (accessControlled.getRoleMemberCount(role) != 0) {
            revert NonZeroRoleHolders(address(accessControlled), role);
        }
    }

    function _initializeAccountingOracle() internal {
        (, uint256 epochsPerFrame, ) = _hashConsensusForAccountingOracle.getFrameConfig();
        uint256 lastLidoOracleCompletedEpochId = _lidoOracle().getLastCompletedEpochId();

        // NB: HashConsensus.updateInitialEpoch must be called after AccountingOracle implementation is bound to proxy
        _hashConsensusForAccountingOracle.updateInitialEpoch(lastLidoOracleCompletedEpochId + epochsPerFrame);
        _accountingOracle().initialize(
            address(this),
            address(_hashConsensusForAccountingOracle),
            _accountingOracleConsensusVersion
        );
    }

    function _initializeWithdrawalQueue() internal {
        IWithdrawalQueue wq = _withdrawalQueue();
        wq.initialize(address(this));
        _resumePausableContract(address(wq));
        wq.grantRole(wq.PAUSE_ROLE(), _gateSeal);
        wq.grantRole(wq.FINALIZE_ROLE(), address(_lido()));
        wq.grantRole(wq.ORACLE_ROLE(), address(_accountingOracle()));
    }

    function _initializeStakingRouter() internal {
        IStakingRouter sr = _stakingRouter();
        sr.initialize(address(this), address(_lido()), _withdrawalCredentials);
        sr.grantRole(sr.STAKING_MODULE_PAUSE_ROLE(), address(_depositSecurityModule()));
        sr.grantRole(sr.STAKING_MODULE_RESUME_ROLE(), address(_depositSecurityModule()));
        sr.grantRole(sr.REPORT_EXITED_VALIDATORS_ROLE(), address(_accountingOracle()));
        sr.grantRole(sr.REPORT_REWARDS_MINTED_ROLE(), address(_lido()));
    }

    function _initializeValidatorsExitBus() internal {
        IValidatorsExitBusOracle vebo = _validatorsExitBusOracle();
        // TODO: ?
        // _hashConsensusForValidatorsExitBusOracle.updateInitialEpoch(lastLidoOracleCompletedEpochId + epochsPerFrame);
        vebo.initialize(
            address(this),
            address(_hashConsensusForValidatorsExitBusOracle),
            _validatorsExitBusOracleConsensusVersion,
            VEBO_LAST_PROCESSING_REF_SLOT
        );
        _resumePausableContract(address(vebo));
        vebo.grantRole(vebo.PAUSE_ROLE(), _gateSeal);
    }

    function _migrateLidoOracleCommitteeMembers() internal {
        address[] memory members = _lidoOracle().getOracleMembers();
        uint256 quorum = _lidoOracle().getQuorum();
        bytes32 manage_members_role = _hashConsensusForAccountingOracle.MANAGE_MEMBERS_AND_QUORUM_ROLE();

        _hashConsensusForAccountingOracle.grantRole(manage_members_role, address(this));
        _hashConsensusForValidatorsExitBusOracle.grantRole(manage_members_role, address(this));
        for (uint256 i; i < members.length; ++i) {
            _hashConsensusForAccountingOracle.addMember(members[i], quorum);
            _hashConsensusForValidatorsExitBusOracle.addMember(members[i], quorum);
        }
        _hashConsensusForAccountingOracle.renounceRole(manage_members_role, address(this));
        _hashConsensusForValidatorsExitBusOracle.renounceRole(manage_members_role, address(this));
    }

    function _migrateDSMGuardians() internal {
        IDepositSecurityModule previousDSM = IDepositSecurityModule(_previousDepositSecurityModule);
        address[] memory guardians = previousDSM.getGuardians();
        uint256 quorum = previousDSM.getGuardianQuorum();
        _depositSecurityModule().addGuardians(guardians, quorum);
    }

    function _finishUpgrade() internal {
        if (msg.sender != _voting) revert OnlyVotingCanUpgrade();
        if (!isUpgradeStarted) revert StartMustBeCalledBeforeFinish();
        if (isUpgradeFinished) revert CanOnlyFinishOnce();
        /// Here we check that the contract got new ABI function getContractVersion(), although it is 0 yet
        /// because in the new contract version is stored in a different slot
        if (_legacyOracle().getContractVersion() != NOT_INITIALIZED_CONTRACT_VERSION) {
            revert LidoOracleMustBeUpgradedToLegacy();
        }
        isUpgradeFinished = true;

        _legacyOracle().finalizeUpgrade_v4(address(_accountingOracle()));

        _lido().finalizeUpgrade_v2(address(_locator), _eip712StETH);

        _nodeOperatorsRegistry.finalizeUpgrade_v2(
            address(_locator),
            _nodeOperatorsRegistryStakingModuleType,
            _nodeOperatorsRegistryStuckPenaltyDelay
        );

        _attachNORToStakingRouter();

        _passAdminRoleFromTemplateToAgent();

        _assertUpgradeIsFinishedCorrectly();
    }

    function _attachNORToStakingRouter() internal {
        bytes32 sm_manage_role = _stakingRouter().STAKING_MODULE_MANAGE_ROLE();
        _stakingRouter().grantRole(sm_manage_role, address(this));
        _stakingRouter().addStakingModule(
            NOR_STAKING_MODULE_NAME,
            address(_nodeOperatorsRegistry),
            NOR_STAKING_MODULE_TARGET_SHARE_BP,
            NOR_STAKING_MODULE_MODULE_FEE_BP,
            NOR_STAKING_MODULE_TREASURY_FEE_BP
        );
        _stakingRouter().renounceRole(sm_manage_role, address(this));
    }

    function _passAdminRoleFromTemplateToAgent() internal {
        _transferOZAdminFromThisToAgent(_hashConsensusForValidatorsExitBusOracle);
        _transferOZAdminFromThisToAgent(_hashConsensusForAccountingOracle);
        _transferOZAdminFromThisToAgent(_burner());
        _transferOZAdminFromThisToAgent(_stakingRouter());
        _transferOZAdminFromThisToAgent(_accountingOracle());
        _transferOZAdminFromThisToAgent(_validatorsExitBusOracle());
        _transferOZAdminFromThisToAgent(_withdrawalQueue());

        _locator.proxy__changeAdmin(_agent);
        _stakingRouter().proxy__changeAdmin(_agent);
        _accountingOracle().proxy__changeAdmin(_agent);
        _validatorsExitBusOracle().proxy__changeAdmin(_agent);
        _withdrawalQueue().proxy__changeAdmin(_agent);

        _depositSecurityModule().setOwner(_agent);
    }

    function _assertUpgradeIsFinishedCorrectly() internal view {
        _checkContractVersions();

        _assertAdminsOfProxies(_agent);

        _assertProxyOZAccessControlContractsAdmin(_agent);
        _assertNonProxyOZAccessControlContractsAdmin(_agent);

        _assertCorrectOracleAndConsensusContractsBinding(_accountingOracle(), _hashConsensusForAccountingOracle);
        _assertCorrectOracleAndConsensusContractsBinding(_validatorsExitBusOracle(), _hashConsensusForValidatorsExitBusOracle);

        // TODO: maybe check non admin roles if enough contract bytecode size?

        if (_depositSecurityModule().getOwner() != _agent) revert WrongDsmOwner();

        if (_withdrawalQueue().isPaused()) revert WQNotResumed();
        if (_validatorsExitBusOracle().isPaused()) revert VEBONotResumed();
    }

    function _assertCorrectOracleAndConsensusContractsBinding(IBaseOracle oracle, IHashConsensus hashConsensus) internal view {
        if (oracle.getConsensusContract() != address(hashConsensus)) {
            revert IncorrectOracleAndHashConsensusBinding(address(oracle), address(hashConsensus));
        }
        // TODO: check the binding in opposite direction when the view is added to HashConsensus
    }

    function _checkContractVersions() internal view {
        _assertContractVersion(_lido(), EXPECTED_FINAL_LIDO_VERSION);
        _assertContractVersion(_nodeOperatorsRegistry, EXPECTED_FINAL_NODE_OPERATORS_REGISTRY_VERSION);
        _assertContractVersion(_legacyOracle(), EXPECTED_FINAL_LEGACY_ORACLE_VERSION);
        _assertContractVersion(_accountingOracle(), EXPECTED_FINAL_ACCOUNTING_ORACLE_VERSION);
        _assertContractVersion(_stakingRouter(), EXPECTED_FINAL_STAKING_ROUTER_VERSION);
        _assertContractVersion(_validatorsExitBusOracle(), EXPECTED_FINAL_VALIDATORS_EXIT_BUS_ORACLE_VERSION);
        _assertContractVersion(_withdrawalQueue(), EXPECTED_FINAL_WITHDRAWAL_QUEUE_VERSION);
        _assertContractVersion(_withdrawalVault(), EXPECTED_FINAL_WITHDRAWAL_VAULT_VERSION);
    }

    function _assertContractVersion(IVersioned versioned, uint256 expectedVersion) internal view {
        if (versioned.getContractVersion() != expectedVersion) {
            revert InvalidContractVersion(address(versioned), expectedVersion);
        }
    }

    function _transferOZAdminFromThisToAgent(IAccessControlEnumerable accessControlled) internal {
        accessControlled.grantRole(DEFAULT_ADMIN_ROLE, _agent);
        accessControlled.renounceRole(DEFAULT_ADMIN_ROLE, address(this));
    }

    function _resumePausableContract(address contractAddress) internal {
        bytes32 resume_role = IPausableUntil(contractAddress).RESUME_ROLE();

        IAccessControlEnumerable(contractAddress).grantRole(resume_role, address(this));
        IPausableUntil(contractAddress).resume();
        IAccessControlEnumerable(contractAddress).renounceRole(resume_role, address(this));
    }

    function _accountingOracle() internal view returns (IAccountingOracle) {
        return IAccountingOracle(_locator.accountingOracle());
    }

    function _burner() internal view returns (IBurner) {
        return IBurner(_locator.burner());
    }

    function _depositSecurityModule() internal view returns (IDepositSecurityModule) {
        return IDepositSecurityModule(_locator.depositSecurityModule());
    }

    function _lido() internal view returns (ILido) {
        return ILido(_locator.lido());
    }

    // Returns the same address as _legacyOracle()
    function _lidoOracle() internal view returns (ILidoOracle) {
        return ILidoOracle(_locator.legacyOracle());
    }

    // Returns the same address as _lidoOracle()
    function _legacyOracle() internal view returns (ILegacyOracle) {
        return ILegacyOracle(_locator.legacyOracle());
    }

    function _oracleDaemonConfig() internal view returns (IOracleDaemonConfig) {
        return IOracleDaemonConfig(_locator.oracleDaemonConfig());
    }

    function _oracleReportSanityChecker() internal view returns (IOracleReportSanityChecker) {
        return IOracleReportSanityChecker(_locator.oracleReportSanityChecker());
    }

    function _stakingRouter() internal view returns (IStakingRouter) {
        return IStakingRouter(_locator.stakingRouter());
    }

    function _validatorsExitBusOracle() internal view returns (IValidatorsExitBusOracle) {
        return IValidatorsExitBusOracle(_locator.validatorsExitBusOracle());
    }

    function _withdrawalQueue() internal view returns (IWithdrawalQueue) {
        return IWithdrawalQueue(_locator.withdrawalQueue());
    }

    function _withdrawalVault() internal view returns (IWithdrawalVault) {
        return IWithdrawalVault(_locator.withdrawalVault());
    }

    error OnlyVotingCanUpgrade();
    error CanOnlyStartOnce();
    error CanOnlyFinishOnce();
    error StartMustBeCalledBeforeFinish();
    error UpgradeIsNotFinished();
    error LidoOracleMustNotBeUpgradedToLegacyYet();
    error LidoOracleMustBeUpgradedToLegacy();
    error WrongDsmOwner();
    error WrongProxyAdmin(address proxy);
    error WrongInitialImplementation(address proxy);
    error InvalidContractVersion(address contractAddress, uint256 actualVersion);
    error WrongOZAccessControlAdmin(address contractAddress);
    error WrongSingleRoleHolder(address contractAddress, bytes32 role);
    error NonZeroRoleHolders(address contractAddress, bytes32 role);
    error WQNotResumed();
    error VEBONotResumed();
    error IncorrectOracleAndHashConsensusBinding(address oracle, address hashConsensus);
    error IncorrectDepositSecurityModuleParameters(address _depositSecurityModule);
}
