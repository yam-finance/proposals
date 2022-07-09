// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

interface IYVault {
    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);
}

contract Proposal27 {
    /// @dev Contracts and ERC20 addresses
    IERC20 internal constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant YAM =
        IERC20(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);
    IYVault internal constant yUSDC =
        IYVault(0xa354F35829Ae975e850e23e9615b11Da1B3dC4DE);
    IERC20 internal constant USDC =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address internal constant RESERVES =
        0x97990B693835da58A281636296D2Bf02787DEa17;

    function execute() public {

        // Withdraw USDC
        IERC20(address(USDC)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(USDC)).balanceOf(RESERVES)
        );

        // Withdraw YAM
        IERC20(address(YAM)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(YAM)).balanceOf(RESERVES)
        );

        // Comp transfers

        // E
        compSend(0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f, 9917, 29310, 1);
        // Chilly
        compSend(0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C, 7140, 21103, 1);
        // Designer
        compSend(0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C, 7140, 21103, 1);
        // Ross
        compSend(0x88c868B1024ECAefDc648eb152e91C57DeA984d0, 8575, 25345, 1);
        // Mona
        compSend(0xdADc6F71986643d9e9CB368f08Eb6F1333F6d8f9, 0, 11490, 1);

        // Return remaining USDC and YAM to reserves
        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.transfer(RESERVES, usdcBalance);
        uint256 yamBalance = YAM.balanceOf(address(this));
        YAM.transfer(RESERVES, yamBalance);
    }
    
    // Function used to distribute comps
    function compSend(
        address _address,
        uint256 amountUSDC,
        uint256 amountYAM,
        uint256 months
    ) internal {
        USDC.transfer(_address, amountUSDC * (10**6) * months);
        YAM.transfer(_address, amountYAM * (10**18) * months);
    }

}