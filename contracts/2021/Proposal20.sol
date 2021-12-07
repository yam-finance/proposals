pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;

import {VestingPool} from "yamV3/tests/vesting_pool/VestingPool.sol";
import {YAMTokenInterface} from "yamV3/token/YAMTokenInterface.sol";
import {IERC20} from "yamV3/lib/IERC20.sol";

interface YVault {
    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);
}

contract Proposal20 {
    // @dev Contracts and ERC20 addresses
    IERC20 internal constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    YVault internal constant yUSDC = YVault(0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9);
    VestingPool internal constant pool = VestingPool(0xDCf613db29E4d0B35e7e15e93BF6cc6315eB0b82);
    address internal constant RESERVES = 0x97990B693835da58A281636296D2Bf02787DEa17;

    function execute() public {
        IERC20(address(yUSDC)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(yUSDC)).balanceOf(RESERVES)
        );
        yUSDC.withdraw(uint256(-1));

        // Stablecoin transfers

        // E
        USDC.transfer(
            0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f,
            yearlyUSDToMonthlyUSD(120000 * (10**6), 2)
        );

        // Chilly
        USDC.transfer(
            0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C,
            yearlyUSDToMonthlyUSD(84000 * (10**6), 2)
        );
        
        // Krguman
        USDC.transfer(
            0xcc506b3c2967022094C3B00276617883167BF32B,
            yearlyUSDToMonthlyUSD(30000 * (10**6), 2)
        );
        
        // Designer
        USDC.transfer(
            0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C,
            yearlyUSDToMonthlyUSD(96000 * (10**6), 2)
        );
        
        // Ross
        USDC.transfer(
            0x88c868B1024ECAefDc648eb152e91C57DeA984d0,
            yearlyUSDToMonthlyUSD(84000 * (10**6), 2)
        );
        
        // Blokku
        USDC.transfer(
            0x392027fDc620d397cA27F0c1C3dCB592F27A4dc3,
            yearlyUSDToMonthlyUSD(22500 * (10**6), 2)
        );
        
        // Kris
        USDC.transfer(
            0x386568164bdC5B105a66D8Ae83785D4758939eE6,
            yearlyUSDToMonthlyUSD(15000 * (10**6), 2)
        );
        
        // Will
        USDC.transfer(
            0x31920DF2b31B5f7ecf65BDb2c497DE31d299d472,
            yearlyUSDToMonthlyUSD(84000 * (10**6), 2)
        );
        
        // Snake
        USDC.transfer(
            0xce1559448e21981911fAC70D4eC0C02cA1EFF39C,
            yearlyUSDToMonthlyUSD(28800 * (10**6), 2)
        );
        
        // Joe
        USDC.transfer(
            0x1Ba2A537A771AA4EaC2f18427716557e4E744864,
            yearlyUSDToMonthlyUSD(28800 * (10**6), 2)
        );
        
        // Nate
        USDC.transfer(
            0xEC3281124d4c2FCA8A88e3076C1E7749CfEcb7F2,
            yearlyUSDToMonthlyUSD(26256 * (10**6), 1)
        );
        
        // Jono
        USDC.transfer(
            0xFcB4f3a1710FefA583e7b003F3165f2E142bC725,
            yearlyUSDToMonthlyUSD(42000 * (10**6), 1)
        );
        
        // Jason
        USDC.transfer(
            0x43fD74401B4BF04095590a5308B6A5e3Db44b9e3,
            yearlyUSDToMonthlyUSD(48000 * (10**6), 1)
        );

        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.approve(address(yUSDC), usdcBalance);
        yUSDC.deposit(usdcBalance, RESERVES);

        // Streams

        // Update E stream
        pool.closeStream(13);
        pool.openStream(
            0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f,
            90 days,
            10303 * (10**24) * 3
        );

        // Update Chilly stream
        pool.closeStream(17);
        pool.openStream(
            0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C,
            90 days,
            2436 * (10**24) * 3
        );
        
        // Update Krugman stream
        pool.closeStream(18);
        pool.openStream(
            0xcc506b3c2967022094C3B00276617883167BF32B,
            90 days,
            727 * (10**24) * 3
        );

        // Update Mona stream
        pool.closeStream(23);
        pool.openStream(
            0xdADc6F71986643d9e9CB368f08Eb6F1333F6d8f9,
            90 days,
            1212 * (10**24) * 3
        );

        // Update Byterose stream
        pool.closeStream(60);
        pool.openStream(
            0xbe9Bb7a473DE5c043146B24AbfA72AB81aee67CD,
            90 days,
            7273 * (10**24) * 3
        );

        // Byterose stream previous pay
        pool.openStream(
            0xbe9Bb7a473DE5c043146B24AbfA72AB81aee67CD,
            0 days,
            7273 * (10**24)
        );

        // Update Nate stream
        pool.closeStream(14);

    }

    function yearlyUSDToMonthlyUSD(uint256 yearlyUSD, uint256 months) internal pure returns (uint256) {
        return ((yearlyUSD / uint256(12)) * months);
    }
}