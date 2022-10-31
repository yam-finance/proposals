// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title contract used to redeem a list of tokens, by permanently
/// taking another token out of circulation.
/// @author Yam Protocol
contract YamRedeemer is ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice event to track redemptions
    event Redeemed(
        address indexed owner,
        address indexed receiver,
        uint256 amount,
        uint256 base
    );

    /// @notice event to track charity donations
    event Donated(address indexed owner);

    /// @notice token to redeem
    address public immutable _redeemedToken;

    /// @notice charities to receive donations
    address[] private _charities;

    /// @notice tokens to receive when redeeming
    address[] private _tokensReceived;

    /// @notice redeem base used to compute the redemption amounts.
    /// For instance, if the base is 100, and a user provides 100 `_redeemedToken`,
    /// they will receive all the balances of each `_tokensReceived` held on this contract.
    uint256 public _redeemBase;

    /// @notice time contract was deployed
    uint256 public _deployTimestamp;

    /// @notice donation time period
    uint256 public _donateTimePeriod = 365 days;

    /// @notice donation ratio
    uint256 public _charity1Ratio = 0.385 ether; // Gitcoin
    uint256 public _charity2Ratio = 0.615 ether; // Watoto

    constructor(
        address redeemedToken,
        address[] memory tokensReceived,
        address[] memory charities,
        uint256 redeemBase
    ) {
        _redeemedToken = redeemedToken;
        _tokensReceived = tokensReceived;
        _charities = charities;
        _redeemBase = redeemBase;
        _deployTimestamp = block.timestamp;
    }

    /// @notice Public function to get `_tokensReceived`
    function tokensReceivedOnRedeem() public view returns (address[] memory) {
        return _tokensReceived;
    }

    /// @notice Return the balances of `_tokensReceived` that would be
    /// transferred if redeeming `amountIn` of `_redeemedToken`.
    function previewRedeem(uint256 amountIn)
        public
        view
        returns (address[] memory tokens, uint256[] memory amountsOut)
    {
        tokens = tokensReceivedOnRedeem();
        amountsOut = new uint256[](tokens.length);

        uint256 base = _redeemBase;
        for (uint256 i = 0; i < _tokensReceived.length; i++) {
            uint256 balance = IERC20(_tokensReceived[i]).balanceOf(
                address(this)
            );
            require(balance != 0, "ZERO_BALANCE");
            // @dev, this assumes all of `_tokensReceived` and `_redeemedToken`
            // have the same number of decimals
            uint256 redeemedAmount = (amountIn * balance) / base;
            amountsOut[i] = redeemedAmount;
        }
    }

    /// @notice Return the ratio of tokens to be sent to the charity
    /// previewDonation() is intentionally not gas optimized to alter as little code as possible
    function previewDonation(uint256 charityRatio)
        public
        view
        returns (address[] memory tokens, uint256[] memory amountsOut)
    {
        tokens = tokensReceivedOnRedeem();
        amountsOut = new uint256[](tokens.length);

        for (uint256 i = 0; i < _tokensReceived.length; i++) {
            uint256 balance = IERC20(_tokensReceived[i]).balanceOf(
                address(this)
            );
            require(balance != 0, "ZERO_BALANCE");
            uint256 donationAmount = (charityRatio * balance) / 1 ether;
            amountsOut[i] = donationAmount;
        }
    }

    /// @notice Redeem `_redeemedToken` for a pro-rata basket of `_tokensReceived`
    function redeem(address to, uint256 amountIn) external nonReentrant {
        IERC20(_redeemedToken).safeTransferFrom(
            msg.sender,
            address(this),
            amountIn
        );

        (address[] memory tokens, uint256[] memory amountsOut) = previewRedeem(
            amountIn
        );

        uint256 base = _redeemBase;
        _redeemBase = base - amountIn; // decrement the base for future redemptions
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).safeTransfer(to, amountsOut[i]);
        }

        emit Redeemed(msg.sender, to, amountIn, base);
    }

    /// @notice Donate sends the remaining funds to the hardcoded charities after
    /// 365 days has ellapsed
    function donate() external nonReentrant {
        require(
            block.timestamp >= _deployTimestamp + _donateTimePeriod,
            "not enough time"
        );

        (
            address[] memory tokens,
            uint256[] memory amountsOutCharity1
        ) = previewDonation(_charity1Ratio);

        (, uint256[] memory amountsOutCharity2) = previewDonation(
            _charity2Ratio
        );

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).safeTransfer(
                _charities[0],
                amountsOutCharity1[i]
            );
            IERC20(tokens[i]).safeTransfer(
                _charities[1],
                amountsOutCharity2[i]
            );
        }

        emit Donated(msg.sender);
    }

    /// @notice Tokens received on redemption
    function tokensReceived() public view virtual returns (address[] memory) {
        return _tokensReceived;
    }

    /// @notice Computes the redemption amounts
    function redeemBase() public view virtual returns (uint256) {
        return _redeemBase;
    }

    /// @notice Charities addresses for donation
    function charities() public view virtual returns (address[] memory) {
        return _charities;
    }
}
