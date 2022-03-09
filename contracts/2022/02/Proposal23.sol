// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import {VestingPool} from "../../../utils/VestingPool.sol";
import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {LongShortPair} from "uma/financial-templates/long-short-pair/LongShortPair.sol";
import {PricelessPositionManager} from "uma/financial-templates/expiring-multiparty/PricelessPositionManager.sol";

interface YVault {
    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);
}

contract Proposal23 {
    /// @dev Contracts and ERC20 addresses
    IERC20 internal constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant UMA =
        IERC20(0x04Fa0d235C4abf4BcF4787aF4CF447DE572eF828);
    YVault internal constant yUSDCV2 =
        YVault(0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9);
    YVault internal constant yUSDC =
        YVault(0xa354F35829Ae975e850e23e9615b11Da1B3dC4DE);
    IERC20 internal constant USDC =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 internal constant SUSHI =
        IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    VestingPool internal constant pool =
        VestingPool(0xDCf613db29E4d0B35e7e15e93BF6cc6315eB0b82);
    address internal constant RESERVES =
        0x97990B693835da58A281636296D2Bf02787DEa17;
    address internal constant MULTISIG =
        0x744D16d200175d20E6D8e5f405AEfB4EB7A962d1;

    IERC20 internal constant SCJAN6 =
        IERC20(0x0B4470515228625ef51E6DB32699989046fCE4De);
    IERC20 internal constant SCDEC2 =
        IERC20(0xf447EF251De50E449107C8D687d10C91e0b7e4D4);
    IERC20 internal constant SCNOV3 =
        IERC20(0xff8f62855fD433347BbE62f1292F905f7aC1DF9d);
    IERC20 internal constant UGASSEP21 =
        IERC20(0xfc10b3A8011B00489705EF1Fc00D0e501106cB1D);
    IERC20 internal constant UGASJUN21 =
        IERC20(0xa6B9d7E3d76cF23549293Fb22c488E0Ea591A44e);
    IERC20 internal constant USTONKSSEP21 =
        IERC20(0xad4353347f05438Ace12aef7AceF6CB2b4186C00);
    IERC20 internal constant USTONKSAPR21 =
        IERC20(0xEC58d3aefc9AAa2E0036FA65F70d569f49D9d1ED);
    IERC20 internal constant USTONKSJUN21 =
        IERC20(0x20F8d43672Cfd78c471972C737134b5DCB700Dd8);
    LongShortPair internal constant LSPSCJAN6 =
        LongShortPair(0xd68761A94302A854C4a368186Af3030378ef8d37);
    LongShortPair internal constant LSPSCDEC2 =
        LongShortPair(0xb8B3583F143B3a4c2AA052828d8809b0818A16E9);
    LongShortPair internal constant LSPSCNOV3 =
        LongShortPair(0x75dBfa9D22CFfc5D8D8c1376Acc75CfCacd77DfB);
    PricelessPositionManager internal constant EMPUGASSEP21 =
        PricelessPositionManager(0xcA2531b9CD04daf0c9114D853e7A83D8528f20bD);
    PricelessPositionManager internal constant EMPUGASJUN21 =
        PricelessPositionManager(0x4E8d60A785c2636A63c5Bd47C7050d21266c8B43);
    PricelessPositionManager internal constant EMPUSTONKSSEP21 =
        PricelessPositionManager(0x799c9518Ea434bBdA03d4C0EAa58d644b768d3aB);
    PricelessPositionManager internal constant EMPUSTONKSAPR21 =
        PricelessPositionManager(0x4F1424Cef6AcE40c0ae4fc64d74B734f1eAF153C);
    PricelessPositionManager internal constant EMPUSTONKSJUN21 =
        PricelessPositionManager(0xB1a3E5a8d642534840bFC50c6417F9566E716cc7);

    function execute() public {
        // Transfer 10 WETH to the multisig
        IERC20(address(WETH)).transferFrom(RESERVES, MULTISIG, 10 * (10**18));

        // Synths tokens
        IERC20(address(UGASSEP21)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(UGASSEP21)).balanceOf(RESERVES)
        );
        IERC20(address(UGASJUN21)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(UGASJUN21)).balanceOf(RESERVES)
        );
        IERC20(address(USTONKSSEP21)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(USTONKSSEP21)).balanceOf(RESERVES)
        );
        IERC20(address(USTONKSAPR21)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(USTONKSAPR21)).balanceOf(RESERVES)
        );
        IERC20(address(USTONKSJUN21)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(USTONKSJUN21)).balanceOf(RESERVES)
        );
        UGASSEP21.approve(address(EMPUGASSEP21), type(uint256).max);
        UGASJUN21.approve(address(EMPUGASJUN21), type(uint256).max);
        USTONKSSEP21.approve(address(EMPUSTONKSSEP21), type(uint256).max);
        USTONKSAPR21.approve(address(EMPUSTONKSAPR21), type(uint256).max);
        USTONKSJUN21.approve(address(EMPUSTONKSJUN21), type(uint256).max);
        EMPUGASSEP21.settleExpired();
        EMPUGASJUN21.settleExpired();
        EMPUSTONKSSEP21.settleExpired();
        EMPUSTONKSAPR21.settleExpired();
        EMPUSTONKSJUN21.settleExpired();

        // Success tokens
        IERC20(address(SCJAN6)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(SCJAN6)).balanceOf(RESERVES)
        );
        IERC20(address(SCDEC2)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(SCDEC2)).balanceOf(RESERVES)
        );
        IERC20(address(SCNOV3)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(SCNOV3)).balanceOf(RESERVES)
        );
        LSPSCJAN6.settle(IERC20(address(SCJAN6)).balanceOf(address(this)), 0);
        LSPSCDEC2.settle(IERC20(address(SCDEC2)).balanceOf(address(this)), 0);
        LSPSCNOV3.settle(IERC20(address(SCNOV3)).balanceOf(address(this)), 0);

        // Withdraw USDC and yUSDC
        IERC20(address(USDC)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(USDC)).balanceOf(RESERVES)
        );
        IERC20(address(yUSDCV2)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(yUSDCV2)).balanceOf(RESERVES)
        );
        yUSDCV2.withdraw(type(uint256).max);

        // Send unrwapped rewards to reserves
        WETH.transfer(RESERVES, WETH.balanceOf(address(this)));
        UMA.transfer(RESERVES, UMA.balanceOf(address(this)));
        USDC.transfer(RESERVES, 100000 * (10**6));

        // Stablecoin transfers

        // Chilly
        USDC.transfer(
            0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C,
            yearlyToMonthlyUSD(93800, 1)
        );

        // Designer
        USDC.transfer(
            0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C,
            yearlyToMonthlyUSD(92400, 1)
        );

        // Blokku
        USDC.transfer(
            0x392027fDc620d397cA27F0c1C3dCB592F27A4dc3,
            yearlyToMonthlyUSD(22500, 2)
        );

        // Ross
        USDC.transfer(
            0x88c868B1024ECAefDc648eb152e91C57DeA984d0,
            yearlyToMonthlyUSD(84000, 1)
        );

        // Will
        USDC.transfer(
            0xF0EEF765172c9AEAf76B57656A1Cd717033C391c,
            yearlyToMonthlyUSD(84000, 1)
        );

        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.approve(address(yUSDC), usdcBalance);
        yUSDC.deposit(usdcBalance, RESERVES);

        // Streams

        // Update E stream
        pool.closeStream(84);
        pool.openStream(
            0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f,
            60,
            4048 * (10**24) * 2
        );

        // Close Jono stream
        pool.closeStream(72);

        // Close Joe stream
        pool.closeStream(75);

        // Close Krug stream
        pool.closeStream(86);

        // Close Snake stream
        pool.closeStream(93);

    }

    function yearlyToMonthlyUSD(uint256 yearlyUSD, uint256 months)
        internal
        pure
        returns (uint256)
    {
        return (((yearlyUSD * (10**6)) / uint256(12)) * months);
    }
}

