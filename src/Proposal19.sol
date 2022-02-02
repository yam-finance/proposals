// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

// Interfaces
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

// Contracts
import {YAMTokenInterface} from "./utils/YAMTokenInterface.sol";
import {VestingPool} from "./utils/VestingPool.sol";

interface YVault {
    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);
}


contract Proposal19 {
    /// @notice Contracts for paying contributors in `USDC`.
    address internal constant RESERVES = address(0x97990B693835da58A281636296D2Bf02787DEa17);
    VestingPool internal constant pool = VestingPool(0xDCf613db29E4d0B35e7e15e93BF6cc6315eB0b82);
    YVault internal constant yUSDC = YVault(0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9);
    IERC20 internal constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    function execute() public {
        /// @dev Transfer the total yUSDC balance from `RESERVES` to `this` contract.
        IERC20(address(yUSDC)).transferFrom(RESERVES, address(this), IERC20(address(yUSDC)).balanceOf(RESERVES));
        /// @dev Withdraw `USDC` for `yUSDC`.
        yUSDC.withdraw(type(uint256).max);

        /**
         * @notice Transfer `USDC` to contributors.
         */ 

        // E
        USDC.transfer(
            0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f,
            yearlyUSDToMonthlyUSD(120000 * (10**6))
        );

        // Nate
        USDC.transfer(
            0xEC3281124d4c2FCA8A88e3076C1E7749CfEcb7F2,
            yearlyUSDToMonthlyUSD(105000 * (10**6))
        );

        // Chilly
        USDC.transfer(
            0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C,
            yearlyUSDToMonthlyUSD(84000 * (10**6))
        );

        // Krguman
        USDC.transfer(
            0xcc506b3c2967022094C3B00276617883167BF32B,
            yearlyUSDToMonthlyUSD(30000 * (10**6))
        );

        // Designer
        USDC.transfer(
            0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C,
            yearlyUSDToMonthlyUSD(96000 * (10**6))
        );

        // Ross
        USDC.transfer(
            0x88c868B1024ECAefDc648eb152e91C57DeA984d0,
            yearlyUSDToMonthlyUSD(84000 * (10**6))
        );

        // Jason
        USDC.transfer(
            0x43fD74401B4BF04095590a5308B6A5e3Db44b9e3,
            yearlyUSDToMonthlyUSD(48000 * (10**6))
        );

        // Blokku
        USDC.transfer(
            0x392027fDc620d397cA27F0c1C3dCB592F27A4dc3,
            yearlyUSDToMonthlyUSD(22500 * (10**6))
        );

        // Kris
        USDC.transfer(
            0x386568164bdC5B105a66D8Ae83785D4758939eE6,
            yearlyUSDToMonthlyUSD(15000 * (10**6))
        );

        // Jono
        USDC.transfer(
            0xFcB4f3a1710FefA583e7b003F3165f2E142bC725,
            yearlyUSDToMonthlyUSD(42000 * (10**6))
        );

        // Will
        USDC.transfer(
            0x31920DF2b31B5f7ecf65BDb2c497DE31d299d472,
            yearlyUSDToMonthlyUSD(84000 * (10**6))
        );
    
        /// @dev Deposit the remainding `USDC` balance back into the `yUSDC` vault.
        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.approve(address(yUSDC), usdcBalance);
        yUSDC.deposit(usdcBalance, RESERVES);

        /**
         * @notice Setup `YAM` streams.
         */

        // Update Ross stream
        pool.openStream(
            0x88c868B1024ECAefDc648eb152e91C57DeA984d0,
            180 days,
            1250 * (10**24) * 6
        );
    }

    function yearlyUSDToMonthlyUSD(uint256 yearlyUSD) internal pure returns (uint256) {
        return ((yearlyUSD / uint256(12)));
    }
}
