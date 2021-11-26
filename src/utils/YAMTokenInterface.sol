// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "./YAMTokenStorage.sol";
import "./YAMGovernanceStorage.sol";

abstract contract YAMTokenInterface is YAMTokenStorage, YAMGovernanceStorage {

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /**
     * @notice Event emitted when tokens are rebased
     */
    event Rebase(uint256 epoch, uint256 prevYamsScalingFactor, uint256 newYamsScalingFactor);

    /*** Gov Events ***/

    /**
     * @notice Event emitted when pendingGov is changed
     */
    event NewPendingGov(address oldPendingGov, address newPendingGov);

    /**
     * @notice Event emitted when gov is changed
     */
    event NewGov(address oldGov, address newGov);

    /**
     * @notice Sets the rebaser contract
     */
    event NewRebaser(address oldRebaser, address newRebaser);

    /**
     * @notice Sets the migrator contract
     */
    event NewMigrator(address oldMigrator, address newMigrator);

    /**
     * @notice Sets the incentivizer contract
     */
    event NewIncentivizer(address oldIncentivizer, address newIncentivizer);

    /* - ERC20 Events - */

    /**
     * @notice EIP20 Transfer event
     */
    event Transfer(address indexed from, address indexed to, uint amount);

    /**
     * @notice EIP20 Approval event
     */
    event Approval(address indexed owner, address indexed spender, uint amount);

    /* - Extra Events - */
    /**
     * @notice Tokens minted event
     */
    event Mint(address to, uint256 amount);

    /**
     * @notice Tokens burned event
     */
    event Burn(address from, uint256 amount);

    // Public functions
    function transfer(address to, uint256 value) virtual external returns(bool);
    function transferFrom(address from, address to, uint256 value) virtual external returns(bool);
    function balanceOf(address who) virtual external view returns(uint256);
    function balanceOfUnderlying(address who) virtual external view returns(uint256);
    function allowance(address owner_, address spender) virtual external view returns(uint256);
    function approve(address spender, uint256 value) virtual external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) virtual external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) virtual external returns (bool);
    function maxScalingFactor() virtual external view returns (uint256);
    function yamToFragment(uint256 yam) virtual external view returns (uint256);
    function fragmentToYam(uint256 value) virtual external view returns (uint256);

    /* - Governance Functions - */
    function getPriorVotes(address account, uint blockNumber) virtual external view returns (uint256);
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) virtual external;
    function delegate(address delegatee) virtual external;
    function delegates(address delegator) virtual external view returns (address);
    function getCurrentVotes(address account) virtual external view returns (uint256);

    /* - Permissioned/Governance functions - */
    function mint(address to, uint256 amount) virtual external returns (bool);
    function burn(uint256 amount) virtual external returns (bool);
    function rebase(uint256 epoch, uint256 indexDelta, bool positive) virtual external returns (uint256);
    function _setRebaser(address rebaser_) virtual external;
    function _setIncentivizer(address incentivizer_) virtual external;
    function _setPendingGov(address pendingGov_) virtual external;
    function _acceptGov() virtual external;
}
