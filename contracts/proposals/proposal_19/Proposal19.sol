pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;

import {VestingPool} from "../../../node_modules/yam/contracts/tests/vesting_pool/VestingPool.sol";
import {IERC20} from "../../../node_modules/yam/contracts/lib/IERC20.sol";
import {YAMTokenInterface} from "../../../node_modules/yam/contracts/token/YAMTokenInterface.sol";
import {Swapper} from "../../../node_modules/yam/contracts/tests/swapper/Swapper.sol";
interface IBasicIssuanceModule {
    function redeem(
        IERC20 setToken,
        uint256 amount,
        address to
    ) external;
}

interface YVault {
    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);
}

interface IUMAFarming {
    function _approveExit() external;

    function _approveEnter() external;
}

contract Proposal19 {
    // Stream updates
    VestingPool internal constant pool =
        VestingPool(0xDCf613db29E4d0B35e7e15e93BF6cc6315eB0b82);

    // For paying contributors
    address internal constant RESERVES =
        0x97990B693835da58A281636296D2Bf02787DEa17;
    YVault internal constant yUSDC =
        YVault(0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9);
    IERC20 internal constant USDC =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    Swapper internal constant SWAPPER = Swapper(0xB4E5BaFf059C5CE3a0EE7ff8e9f16ca9dd91F1fE);
    function execute() public {
        IERC20(address(yUSDC)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(yUSDC)).balanceOf(RESERVES)
        );
        yUSDC.withdraw(uint256(-1));
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

        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.approve(address(yUSDC), usdcBalance);
        yUSDC.deposit(usdcBalance, RESERVES);

        // Close Tom stream
        pool.closeStream(63);

        // Close Indigo stream
        pool.closeStream(59);

        // Update Ross stream
        pool.closeStream(65);
        pool.openStream(
            0x88c868B1024ECAefDc648eb152e91C57DeA984d0,
            180 days,
            1250 * (10**24) * 6
        );

        // Update Blokku stream
        pool.closeStream(61);
        pool.openStream(
            0x392027fDc620d397cA27F0c1C3dCB592F27A4dc3,
            180 days,
            2333 * (10**24) * 6
        );

        // Update Kris stream
        pool.closeStream(62);
        pool.openStream(
            0x386568164bdC5B105a66D8Ae83785D4758939eE6,
            180 days,
            667 * (10**24) * 6
        );

        // Update Jono stream
        pool.closeStream(56);
        pool.openStream(
            0xFcB4f3a1710FefA583e7b003F3165f2E142bC725,
            180 days,
            800 * (10**24) * 6
        );

        // Update Will stream
        pool.closeStream(57);
        pool.openStream(
            0x31920DF2b31B5f7ecf65BDb2c497DE31d299d472,
            180 days,
            1600 * (10**24) * 6
        );

        // Open Snake stream
        pool.openStream(
            0xce1559448e21981911fAC70D4eC0C02cA1EFF39C,
            180 days,
            5120 * (10**24) * 6
        );

        // Open Joe stream
        pool.openStream(
            0x1Ba2A537A771AA4EaC2f18427716557e4E744864,
            180 days,
            853 * (10**24) * 6
        );

        // Snake trial period payment
        pool.openStream(
            0xce1559448e21981911fAC70D4eC0C02cA1EFF39C,
            0 days,
            4545 * (10**24)
        );

        // Joe trial period payment
        pool.openStream(
            0x1Ba2A537A771AA4EaC2f18427716557e4E744864,
            0 days,
            1818 * (10**24)
        );

        // Sushiswap 2 hop INDEX to ETH to USDC
        SWAPPER.addSwap(
            Swapper.SwapParams({
                sourceToken: 0x0954906da0Bf32d5479e25f46056d22f08464cab,
                destinationToken: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
                router: 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F,
                pool1: 0xA73DF646512C82550C2b3C0324c4EEdEE53b400C,
                pool2: 0x397FF1542f962076d0BFE58eA045FfA2d347ACa0,
                sourceAmount: 5000 * (10**18),
                slippageLimit: 35 * (10**15)
            })
        );

    }

    function yearlyUSDToMonthlyUSD(uint256 yearlyUSD)
        internal
        pure
        returns (uint256)
    {
        return ((yearlyUSD / uint256(12)));
    }
}
