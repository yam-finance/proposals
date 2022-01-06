pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;

import {VestingPool} from "yamV3/tests/vesting_pool/VestingPool.sol";
import {YAMTokenInterface} from "yamV3/token/YAMTokenInterface.sol";
import {Timelock} from "yamV3/governance/TimeLock.sol";
import {IERC20} from "yamV3/lib/IERC20.sol";

interface YVault {
    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);
}

contract Proposal21 {
    // @dev Contracts and ERC20 addresses
    IERC20 internal constant USDC =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    YVault internal constant yUSDC =
        YVault(0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9);
    VestingPool internal constant pool =
        VestingPool(0xDCf613db29E4d0B35e7e15e93BF6cc6315eB0b82);
    address internal constant RESERVES =
        0x97990B693835da58A281636296D2Bf02787DEa17;

    function execute() public {
        IERC20(address(yUSDC)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(yUSDC)).balanceOf(RESERVES)
        );
        yUSDC.withdraw(uint256(-1));

        // Stablecoin transfers

        // Chilly
        USDC.transfer(
            0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C,
            yearlyToMonthlyUSD(93800, 1)
        );

        // Krguman
        USDC.transfer(
            0xcc506b3c2967022094C3B00276617883167BF32B,
            yearlyToMonthlyUSD(28000, 1)
        );

        // Designer
        USDC.transfer(
            0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C,
            yearlyToMonthlyUSD(92400, 1)
        );

        // Ross
        USDC.transfer(
            0x88c868B1024ECAefDc648eb152e91C57DeA984d0,
            yearlyToMonthlyUSD(84000, 1)
        );

        // Blokku
        USDC.transfer(
            0x392027fDc620d397cA27F0c1C3dCB592F27A4dc3,
            yearlyToMonthlyUSD(45000, 1)
        );

        // Kris
        USDC.transfer(
            0x386568164bdC5B105a66D8Ae83785D4758939eE6,
            yearlyToMonthlyUSD(15000, 1)
        );

        // Will
        USDC.transfer(
            0x31920DF2b31B5f7ecf65BDb2c497DE31d299d472,
            yearlyToMonthlyUSD(84000, 1)
        );

        // Snake
        USDC.transfer(
            0xce1559448e21981911fAC70D4eC0C02cA1EFF39C,
            yearlyToMonthlyUSD(72000, 1)
        );

        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.approve(address(yUSDC), usdcBalance);
        yUSDC.deposit(usdcBalance, RESERVES);

        // Streams

        // Update E stream
        pool.closeStream(78);
        pool.openStream(
            0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f,
            90 days,
            13492 * (10**24) * 3
        );

        // Update Chilly stream
        pool.closeStream(79);
        pool.openStream(
            0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C,
            90 days,
            3190 * (10**24) * 3
        );

        // Update Krugman stream
        pool.closeStream(80);
        pool.openStream(
            0xcc506b3c2967022094C3B00276617883167BF32B,
            90 days,
            952 * (10**24) * 3
        );

        // Update Designer stream
        pool.closeStream(68);
        pool.openStream(
            0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C,
            90 days,
            3143 * (10**24) * 3
        );

        // Update Ross stream
        pool.closeStream(69);
        pool.openStream(
            0x88c868B1024ECAefDc648eb152e91C57DeA984d0,
            90 days,
            2381 * (10**24) * 3
        );

        // Update Byterose stream
        pool.closeStream(82);
        pool.openStream(
            0xbe9Bb7a473DE5c043146B24AbfA72AB81aee67CD,
            90 days,
            9524 * (10**24) * 3
        );

        // Update Blokku stream
        pool.closeStream(70);
        pool.openStream(
            0x392027fDc620d397cA27F0c1C3dCB592F27A4dc3,
            90 days,
            2381 * (10**24) * 3
        );

        // Update Kris stream
        pool.closeStream(71);
        pool.openStream(
            0x386568164bdC5B105a66D8Ae83785D4758939eE6,
            90 days,
            1190 * (10**24) * 3
        );

        // Update Will stream
        pool.closeStream(73);
        pool.openStream(
            0x31920DF2b31B5f7ecf65BDb2c497DE31d299d472,
            90 days,
            2857 * (10**24) * 3
        );

        // Update Snake stream
        pool.closeStream(74);
        pool.openStream(
            0xce1559448e21981911fAC70D4eC0C02cA1EFF39C,
            90 days,
            5714 * (10**24) * 3
        );

        // Update Mona stream
        pool.closeStream(81);
        pool.openStream(
            0xdADc6F71986643d9e9CB368f08Eb6F1333F6d8f9,
            90 days,
            1587 * (10**24) * 3
        );

        // Streams previous pay

        // E stream previous pay
        pool.payout(
            pool.openStream(
                0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f,
                0 days,
                4121 * (10**24)
            )
        );

        // Chilly stream previous pay
        pool.payout(
            pool.openStream(
                0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C,
                0 days,
                975 * (10**24)
            )
        );

        // Krugman stream previous pay
        pool.payout(
            pool.openStream(
                0xcc506b3c2967022094C3B00276617883167BF32B,
                0 days,
                291 * (10**24)
            )
        );

        // Mona stream previous pay
        pool.payout(
            pool.openStream(
                0xdADc6F71986643d9e9CB368f08Eb6F1333F6d8f9,
                0 days,
                485 * (10**24)
            )
        );

        // Byterose stream previous pay
        pool.payout(
            pool.openStream(
                0xbe9Bb7a473DE5c043146B24AbfA72AB81aee67CD,
                0 days,
                3879 * (10**24)
            )
        );
    }

    function yearlyToMonthlyUSD(uint256 yearlyUSD, uint256 months)
        internal
        pure
        returns (uint256)
    {
        return (((yearlyUSD * (10**6)) / uint256(12)) * months);
    }
}
