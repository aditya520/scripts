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

interface IAragonAppRepo {
    function getLatest() external view returns (uint16[3] memory, address, bytes memory);
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

interface IGateSeal {
    function get_sealables() external view returns (address[] memory);
}

interface IHashConsensus is IAccessControlEnumerable {
    /// @notice An ACL role granting the permission to modify members list members and
    /// change the quorum by calling addMember, removeMember, and setQuorum functions.
    function MANAGE_MEMBERS_AND_QUORUM_ROLE() external view returns (bytes32);


    /// @notice Returns the time-related configuration.
    ///
    /// @return initialEpoch Epoch of the frame with zero index.
    /// @return epochsPerFrame Length of a frame in epochs.
    /// @return fastLaneLengthSlots Length of the fast lane interval in slots; see `getIsFastLaneMember`.
    ///
    function getFrameConfig() external view returns (uint256 initialEpoch, uint256 epochsPerFrame, uint256 fastLaneLengthSlots);

    function updateInitialEpoch(uint256 initialEpoch) external;
    function addMember(address addr, uint256 quorum) external;
    function getReportProcessor() external view returns (address);
}

interface ILido is IVersioned {
    function finalizeUpgrade_v2(address lidoLocator, address eip712StETH) external;

    /**
     * @notice Returns current fee distribution
     * @dev DEPRECATED: Now fees information is stored in StakingRouter and
     * with higher precision. Use StakingRouter.getStakingFeeAggregateDistribution() instead.
     * @return treasuryFeeBasisPoints return treasury fee in TOTAL_BASIS_POINTS (10000 is 100% fee) precision
     * @return insuranceFeeBasisPoints always returns 0 because the capability to send fees to
     * insurance from Lido contract is removed.
     * @return operatorsFeeBasisPoints return total fee for all operators of all staking modules in
     * TOTAL_BASIS_POINTS (10000 is 100% fee) precision.
     * Previously returned total fee of all node operators of NodeOperatorsRegistry (Curated staking module now)
     * The value might be inaccurate because the actual value is truncated here to 1e4 precision.
     */
    function getFeeDistribution() external view
        returns (uint16 treasuryFeeBasisPoints, uint16 insuranceFeeBasisPoints, uint16 operatorsFeeBasisPoints);

    function getFee() external view returns (uint16 totalFee);
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
    /**
     * @notice A function to finalize upgrade v3 -> v4 (the compat-only deprecated impl).
     * Can be called only once.
     */
    function finalizeUpgrade_v4(address accountingOracle) external;
}

interface ILidoOracle {
    function getVersion() external view returns (uint256);

    /**
     * @notice Return the current oracle member committee list
     */
    function getOracleMembers() external view returns (address[] memory);

    /**
     * @notice Return the number of exactly the same reports needed to finalize the epoch
     */
    function getQuorum() external view returns (uint256);

    /**
     * @notice Return last completed epoch
     */
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
    function getOracleReportLimits() external view returns (LimitsList memory);
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

    /**
     * @dev Returns true if staking module with the given id was registered via `addStakingModule`, false otherwise
     */
    function hasStakingModule(uint256 _stakingModuleId) external view returns (bool);

    /**
     * @dev Returns total number of staking modules
     */
    function getStakingModulesCount() external view returns (uint256);

    function getStakingModule(uint256 _stakingModuleId) external view returns (StakingModule memory);
}

interface IValidatorsExitBusOracle is IBaseOracle, IPausableUntil, IOssifiableProxy {
    function initialize(address admin, address consensusContract, uint256 consensusVersion, uint256 lastProcessingRefSlot) external;

    /// @notice An ACL role granting the permission to pause accepting validator exit requests
    function PAUSE_ROLE() external view returns (bytes32);

    /// @notice An ACL role granting the permission to resume accepting validator exit requests
    function RESUME_ROLE() external view returns (bytes32);

    /// @notice Resume accepting validator exit requests
    ///
    /// @dev Reverts with `PausedExpected()` if contract is already resumed
    /// @dev Reverts with `AccessControl:...` reason if sender has no `RESUME_ROLE`
    ///
    function resume() external;
}

interface IWithdrawalQueue is IAccessControlEnumerable, IPausableUntil, IVersioned, IOssifiableProxy {
    function FINALIZE_ROLE() external view returns (bytes32);
    function ORACLE_ROLE() external view returns (bytes32);
    function PAUSE_ROLE() external view returns (bytes32);
    function RESUME_ROLE() external view returns (bytes32);

    /// @notice Initialize the contract storage explicitly.
    /// @param _admin admin address that can change every role.
    /// @dev Reverts if `_admin` equals to `address(0)`
    /// @dev NB! It's initialized in paused state by default and should be resumed explicitly to start
    /// @dev NB! Bunker mode is disabled by default
    function initialize(address _admin) external;

    /// @notice Resume withdrawal requests placement and finalization
    function resume() external;
}

interface IWithdrawalsManagerProxy {
    function proxy_getAdmin() external view returns (address);
    function implementation() external view returns (address);
}

interface IWithdrawalVault is IVersioned, IWithdrawalsManagerProxy {
    /**
     * @notice Initialize the contract explicitly.
     * Sets the contract version to '1'.
     */
    function initialize() external;
}

struct LimitsList {
    /// @notice The max possible number of validators that might appear or exit on the Consensus
    ///     Layer during one day
    /// @dev Must fit into uint16 (<= 65_535)
    uint256 churnValidatorsPerDayLimit;

    /// @notice The max decrease of the total validators' balances on the Consensus Layer since
    ///     the previous oracle report
    /// @dev Represented in the Basis Points (100% == 10_000)
    uint256 oneOffCLBalanceDecreaseBPLimit;

    /// @notice The max annual increase of the total validators' balances on the Consensus Layer
    ///     since the previous oracle report
    /// @dev Represented in the Basis Points (100% == 10_000)
    uint256 annualBalanceIncreaseBPLimit;

    /// @notice The max deviation of the provided `simulatedShareRate`
    ///     and the actual one within the currently processing oracle report
    /// @dev Represented in the Basis Points (100% == 10_000)
    uint256 simulatedShareRateDeviationBPLimit;

    /// @notice The max number of exit requests allowed in report to ValidatorsExitBusOracle
    uint256 maxValidatorExitRequestsPerReport;

    /// @notice The max number of data list items reported to accounting oracle in extra data
    /// @dev Must fit into uint16 (<= 65_535)
    uint256 maxAccountingExtraDataListItemsCount;

    /// @notice The max number of node operators reported per extra data list item
    /// @dev Must fit into uint16 (<= 65_535)
    uint256 maxNodeOperatorsPerExtraDataItemCount;

    /// @notice The min time required to be passed from the creation of the request to be
    ///     finalized till the time of the oracle report
    uint256 requestTimestampMargin;

    /// @notice The positive token rebase allowed per single LidoOracle report
    /// @dev uses 1e9 precision, e.g.: 1e6 - 0.1%; 1e9 - 100%, see `setMaxPositiveTokenRebase()`
    uint256 maxPositiveTokenRebase;
}

enum StakingModuleStatus {
    Active, // deposits and rewards allowed
    DepositsPaused, // deposits NOT allowed, rewards allowed
    Stopped // deposits and rewards NOT allowed
}

struct StakingModule {
    /// @notice unique id of the staking module
    uint24 id;
    /// @notice address of staking module
    address stakingModuleAddress;
    /// @notice part of the fee taken from staking rewards that goes to the staking module
    uint16 stakingModuleFee;
    /// @notice part of the fee taken from staking rewards that goes to the treasury
    uint16 treasuryFee;
    /// @notice target percent of total validators in protocol, in BP
    uint16 targetShare;
    /// @notice staking module status if staking module can not accept the deposits or can participate in further reward distribution
    uint8 status;
    /// @notice name of staking module
    string name;
    /// @notice block.timestamp of the last deposit of the staking module
    /// @dev NB: lastDepositAt gets updated even if the deposit value was 0 and no actual deposit happened
    uint64 lastDepositAt;
    /// @notice block.number of the last deposit of the staking module
    /// @dev NB: lastDepositBlock gets updated even if the deposit value was 0 and no actual deposit happened
    uint256 lastDepositBlock;
    /// @notice number of exited validators
    uint256 exitedValidatorsCount;
}

/**
* @title Shapella Lido Upgrade Template
*
* @dev Auxiliary contracts which performs binding of already deployed Shapella upgrade contracts.
* Must be used by means of two calls:
*   - `startUpgrade()` before updating implementation of Aragon apps
*   - `finishUpgrade()` after updating implementation of Aragon apps
* The required initial on-chain state is checked in `startUpgrade()`
*/
contract ShapellaUpgradeTemplate {

    event UpgradeStarted();
    event UpgradeFinished();

    // New proxies
    ILidoLocator public constant _locator = ILidoLocator(0xd75C357F32Df60A67111BAa62a168c0D644d1C32);
    IAccountingOracle public constant _accountingOracle = IAccountingOracle(0x9FE21EeCC385a1FeE057E58427Bfb9588E249231);
    address public constant _eip712StETH = 0x8dF3c29C96fd4c4d496954646B8B6a48dFFcA83F;
    INodeOperatorsRegistry public constant _nodeOperatorsRegistry = INodeOperatorsRegistry(0x55032650b14df07b85bF18A3a3eC8E0Af2e028d5);
    IStakingRouter public constant _stakingRouter = IStakingRouter(0x5A2a6cB5e0f57A30085A9411f7F5f07be8ad1Ec7);
    IValidatorsExitBusOracle public constant _validatorsExitBusOracle = IValidatorsExitBusOracle(0x6e7Da71eF6E0Aaa85E59554C1FAe44128fA649Ed);
    IWithdrawalQueue public constant _withdrawalQueue = IWithdrawalQueue(0xFb4E291D12734af4300B89585A16dF932160b840);

    // New non-proxy contracts
    IHashConsensus public constant _hashConsensusForAccountingOracle = IHashConsensus(0x379EBeeD117c96380034c6a6234321e4e64fCa0B);
    IHashConsensus public constant _hashConsensusForValidatorsExitBusOracle = IHashConsensus(0x2330b9F113784a58d74c7DB49366e9FB792DeABf);
    // TODO: update gateSeal address
    address public constant _gateSeal = 0x0000000000000000000000000000000000000001;
    IBurner public constant _burner = IBurner(0xFc810b3F9acc7ee0C3820B5f7a9bb0ee88C3cBd2);
    IDepositSecurityModule public constant _depositSecurityModule = IDepositSecurityModule(0xe44E11BBb629Dc23e72e6eAC4e538AaCb66A0c88);
    IOracleDaemonConfig public constant _oracleDaemonConfig = IOracleDaemonConfig(0xbA3981771AB991960028B2F83ae83664Fd003F61);
    IOracleReportSanityChecker public constant _oracleReportSanityChecker = IOracleReportSanityChecker(0x499A11A07ebe21685953583B6DA9f237E792aEE3);

    // New implementations
    address public constant _withdrawalVaultImplementation = 0x654f166BA493551899212917d8eAa30CE977b794;
    address public constant _withdrawalQueueImplementation = 0x5EfF11Cb6bD446370FC3ce46019F2b501ba06c2D;
    address public constant _stakingRouterImplementation = 0x4384fB5DcaC0576B93e36b8af6CdfEB739888894;
    address public constant _accountingOracleImplementation = 0x115065ad19aDae715576b926CF6e26067F64e741;
    address public constant _validatorsExitBusOracleImplementation = 0xfdfad30ae5e5c9Dc4fb51aC35AB60674FcBdefB3;
    address public constant _dummyImplementation = 0xE2f969983c8859E986d6e19892EDBd1eea7371D2;
    address public constant _locatorImplementation = 0x7948f9cf80D99DDb7C7258Eb23a693E9dFBc97EC;

    // Existing proxies and contracts
    address public constant _agent = 0x3e40D73EB977Dc6a537aF587D48316feE66E9C8c;
    IAragonAppRepo public constant _aragonAppLidoRepo = IAragonAppRepo(0xF5Dc67E54FC96F993CD06073f71ca732C1E654B1);
    IAragonAppRepo public constant _aragonAppNodeOperatorsRegistryRepo = IAragonAppRepo(0x0D97E876ad14DB2b183CFeEB8aa1A5C788eB1831);
    IAragonAppRepo public constant _aragonAppLegacyOracleRepo = IAragonAppRepo(0xF9339DE629973c60c4d2b76749c81E6F40960E3A);
    ILido public constant _lido = ILido(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);
    ILidoOracle public constant _lidoOracle = ILidoOracle(0x442af784A788A5bd6F42A01Ebe9F287a871243fb);
    // _legacyOracle has the same address as _lidoOracle: we're renaming the contract, but it's on the same address
    ILegacyOracle public constant _legacyOracle = ILegacyOracle(address(_lidoOracle));
    address public constant _previousDepositSecurityModule = 0x710B3303fB508a84F10793c1106e32bE873C24cd;
    address public constant _voting = 0x2e59A20f205bB85a89C53f1936454680651E618e;
    IWithdrawalVault public constant _withdrawalVault = IWithdrawalVault(0xB9D7934878B5FB9610B3fE8A5e441e8fad7E293f);

    // Aragon Apps new implementations
    address public constant _lidoImplementation = 0xAb3bcE27F31Ca36AAc6c6ec2bF3e79569105ec2c;
    address public constant _legacyOracleImplementation = 0xcA3cE6bf0CB2bbaC5dF3874232AE3F5b67C6b146;
    address public constant _nodeOperatorsRegistryImplementation = 0x9cBbA6CDA09C7dadA8343C4076c21eE06CCa4836;

    // Values to set
    uint256 public constant ACCOUNTING_ORACLE_CONSENSUS_VERSION = 1;
    string public constant NOR_STAKING_MODULE_NAME = "curated-onchain-v1";
    bytes32 public constant NODE_OPERATORS_REGISTRY_STAKING_MODULE_TYPE = bytes32("curated-onchain-v1");
    uint256 public constant NODE_OPERATORS_REGISTRY_STUCK_PENALTY_DELAY = 172800;
    bytes32 public constant WITHDRAWAL_CREDENTIALS = 0x010000000000000000000000b9d7934878b5fb9610b3fe8a5e441e8fad7e293f;
    uint256 public constant NOR_STAKING_MODULE_ID = 1;
    uint256 public constant NOR_STAKING_MODULE_TARGET_SHARE_BP = 10000; // 100%
    uint256 public constant NOR_STAKING_MODULE_MODULE_FEE_BP = 500; // 5%
    uint256 public constant NOR_STAKING_MODULE_TREASURY_FEE_BP = 500; // 5%
    uint256 public constant VEBO_LAST_PROCESSING_REF_SLOT = 0;
    uint256 public constant VALIDATORS_EXIT_BUS_ORACLE_CONSENSUS_VERSION = 1;

    //
    // Values for checks to compare with or other
    //
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    uint256 public constant NOT_INITIALIZED_CONTRACT_VERSION = 0;
    uint256 public constant TOTAL_BASIS_POINTS = 10000;

    uint256 public constant EXPECTED_FINAL_LIDO_VERSION = 2;
    uint256 public constant EXPECTED_FINAL_NODE_OPERATORS_REGISTRY_VERSION = 2;
    uint256 public constant EXPECTED_FINAL_LEGACY_ORACLE_VERSION = 4;
    uint256 public constant EXPECTED_FINAL_ACCOUNTING_ORACLE_VERSION = 1;
    uint256 public constant EXPECTED_FINAL_STAKING_ROUTER_VERSION = 1;
    uint256 public constant EXPECTED_FINAL_VALIDATORS_EXIT_BUS_ORACLE_VERSION = 1;
    uint256 public constant EXPECTED_FINAL_WITHDRAWAL_QUEUE_VERSION = 1;
    uint256 public constant EXPECTED_FINAL_WITHDRAWAL_VAULT_VERSION = 1;

    uint256 public constant EXPECTED_DSM_MAX_DEPOSITS_PER_BLOCK = 150;
    uint256 public constant EXPECTED_DSM_MIN_DEPOSIT_BLOCK_DISTANCE = 25;
    uint256 public constant EXPECTED_DSM_PAUSE_INTENT_VALIDITY_PERIOD_BLOCKS = 6646;

    uint256 public constant SANITY_LIMIT_churnValidatorsPerDayLimit = 12375;
    uint256 public constant SANITY_LIMIT_oneOffCLBalanceDecreaseBPLimit = 500;
    uint256 public constant SANITY_LIMIT_annualBalanceIncreaseBPLimit = 1000;
    uint256 public constant SANITY_LIMIT_simulatedShareRateDeviationBPLimit = 10;
    uint256 public constant SANITY_LIMIT_maxValidatorExitRequestsPerReport = 500;
    uint256 public constant SANITY_LIMIT_maxAccountingExtraDataListItemsCount = 500;
    uint256 public constant SANITY_LIMIT_maxNodeOperatorsPerExtraDataItemCount = 100;
    uint256 public constant SANITY_LIMIT_requestTimestampMargin = 7680;
    uint256 public constant SANITY_LIMIT_maxPositiveTokenRebase = 750000;

    string public constant NORMALIZED_CL_REWARD_PER_EPOCH_KEY = "NORMALIZED_CL_REWARD_PER_EPOCH";
    bytes public constant NORMALIZED_CL_REWARD_PER_EPOCH_VALUE = hex"40";
    string public constant NORMALIZED_CL_REWARD_MISTAKE_RATE_BP_KEY = "NORMALIZED_CL_REWARD_MISTAKE_RATE_BP";
    bytes public constant NORMALIZED_CL_REWARD_MISTAKE_RATE_BP_VALUE = hex"03e8";
    string public constant REBASE_CHECK_NEAREST_EPOCH_DISTANCE_KEY = "REBASE_CHECK_NEAREST_EPOCH_DISTANCE";
    bytes public constant REBASE_CHECK_NEAREST_EPOCH_DISTANCE_VALUE = hex"04";
    string public constant REBASE_CHECK_DISTANT_EPOCH_DISTANCE_KEY = "REBASE_CHECK_DISTANT_EPOCH_DISTANCE";
    bytes public constant REBASE_CHECK_DISTANT_EPOCH_DISTANCE_VALUE = hex"0a";
    string public constant VALIDATOR_DELAYED_TIMEOUT_IN_SLOTS_KEY = "VALIDATOR_DELAYED_TIMEOUT_IN_SLOTS";
    bytes public constant VALIDATOR_DELAYED_TIMEOUT_IN_SLOTS_VALUE = hex"1c20";
    string public constant VALIDATOR_DELINQUENT_TIMEOUT_IN_SLOTS_KEY = "VALIDATOR_DELINQUENT_TIMEOUT_IN_SLOTS";
    bytes public constant VALIDATOR_DELINQUENT_TIMEOUT_IN_SLOTS_VALUE = hex"5460";
    string public constant PREDICTION_DURATION_IN_SLOTS_KEY = "PREDICTION_DURATION_IN_SLOTS";
    bytes public constant PREDICTION_DURATION_IN_SLOTS_VALUE = hex"c4e0";
    string public constant FINALIZATION_MAX_NEGATIVE_REBASE_EPOCH_SHIFT_KEY = "FINALIZATION_MAX_NEGATIVE_REBASE_EPOCH_SHIFT";
    bytes public constant FINALIZATION_MAX_NEGATIVE_REBASE_EPOCH_SHIFT_VALUE = hex"0546";
    string public constant NODE_OPERATOR_NETWORK_PENETRATION_THRESHOLD_BP_KEY = "NODE_OPERATOR_NETWORK_PENETRATION_THRESHOLD_BP";
    bytes public constant NODE_OPERATOR_NETWORK_PENETRATION_THRESHOLD_BP_VALUE = hex"64";

    // Immutables
    // Timestamp since startUpgrade() and finishUpgrade() act as no-ops
    uint256 public EXPIRES_SINCE_INCLUSIVE;

    //
    // Structured storage
    //
    bool public _isUpgradeStarted;
    bool public _isUpgradeFinished;

    constructor(uint256 expiresSinceInclusive) {
        if (expiresSinceInclusive <= block.timestamp) revert ExpireSinceMustBeInFuture();

        EXPIRES_SINCE_INCLUSIVE = expiresSinceInclusive;
    }

    /// Need to be called before LidoOracle implementation is upgraded to LegacyOracle
    function startUpgrade() external {
        if (_isExpired()) return;

        _startUpgrade();
    }

    /// Need to be called after LidoOracle implementation is upgraded to LegacyOracle
    function finishUpgrade() external {
        if (_isExpired()) return;

        _finishUpgrade();
    }

    /// Perform basic checks to revert the entire upgrade if something gone wrong
    function assertUpgradeIsFinishedCorrectly() external view {
        _assertUpgradeIsFinishedCorrectly();
    }

    /// Needed for 2nd Aragon voting (roles revoke) to fail if 1st voting isn't enacted
    function revertIfUpgradeNotEnacted() external view {
        if (!_isUpgradeFinished) {
            revert UpgradeNotEnacted();
        }
    }

    function _startUpgrade() internal {
        if (msg.sender != _voting) revert OnlyVotingCanUpgrade();
        if (_isUpgradeStarted) revert CanOnlyStartOnce();
        if (_lidoOracle.getVersion() != EXPECTED_FINAL_LEGACY_ORACLE_VERSION - 1) {
            revert LidoOracleMustNotBeUpgradedToLegacyYet();
        }
        _assertInitialProxyImplementations();

        _isUpgradeStarted = true;

        _upgradeProxyImplementations();

        // Need to have the implementations attached to the proxies to perform part of the inner checks

        _assertInitialACL();
        // Check initial version of feeDistribution() before Lido implementation updated
        _assertFeeDistribution();

        // Both rely on the old LidoOracle contract, so must be performed before update to the LegacyOracle impl
        _migrateLidoOracleCommitteeMembers();
        _initializeAccountingOracle();
    }

    function _assertInitialACL() internal view {
        if (_withdrawalVault.proxy_getAdmin() != _voting) revert WrongProxyAdmin(address(_withdrawalVault));
        _assertAdminsOfProxies(address(this));

        if (_depositSecurityModule.getOwner() != address(this)) revert WrongDsmOwner();

        _assertOracleDaemonConfigRoles();
        _assertOracleReportSanityCheckerRoles();

        _assertSingleOZRoleHolder(_burner, DEFAULT_ADMIN_ROLE, address(this));
        _assertSingleOZRoleHolder(_burner, _burner.REQUEST_BURN_SHARES_ROLE(), address(_lido));

        _assertSingleOZRoleHolder(_hashConsensusForAccountingOracle, DEFAULT_ADMIN_ROLE, address(this));
        _assertZeroOZRoleHolders(_accountingOracle, DEFAULT_ADMIN_ROLE);

        _assertSingleOZRoleHolder(_hashConsensusForValidatorsExitBusOracle, DEFAULT_ADMIN_ROLE, address(this));
        _assertZeroOZRoleHolders(_validatorsExitBusOracle, DEFAULT_ADMIN_ROLE);
        _assertZeroOZRoleHolders(_validatorsExitBusOracle, _validatorsExitBusOracle.RESUME_ROLE());
        _assertZeroOZRoleHolders(_validatorsExitBusOracle, _validatorsExitBusOracle.PAUSE_ROLE());

        _assertZeroOZRoleHolders(_stakingRouter, DEFAULT_ADMIN_ROLE);
        _assertZeroOZRoleHolders(_stakingRouter, _stakingRouter.STAKING_MODULE_PAUSE_ROLE());
        _assertZeroOZRoleHolders(_stakingRouter, _stakingRouter.STAKING_MODULE_RESUME_ROLE());
        _assertZeroOZRoleHolders(_stakingRouter, _stakingRouter.REPORT_EXITED_VALIDATORS_ROLE());
        _assertZeroOZRoleHolders(_stakingRouter, _stakingRouter.REPORT_REWARDS_MINTED_ROLE());

        _assertZeroOZRoleHolders(_withdrawalQueue, DEFAULT_ADMIN_ROLE);
        _assertZeroOZRoleHolders(_withdrawalQueue, _withdrawalQueue.RESUME_ROLE());
        _assertZeroOZRoleHolders(_withdrawalQueue, _withdrawalQueue.PAUSE_ROLE());
        _assertZeroOZRoleHolders(_withdrawalQueue, _withdrawalQueue.FINALIZE_ROLE());
        _assertZeroOZRoleHolders(_withdrawalQueue, _withdrawalQueue.ORACLE_ROLE());
    }

    function _assertLocatorAddresses() internal view {
        if (
            _locator.accountingOracle() != address(_accountingOracle)
         || _locator.burner() != address(_burner)
         || _locator.depositSecurityModule() != address(_depositSecurityModule)
         || _locator.lido() != address(_lido)
         || _locator.legacyOracle() != address(_legacyOracle)
         || _locator.oracleDaemonConfig() != address(_oracleDaemonConfig)
         || _locator.oracleReportSanityChecker() != address(_oracleReportSanityChecker)
         || _locator.stakingRouter() != address(_stakingRouter)
         || _locator.validatorsExitBusOracle() != address(_validatorsExitBusOracle)
         || _locator.withdrawalQueue() != address(_withdrawalQueue)
         || _locator.withdrawalVault() != address(_withdrawalVault)
        ) {
            revert WrongLocatorAddresses();
        }
    }

    function _assertFeeDistribution() internal view {
        (uint16 treasuryFeeBasisPoints, , uint16 operatorsFeeBasisPoints) = _lido.getFeeDistribution();
        // New fee values for staking module are set as values relative to the all rewards gained
        // Although Lido.getFeeDistribution() returns values relative to total fee taken by the protocol from all rewards
        // So need to convert "relative" hardcoded values into their "absolute" form
        uint256 totalFee = _lido.getFee();
        if ((NOR_STAKING_MODULE_MODULE_FEE_BP * TOTAL_BASIS_POINTS) / totalFee != operatorsFeeBasisPoints
         || (NOR_STAKING_MODULE_TREASURY_FEE_BP * TOTAL_BASIS_POINTS) / totalFee != treasuryFeeBasisPoints
        ) {
            revert WrongFeeDistribution();
        }
    }

    function _assertCorrectDSMParameters() internal view {
        IDepositSecurityModule dsm = _depositSecurityModule;
        if (
            dsm.getMaxDeposits() != EXPECTED_DSM_MAX_DEPOSITS_PER_BLOCK
         || dsm.getPauseIntentValidityPeriodBlocks() != EXPECTED_DSM_PAUSE_INTENT_VALIDITY_PERIOD_BLOCKS
         || dsm.getMinDepositBlockDistance() != EXPECTED_DSM_MIN_DEPOSIT_BLOCK_DISTANCE
        ) {
            revert IncorrectDepositSecurityModuleParameters(address(dsm));
        }
    }

    function _upgradeProxyImplementations() internal {
        _locator.proxy__upgradeTo(_locatorImplementation);
        _accountingOracle.proxy__upgradeTo(_accountingOracleImplementation);
        _validatorsExitBusOracle.proxy__upgradeTo(_validatorsExitBusOracleImplementation);
        _stakingRouter.proxy__upgradeTo(_stakingRouterImplementation);
        _withdrawalQueue.proxy__upgradeTo(_withdrawalQueueImplementation);
    }

    function _assertAdminsOfProxies(address admin) internal view {
        _assertProxyAdmin(_locator, admin);
        _assertProxyAdmin(_accountingOracle, admin);
        _assertProxyAdmin(_stakingRouter, admin);
        _assertProxyAdmin(_validatorsExitBusOracle, admin);
        _assertProxyAdmin(_withdrawalQueue, admin);
    }

    function _assertProxyAdmin(IOssifiableProxy proxy, address admin) internal view {
        if (proxy.proxy__getAdmin() != admin) revert WrongProxyAdmin(address(proxy));
    }

    function _assertOracleReportSanityCheckerRoles() internal view {
        IOracleReportSanityChecker checker = _oracleReportSanityChecker;
        _assertSingleOZRoleHolder(checker, DEFAULT_ADMIN_ROLE, _agent);
        _assertZeroOZRoleHolders(checker, checker.ALL_LIMITS_MANAGER_ROLE());
        _assertZeroOZRoleHolders(checker, checker.CHURN_VALIDATORS_PER_DAY_LIMIT_MANGER_ROLE());
        _assertZeroOZRoleHolders(checker, checker.ONE_OFF_CL_BALANCE_DECREASE_LIMIT_MANAGER_ROLE());
        _assertZeroOZRoleHolders(checker, checker.ANNUAL_BALANCE_INCREASE_LIMIT_MANAGER_ROLE());
        _assertZeroOZRoleHolders(checker, checker.SHARE_RATE_DEVIATION_LIMIT_MANAGER_ROLE());
        _assertZeroOZRoleHolders(checker, checker.MAX_VALIDATOR_EXIT_REQUESTS_PER_REPORT_ROLE());
        _assertZeroOZRoleHolders(checker, checker.MAX_ACCOUNTING_EXTRA_DATA_LIST_ITEMS_COUNT_ROLE());
        _assertZeroOZRoleHolders(checker, checker.MAX_NODE_OPERATORS_PER_EXTRA_DATA_ITEM_COUNT_ROLE());
        _assertZeroOZRoleHolders(checker, checker.REQUEST_TIMESTAMP_MARGIN_MANAGER_ROLE());
        _assertZeroOZRoleHolders(checker, checker.MAX_POSITIVE_TOKEN_REBASE_MANAGER_ROLE());
    }

    function _assertOracleReportSanityCheckerParameters() internal view {
        LimitsList memory limitsList = _oracleReportSanityChecker.getOracleReportLimits();
        if (
            limitsList.churnValidatorsPerDayLimit != SANITY_LIMIT_churnValidatorsPerDayLimit
         || limitsList.oneOffCLBalanceDecreaseBPLimit != SANITY_LIMIT_oneOffCLBalanceDecreaseBPLimit
         || limitsList.annualBalanceIncreaseBPLimit != SANITY_LIMIT_annualBalanceIncreaseBPLimit
         || limitsList.simulatedShareRateDeviationBPLimit != SANITY_LIMIT_simulatedShareRateDeviationBPLimit
         || limitsList.maxValidatorExitRequestsPerReport != SANITY_LIMIT_maxValidatorExitRequestsPerReport
         || limitsList.maxAccountingExtraDataListItemsCount != SANITY_LIMIT_maxAccountingExtraDataListItemsCount
         || limitsList.maxNodeOperatorsPerExtraDataItemCount != SANITY_LIMIT_maxNodeOperatorsPerExtraDataItemCount
         || limitsList.requestTimestampMargin != SANITY_LIMIT_requestTimestampMargin
         || limitsList.maxPositiveTokenRebase != SANITY_LIMIT_maxPositiveTokenRebase
         ) {
            revert InvalidOracleReportSanityCheckerConfig();
         }
    }

    function _assertOracleDaemonConfigRoles() internal view {
        IOracleDaemonConfig config = _oracleDaemonConfig;
        _assertSingleOZRoleHolder(config, DEFAULT_ADMIN_ROLE, _agent);
        _assertZeroOZRoleHolders(config, config.CONFIG_MANAGER_ROLE());
    }

    function _assertOracleDaemonConfigParameters() internal view {
        _assertKeyValue(NORMALIZED_CL_REWARD_PER_EPOCH_KEY, NORMALIZED_CL_REWARD_PER_EPOCH_VALUE);
        _assertKeyValue(NORMALIZED_CL_REWARD_MISTAKE_RATE_BP_KEY, NORMALIZED_CL_REWARD_MISTAKE_RATE_BP_VALUE);
        _assertKeyValue(REBASE_CHECK_NEAREST_EPOCH_DISTANCE_KEY, REBASE_CHECK_NEAREST_EPOCH_DISTANCE_VALUE);
        _assertKeyValue(REBASE_CHECK_DISTANT_EPOCH_DISTANCE_KEY, REBASE_CHECK_DISTANT_EPOCH_DISTANCE_VALUE);
        _assertKeyValue(VALIDATOR_DELAYED_TIMEOUT_IN_SLOTS_KEY, VALIDATOR_DELAYED_TIMEOUT_IN_SLOTS_VALUE);
        _assertKeyValue(VALIDATOR_DELINQUENT_TIMEOUT_IN_SLOTS_KEY, VALIDATOR_DELINQUENT_TIMEOUT_IN_SLOTS_VALUE);
        _assertKeyValue(PREDICTION_DURATION_IN_SLOTS_KEY, PREDICTION_DURATION_IN_SLOTS_VALUE);
        _assertKeyValue(FINALIZATION_MAX_NEGATIVE_REBASE_EPOCH_SHIFT_KEY, FINALIZATION_MAX_NEGATIVE_REBASE_EPOCH_SHIFT_VALUE);
        _assertKeyValue(NODE_OPERATOR_NETWORK_PENETRATION_THRESHOLD_BP_KEY, NODE_OPERATOR_NETWORK_PENETRATION_THRESHOLD_BP_VALUE);
    }

    function _assertKeyValue(string memory key, bytes memory value) internal view {
        if (keccak256(_oracleDaemonConfig.get(key)) != keccak256(value)) {
            revert WrongOracleDaemonConfigKeyValue(key);
        }
    }

    function _assertInitialProxyImplementations() internal view {
        if (_withdrawalVault.implementation() != _withdrawalVaultImplementation) revert WrongInitialImplementation(address(_withdrawalVault));
        _assertInitialDummyImplementation(_accountingOracle);
        _assertInitialDummyImplementation(_stakingRouter);
        _assertInitialDummyImplementation(_validatorsExitBusOracle);
        _assertInitialDummyImplementation(_withdrawalQueue);
    }

    function _assertInitialDummyImplementation(IOssifiableProxy proxy) internal view {
        if (proxy.proxy__getImplementation() != _dummyImplementation) revert WrongInitialImplementation(address(proxy));
    }

    function _assertZeroOZRoleHolders(IAccessControlEnumerable accessControlled, bytes32 role) internal view {
        if (accessControlled.getRoleMemberCount(role) != 0) {
            revert NonZeroRoleHolders(address(accessControlled), role);
        }
    }

    function _assertSingleOZRoleHolder(IAccessControlEnumerable accessControlled, bytes32 role, address holder) internal view {
        if (accessControlled.getRoleMemberCount(role) != 1
         || accessControlled.getRoleMember(role, 0) != holder
        ) {
            revert WrongOZAccessControlRoleHolders(address(accessControlled), role);
        }
    }

    function _assertTwoOZRoleHolders(IAccessControlEnumerable accessControlled, bytes32 role, address holder1, address holder2) internal view {
        if (accessControlled.getRoleMemberCount(role) != 2
         || accessControlled.getRoleMember(role, 0) != holder1
         || accessControlled.getRoleMember(role, 1) != holder2
        ) {
            revert WrongOZAccessControlRoleHolders(address(accessControlled), role);
        }
    }

    function _initializeAccountingOracle() internal {
        // NB: HashConsensus.updateInitialEpoch must be called after AccountingOracle implementation is bound to proxy
        _hashConsensusForAccountingOracle.updateInitialEpoch(
            _calcInitialEpochForAccountingOracleHashConsensus()
        );

        _accountingOracle.initialize(
            address(this),
            address(_hashConsensusForAccountingOracle),
            ACCOUNTING_ORACLE_CONSENSUS_VERSION
        );
    }

    function _calcInitialEpochForAccountingOracleHashConsensus() internal view returns (uint256) {
        (, uint256 epochsPerFrame, ) = _hashConsensusForAccountingOracle.getFrameConfig();
        uint256 lastLidoOracleCompletedEpochId = _lidoOracle.getLastCompletedEpochId();
        return lastLidoOracleCompletedEpochId + epochsPerFrame;
    }

    function _initializeWithdrawalQueue() internal {
        IWithdrawalQueue wq = _withdrawalQueue;
        wq.initialize(address(this));
        wq.grantRole(wq.PAUSE_ROLE(), _gateSeal);
        wq.grantRole(wq.FINALIZE_ROLE(), address(_lido));
        wq.grantRole(wq.ORACLE_ROLE(), address(_accountingOracle));
        _resumeWithdrawalQueue();
    }

    function _initializeStakingRouter() internal {
        IStakingRouter sr = _stakingRouter;
        sr.initialize(address(this), address(_lido), WITHDRAWAL_CREDENTIALS);
        sr.grantRole(sr.STAKING_MODULE_PAUSE_ROLE(), address(_depositSecurityModule));
        sr.grantRole(sr.REPORT_EXITED_VALIDATORS_ROLE(), address(_accountingOracle));
        sr.grantRole(sr.REPORT_REWARDS_MINTED_ROLE(), address(_lido));
    }

    function _initializeValidatorsExitBus() internal {
        IValidatorsExitBusOracle vebo = _validatorsExitBusOracle;
        // NB: Setting same initial epoch as for AccountingOracle on purpose
        _hashConsensusForValidatorsExitBusOracle.updateInitialEpoch(
            _calcInitialEpochForAccountingOracleHashConsensus()
        );
        vebo.initialize(
            address(this),
            address(_hashConsensusForValidatorsExitBusOracle),
            VALIDATORS_EXIT_BUS_ORACLE_CONSENSUS_VERSION,
            VEBO_LAST_PROCESSING_REF_SLOT
        );
        vebo.grantRole(vebo.PAUSE_ROLE(), _gateSeal);
        _resumeValidatorsExitBusOracle();
    }

    function _migrateLidoOracleCommitteeMembers() internal {
        address[] memory members = _lidoOracle.getOracleMembers();
        uint256 quorum = _lidoOracle.getQuorum();
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
        _depositSecurityModule.addGuardians(guardians, quorum);
    }

    function _finishUpgrade() internal {
        if (msg.sender != _voting) revert OnlyVotingCanUpgrade();
        if (!_isUpgradeStarted) revert UpgradeNotStarted();
        if (_isUpgradeFinished) revert CanOnlyFinishOnce();
        /// Here we check that the contract got new ABI function getContractVersion(), although it is 0 yet
        /// because in the new contract version is stored in a different slot
        if (_legacyOracle.getContractVersion() != NOT_INITIALIZED_CONTRACT_VERSION) {
            revert LidoOracleMustBeUpgradedToLegacy();
        }
        _isUpgradeFinished = true;

        _withdrawalVault.initialize();


        _initializeWithdrawalQueue();

        _initializeValidatorsExitBus();

        _initializeStakingRouter();

        _legacyOracle.finalizeUpgrade_v4(address(_accountingOracle));

        _lido.finalizeUpgrade_v2(address(_locator), _eip712StETH);

        _nodeOperatorsRegistry.finalizeUpgrade_v2(
            address(_locator),
            NODE_OPERATORS_REGISTRY_STAKING_MODULE_TYPE,
            NODE_OPERATORS_REGISTRY_STUCK_PENALTY_DELAY
        );

        _migrateDSMGuardians();

        _attachNORToStakingRouter();

        _burner.grantRole(_burner.REQUEST_BURN_SHARES_ROLE(), address(_nodeOperatorsRegistry));

        _passAdminRoleFromTemplateToAgent();

        _assertUpgradeIsFinishedCorrectly();
    }

    function _attachNORToStakingRouter() internal {
        bytes32 sm_manage_role = _stakingRouter.STAKING_MODULE_MANAGE_ROLE();
        _stakingRouter.grantRole(sm_manage_role, address(this));
        _stakingRouter.addStakingModule(
            NOR_STAKING_MODULE_NAME,
            address(_nodeOperatorsRegistry),
            NOR_STAKING_MODULE_TARGET_SHARE_BP,
            NOR_STAKING_MODULE_MODULE_FEE_BP,
            NOR_STAKING_MODULE_TREASURY_FEE_BP
        );
        _stakingRouter.renounceRole(sm_manage_role, address(this));
    }

    function _passAdminRoleFromTemplateToAgent() internal {
        // NB: No need to pass OracleDaemonConfig and OracleReportSanityChecker admin roles
        // because they were Agent at the beginning and are not needed by the template

        _transferOZAdminFromThisToAgent(_hashConsensusForValidatorsExitBusOracle);
        _transferOZAdminFromThisToAgent(_hashConsensusForAccountingOracle);
        _transferOZAdminFromThisToAgent(_burner);
        _transferOZAdminFromThisToAgent(_stakingRouter);
        _transferOZAdminFromThisToAgent(_accountingOracle);
        _transferOZAdminFromThisToAgent(_validatorsExitBusOracle);
        _transferOZAdminFromThisToAgent(_withdrawalQueue);

        _locator.proxy__changeAdmin(_agent);
        _stakingRouter.proxy__changeAdmin(_agent);
        _accountingOracle.proxy__changeAdmin(_agent);
        _validatorsExitBusOracle.proxy__changeAdmin(_agent);
        _withdrawalQueue.proxy__changeAdmin(_agent);

        _depositSecurityModule.setOwner(_agent);
    }

    function _assertUpgradeIsFinishedCorrectly() internal view {
        if (!_isUpgradeStarted) revert UpgradeNotStarted();
        if (!_isUpgradeFinished) revert UpgradeNotFinished();

        _checkContractVersions();

        _assertFinalACL();

        _assertNewAragonAppImplementations();
        _assertOracleDaemonConfigParameters();
        _assertOracleReportSanityCheckerParameters();
        _assertCorrectDSMParameters();
        // TODO: restore the check when gateSeal gets deployed
        // _assertGateSealSealables();
        _assertCorrectOracleAndConsensusContractsBinding(_accountingOracle, _hashConsensusForAccountingOracle);
        _assertCorrectOracleAndConsensusContractsBinding(_validatorsExitBusOracle, _hashConsensusForValidatorsExitBusOracle);
        _assertCorrectStakingModule();
        if (_withdrawalQueue.isPaused()) revert WQNotResumed();
        if (_validatorsExitBusOracle.isPaused()) revert VEBONotResumed();
        // Check new version of feeDistribution() after Lido implementation updated
        _assertFeeDistribution();
    }

    function _assertNewAragonAppImplementations() internal view {
        _assertSingleAragonAppImplementation(_aragonAppLidoRepo, _lidoImplementation);
        _assertSingleAragonAppImplementation(_aragonAppNodeOperatorsRegistryRepo, _nodeOperatorsRegistryImplementation);
        _assertSingleAragonAppImplementation(_aragonAppLegacyOracleRepo, _legacyOracleImplementation);
    }

    function _assertSingleAragonAppImplementation(IAragonAppRepo repo, address implementation) internal view {
        (, address actualImplementation, ) = repo.getLatest();
        if (actualImplementation != implementation) {
            revert WrongAragonAppImplementation(address(repo), implementation);
        }
    }

    function _assertFinalACL() internal view {
        if (_withdrawalVault.proxy_getAdmin() != _voting) revert WrongProxyAdmin(address(_withdrawalVault));
        _assertAdminsOfProxies(_agent);

        if (_depositSecurityModule.getOwner() != _agent) revert WrongDsmOwner();

        _assertOracleDaemonConfigRoles();
        _assertOracleReportSanityCheckerRoles();

        _assertSingleOZRoleHolder(_burner, DEFAULT_ADMIN_ROLE, _agent);
        _assertTwoOZRoleHolders(_burner, _burner.REQUEST_BURN_SHARES_ROLE(), address(_lido), address(_nodeOperatorsRegistry));

        _assertSingleOZRoleHolder(_hashConsensusForAccountingOracle, DEFAULT_ADMIN_ROLE, _agent);
        _assertSingleOZRoleHolder(_accountingOracle, DEFAULT_ADMIN_ROLE, _agent);

        _assertSingleOZRoleHolder(_hashConsensusForValidatorsExitBusOracle, DEFAULT_ADMIN_ROLE, _agent);
        _assertSingleOZRoleHolder(_validatorsExitBusOracle, DEFAULT_ADMIN_ROLE, _agent);
        _assertZeroOZRoleHolders(_validatorsExitBusOracle, _validatorsExitBusOracle.RESUME_ROLE());
        _assertSingleOZRoleHolder(_validatorsExitBusOracle, _validatorsExitBusOracle.PAUSE_ROLE(), _gateSeal);

        _assertSingleOZRoleHolder(_stakingRouter, DEFAULT_ADMIN_ROLE, _agent);
        _assertZeroOZRoleHolders(_stakingRouter, _stakingRouter.STAKING_MODULE_RESUME_ROLE());
        _assertSingleOZRoleHolder(_stakingRouter, _stakingRouter.STAKING_MODULE_PAUSE_ROLE(), address(_depositSecurityModule));
        _assertSingleOZRoleHolder(_stakingRouter, _stakingRouter.REPORT_EXITED_VALIDATORS_ROLE(), address(_accountingOracle));
        _assertSingleOZRoleHolder(_stakingRouter, _stakingRouter.REPORT_REWARDS_MINTED_ROLE(), address(_lido));

        _assertSingleOZRoleHolder(_withdrawalQueue, DEFAULT_ADMIN_ROLE, _agent);
        _assertZeroOZRoleHolders(_withdrawalQueue, _withdrawalQueue.RESUME_ROLE());
        _assertSingleOZRoleHolder(_withdrawalQueue, _withdrawalQueue.PAUSE_ROLE(), _gateSeal);
        _assertSingleOZRoleHolder(_withdrawalQueue, _withdrawalQueue.FINALIZE_ROLE(), address(_lido));
        _assertSingleOZRoleHolder(_withdrawalQueue, _withdrawalQueue.ORACLE_ROLE(), address(_accountingOracle));
    }

    function _assertGateSealSealables() internal view {
        address[] memory sealables = IGateSeal(_gateSeal).get_sealables();
        if (
            sealables.length != 2
         || sealables[0] != address(_withdrawalQueue)
         || sealables[1] != address(_validatorsExitBusOracle)
         ) {
            revert WrongSealGateSealables();
        }
    }

    function _assertCorrectStakingModule() internal view {
        IStakingRouter sr = _stakingRouter;

        if (
            !sr.hasStakingModule(NOR_STAKING_MODULE_ID)
         || sr.hasStakingModule(NOR_STAKING_MODULE_ID + 1)
         || sr.getStakingModulesCount() != 1
         ) {
            revert WrongStakingModulesCount();
        }

        StakingModule memory module = sr.getStakingModule(NOR_STAKING_MODULE_ID);
        if (
            module.id != NOR_STAKING_MODULE_ID
         || module.stakingModuleAddress != address(_nodeOperatorsRegistry)
         || module.stakingModuleFee != NOR_STAKING_MODULE_MODULE_FEE_BP
         || module.treasuryFee != NOR_STAKING_MODULE_TREASURY_FEE_BP
         || module.targetShare != NOR_STAKING_MODULE_TARGET_SHARE_BP
         || module.status != uint8(StakingModuleStatus.Active)
         || keccak256(abi.encodePacked(module.name)) != keccak256(abi.encodePacked(NOR_STAKING_MODULE_NAME))
         || module.lastDepositAt != block.timestamp
         || module.lastDepositBlock != block.number
         || module.exitedValidatorsCount != 0
        ) {
            revert WrongStakingModuleParameters();
        }
    }

    function _assertCorrectOracleAndConsensusContractsBinding(IBaseOracle oracle, IHashConsensus hashConsensus) internal view {
        if (
            oracle.getConsensusContract() != address(hashConsensus)
         || hashConsensus.getReportProcessor() != address(oracle)
        ) {
            revert IncorrectOracleAndHashConsensusBinding(address(oracle), address(hashConsensus));
        }
    }

    function _checkContractVersions() internal view {
        _assertContractVersion(_lido, EXPECTED_FINAL_LIDO_VERSION);
        _assertContractVersion(_nodeOperatorsRegistry, EXPECTED_FINAL_NODE_OPERATORS_REGISTRY_VERSION);
        _assertContractVersion(_legacyOracle, EXPECTED_FINAL_LEGACY_ORACLE_VERSION);
        _assertContractVersion(_accountingOracle, EXPECTED_FINAL_ACCOUNTING_ORACLE_VERSION);
        _assertContractVersion(_stakingRouter, EXPECTED_FINAL_STAKING_ROUTER_VERSION);
        _assertContractVersion(_validatorsExitBusOracle, EXPECTED_FINAL_VALIDATORS_EXIT_BUS_ORACLE_VERSION);
        _assertContractVersion(_withdrawalQueue, EXPECTED_FINAL_WITHDRAWAL_QUEUE_VERSION);
        _assertContractVersion(_withdrawalVault, EXPECTED_FINAL_WITHDRAWAL_VAULT_VERSION);
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

    function _isExpired() internal view returns (bool) {
        return block.timestamp >= EXPIRES_SINCE_INCLUSIVE;
    }

    function _resumeWithdrawalQueue() internal {
        IWithdrawalQueue wq = _withdrawalQueue;
        bytes32 resume_role = wq.RESUME_ROLE();
        wq.grantRole(resume_role, address(this));
        wq.resume();
        wq.renounceRole(resume_role, address(this));
    }

    // To be strict need two almost identical _resume... function because RESUME_ROLE and resume()
    // do not actually belong to PausableUntil contract
    function _resumeValidatorsExitBusOracle() internal {
        IValidatorsExitBusOracle vebo = _validatorsExitBusOracle;
        bytes32 resume_role = vebo.RESUME_ROLE();
        vebo.grantRole(resume_role, address(this));
        vebo.resume();
        vebo.renounceRole(resume_role, address(this));
    }

    error OnlyVotingCanUpgrade();
    error CanOnlyStartOnce();
    error CanOnlyFinishOnce();
    error UpgradeNotStarted();
    error UpgradeNotFinished();
    error UpgradeNotEnacted();
    error LidoOracleMustNotBeUpgradedToLegacyYet();
    error LidoOracleMustBeUpgradedToLegacy();
    error WrongDsmOwner();
    error WrongProxyAdmin(address proxy);
    error WrongInitialImplementation(address proxy);
    error InvalidContractVersion(address contractAddress, uint256 actualVersion);
    error WrongOZAccessControlAdmin(address contractAddress);
    error WrongOZAccessControlRoleHolders(address contractAddress, bytes32 role);
    error NonZeroRoleHolders(address contractAddress, bytes32 role);
    error WQNotResumed();
    error VEBONotResumed();
    error IncorrectOracleAndHashConsensusBinding(address oracle, address hashConsensus);
    error IncorrectDepositSecurityModuleParameters(address _depositSecurityModule);
    error WrongStakingModulesCount();
    error InvalidOracleReportSanityCheckerConfig();
    error WrongSealGateSealables();
    error WrongStakingModuleParameters();
    error WrongOracleDaemonConfigKeyValue(string key);
    error WrongLocatorAddresses();
    error WrongAragonAppImplementation(address repo, address implementation);
    error WrongFeeDistribution();
    error ExpireSinceMustBeInFuture();
}
