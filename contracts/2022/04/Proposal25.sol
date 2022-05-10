// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {VestingPool} from "../../../utils/VestingPool.sol";
import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

interface IYVault {
    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);
}

contract Proposal25 {
    /// @dev Contracts and ERC20 addresses
    IERC20 internal constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant YAM =
        IERC20(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);
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
    IERC20 internal constant SCJAN6 =
        IERC20(0x0B4470515228625ef51E6DB32699989046fCE4De);
    IERC20 internal constant SCDEC2 =
        IERC20(0xf447EF251De50E449107C8D687d10C91e0b7e4D4);
    IERC20 internal constant SCNOV3 =
        IERC20(0xff8f62855fD433347BbE62f1292F905f7aC1DF9d);
    IUSynthFarming internal UGASFarming =
        IUSynthFarming(0xDFE435ade40Bbf7476a0847d5ae6B1df9BD5Ba30);
    IUSynthFarming internal USTONKSFarming =
        IUSynthFarming(0x9789204c43bbc03E9176F2114805B68D0320B31d);
    IUSynthFarming internal UPUNKSFarming =
        IUSynthFarming(0xA5163cE5331413715c1023f28499cbdC9a8b8b3E);

    function execute() public {
        // Stablecoin transfers

        // Withdraw USDC
        IERC20(address(USDC)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(USDC)).balanceOf(RESERVES)
        );

        // E
        USDC.transfer(
            0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f,
            yearlyToMonthlyUSD(119004, 1)
        );
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
        // Ross
        USDC.transfer(
            0x88c868B1024ECAefDc648eb152e91C57DeA984d0,
            yearlyToMonthlyUSD(84000, 1)
        );

        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.transfer(RESERVES, usdcBalance);

        // Synths

        // Exit position for UGAS USTONKS UPUNKS
        UGASFarming._approveExit();
        UPUNKSFarming._approveExit();

        // Claim reward tokens to treasury
        UGASFarming._getTokenFromHere(address(UMA));
        USTONKSFarming._getTokenFromHere(address(UMA));
        UPUNKSFarming._getTokenFromHere(address(UMA));
        UGASFarming._getTokenFromHere(address(SCJAN6));
        UPUNKSFarming._getTokenFromHere(address(SCJAN6));
        UGASFarming._getTokenFromHere(address(SCDEC2));
        UPUNKSFarming._getTokenFromHere(address(SCDEC2));
        UGASFarming._getTokenFromHere(address(SCNOV3));
        UPUNKSFarming._getTokenFromHere(address(SCNOV3));

        // Yam transfers

        // E
        YAM.transfer(
            0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f,
            19318 * (10**18)
        );
        // Chilly
        YAM.transfer(
            0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C,
            15227 * (10**18)
        );
        // Designer
        YAM.transfer(
            0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C,
            15000 * (10**18)
        );
        // Ross
        YAM.transfer(
            0x88c868B1024ECAefDc648eb152e91C57DeA984d0,
            13636 * (10**18)
        );
        // Mona
        YAM.transfer(
            0xdADc6F71986643d9e9CB368f08Eb6F1333F6d8f9,
            7573 * (10**18)
        );

        // Transfer vesting pool YAM to reserves
        pool.payout(pool.openStream(RESERVES, 0, 2086282107599161416658680858));

        // Transfer 25k YAM to the multisig
        YAM.transfer(MULTISIG, 25000 * (10**18));
        uint256 yamBalance = YAM.balanceOf(address(this));
        YAM.transfer(RESERVES, yamBalance);
    }

    function yearlyToMonthlyUSD(uint256 yearlyUSD, uint256 months)
        internal
        pure
        returns (uint256)
    {
        return (((yearlyUSD * (10**6)) / uint256(12)) * months);
    }
}

interface IUSynthFarming {
    function _approveEnter() external;
    function _approveExit() external;
    function _getTokenFromHere(address token) external;
    function update_twap() external;
    function enter() external;
    function exit() external;
}
