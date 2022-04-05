// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import {VestingPool} from "../../../utils/VestingPool.sol";
import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

interface IYVault {
    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);
}

interface IYYCRVVault {
    function deposit(uint256 _amount) external;
    function withdraw(uint256 shares) external;
}

interface IYCRVVault {
    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_uamount,
        bool donate_dust
    ) external;
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
    function balanceOf(address) external view returns (uint256);
}

interface IYSTETHPool {
    function deposit(uint256 _amount) external returns (uint256);
}

interface ILidoPool {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external payable returns (uint256);

    function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount)
        external
        payable
        returns (uint256);
}

contract Proposal24 {
    /// @dev Contracts and ERC20 addresses
    IERC20 internal constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant UMA =
        IERC20(0x04Fa0d235C4abf4BcF4787aF4CF447DE572eF828);
    IYVault internal constant yUSDCV2 =
        IYVault(0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9);
    IYVault internal constant yUSDC =
        IYVault(0xa354F35829Ae975e850e23e9615b11Da1B3dC4DE);
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
    address public constant yyCRV = 0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c;
    address public constant yCRV = 0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8;
    address public constant yCRVVault =
        0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3;
    ILidoPool internal constant lidoPool =
        ILidoPool(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022);
    address public constant crvstETH =
        0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address public constant steCRV = 0x06325440D014e39736583c165C2963BA99fAf14E;
    IERC20 internal constant ystETH =
        IERC20(0xdCD90C7f6324cfa40d7169ef80b12031770B4325);

    uint8 executeStep = 0;

    function execute() public {
        require(executeStep == 0);

        // Withdraw yyCRV
        IERC20(address(yyCRV)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(yyCRV)).balanceOf(RESERVES)
        );

        // Unwrap yyCRV and yCRV
        IERC20(yyCRV).approve(address(this), type(uint256).max);
        uint256 yyCRVBalance = IERC20(yyCRV).balanceOf(address(this));
        IYYCRVVault(yyCRV).withdraw(yyCRVBalance);
        IERC20(yCRV).approve(yCRVVault, type(uint256).max);
        IYCRVVault(yCRVVault).remove_liquidity_one_coin(
            IERC20(yCRV).balanceOf(address(this)),
            1,
            260000000000,
            true
        );

        // Stablecoin transfers

        // E
        USDC.transfer(
            0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f,
            yearlyToMonthlyUSD(119004, 1)
        );

        // // Chilly
        // USDC.transfer(
        //     0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C,
        //     yearlyToMonthlyUSD(93800, 1)
        // );

        // Designer
        USDC.transfer(
            0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C,
            yearlyToMonthlyUSD(92400, 1)
        );

        // // Blokku
        // USDC.transfer(
        //     0x392027fDc620d397cA27F0c1C3dCB592F27A4dc3,
        //     yearlyToMonthlyUSD(22500, 1)
        // );

        // Ross
        USDC.transfer(
            0x88c868B1024ECAefDc648eb152e91C57DeA984d0,
            yearlyToMonthlyUSD(84000, 1)
        );

        // // Nushi
        // USDC.transfer(
        //     0xF0EEF765172c9AEAf76B57656A1Cd717033C391c,
        //     yearlyToMonthlyUSD(84000, 1)
        // );

        // Deposit yUSDC into reserves
        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.approve(address(yUSDC), usdcBalance);
        yUSDC.deposit(usdcBalance, RESERVES);

        // Streams

        // Closing all streams
        pool.closeStream(12);
        pool.closeStream(15);
        pool.closeStream(16);
        pool.closeStream(55);
        pool.closeStream(83);
        pool.closeStream(85);
        pool.closeStream(87);
        pool.closeStream(88);
        pool.closeStream(89);
        pool.closeStream(90);
        pool.closeStream(91);
        pool.closeStream(92);
        pool.closeStream(94);
        pool.closeStream(100);

        executeStep++;
    }

    function executeStep2() public {
        require(executeStep == 1);
        require(msg.sender == 0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f);

        // Withdraw WETH
        IERC20(address(WETH)).transferFrom(
            RESERVES,
            address(this),
            139000000000000000000
        );
        IWETH(address(WETH)).withdraw(139000000000000000000);

        // Deposit into steCRV
        lidoPool.add_liquidity{value: 139000000000000000000}(
            [uint256(139000000000000000000), uint256(0)],
            uint256(130000000000000000000)
        );

        // Deposit into ystETH vault
        IERC20(steCRV).approve(address(ystETH), type(uint256).max);
        uint256 steCRVBalance = IERC20(steCRV).balanceOf(address(this));
        IYSTETHPool(address(ystETH)).deposit(steCRVBalance);

        // Transfer ystETH into reserves
        ystETH.transfer(RESERVES, IERC20(ystETH).balanceOf(address(this)));

        executeStep++;
    }

    fallback() external payable {}

    function yearlyToMonthlyUSD(uint256 yearlyUSD, uint256 months)
        internal
        pure
        returns (uint256)
    {
        return (((yearlyUSD * (10**6)) / uint256(12)) * months);
    }
}
