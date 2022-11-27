// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title contract used to redeem a list of tokens, by permanently
/// taking another token out of circulation.
/// @author Yam Protocol
contract TreasuryRedeemDonate is ReentrancyGuard {
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

    /// @notice tokens to receive when redeeming
    address[] private _tokensReceived;

    /// @notice redeem base used to compute the redemption amounts.
    /// For instance, if the base is 100, and a user provides 100 `_redeemedToken`,
    /// they will receive all the balances of each `_tokensReceived` held on this contract.
    uint256 public _redeemBase;

    /// @notice deployment time
    uint256 public _deployTimestamp;

    /// @notice time in which users can redeem
    uint256 public _redeemLength;

    /// @notice charities addresses to receive donations
    address[] private _donationCharities;

    /// @notice charities addresses ratios
    uint256[] private _donationRatios;

    constructor(
        address redeemedToken,
        address[] memory tokensReceived,
        uint256 redeemBase,
        address[] memory donationCharities,
        uint256[] memory donationRatios,
        uint256 redeemLength
    ) {
        _redeemedToken = redeemedToken;
        _tokensReceived = tokensReceived;
        _redeemBase = redeemBase;
        _donationCharities = donationCharities;
        _donationRatios = donationRatios;
        _redeemLength = redeemLength;
        _deployTimestamp = block.timestamp;
    }

    /// @notice Return the balances of `_tokensReceived` that would be
    /// transferred if redeeming `amountIn` of `_redeemedToken`.
    function previewRedeem(
        uint256 amountIn
    )
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
    function previewDonation(
        uint256 charityRatio
    )
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

    /// @notice Donate sends the remaining funds to the charities after redemption period ends
    function donate() external nonReentrant {
        require(
            block.timestamp >= _deployTimestamp + _redeemLength,
            "not enough time"
        );

        (
            address[] memory tokens,
            uint256[] memory amountsOutCharity1
        ) = previewDonation(_donationRatios[0]);

        (, uint256[] memory amountsOutCharity2) = previewDonation(
            _donationRatios[1]
        );

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).safeTransfer(
                _donationCharities[0],
                amountsOutCharity1[i]
            );
            IERC20(tokens[i]).safeTransfer(
                _donationCharities[1],
                amountsOutCharity2[i]
            );
        }

        emit Donated(msg.sender);
    }

    /// @notice Public function to get `_tokensReceived`
    function tokensReceivedOnRedeem() public view returns (address[] memory) {
        return _tokensReceived;
    }
    
    /// @notice Public function to get `_donationCharities`
    function charitiesAddresses() public view returns (address[] memory) {
        return _donationCharities;
    }

    /// @notice Public function to get `_donationRatios`
    function charitiesRatios() public view returns (uint256[] memory) {
        return _donationRatios;
    }

}
