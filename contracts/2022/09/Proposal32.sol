// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {UniswapV2Router02} from "../../../utils/UniswapV2Router02.sol";
import {ISablier} from "../../../utils/Sablier.sol";
import "../../../utils/YAMDelegator.sol";

interface IYVault {
    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);
}

contract Proposal32 {
    /// Contracts and ERC20 addresses
    IERC20 internal constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant YAM =
        IERC20(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);
    YAMTokenInterface internal constant YAMV3 =
        YAMTokenInterface(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);
    IYVault internal constant yUSDC =
        IYVault(0xa354F35829Ae975e850e23e9615b11Da1B3dC4DE);
    IERC20 internal constant USDC =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 internal constant YAMSLP =
        IERC20(0x0F82E57804D0B1F6FAb2370A43dcFAd3c7cB239c);
    UniswapV2Router02 internal constant Sushiswap =
        UniswapV2Router02(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
    ISablier internal constant Sablier =
        ISablier(0xCD18eAa163733Da39c232722cBC4E8940b1D8888);
    address internal constant RESERVES =
        0x97990B693835da58A281636296D2Bf02787DEa17;
    address internal constant MULTISIG =
        0x744D16d200175d20E6D8e5f405AEfB4EB7A962d1;
    address internal constant TIMELOCK =
        0x8b4f1616751117C38a0f84F9A146cca191ea3EC5;
    uint8 executeStep = 0;

    function execute() public {
        // Withdraw USDC
        withdrawToken(
            address(USDC),
            address(this),
            IERC20(USDC).balanceOf(RESERVES)
        );

        // Comp transfers

        // // E
        // compSend(0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f, 0, 0, 1);
        // // Chilly
        // compSend(0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C, 0, 0, 1);
        // // Designer
        // compSend(0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C, 0, 0, 1);
        // Ross
        compSend(0x88c868B1024ECAefDc648eb152e91C57DeA984d0, 438, 0, 1);
        // // Feddas
        // compSend(0xbdac5657eDd13F47C3DD924eAa36Cf1Ec49672cc, 0, 0, 1);
        // // Mona
        // compSend(0xdADc6F71986643d9e9CB368f08Eb6F1333F6d8f9, 0, 0, 1);

        // Transfer remaining USDC to reserves
        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.transfer(RESERVES, usdcBalance);

        executeStep++;
    }

    function executeStreams() public {
        require(executeStep == 1);

        // Approve Sablier
        YAM.approve(address(Sablier), type(uint256).max);

        // Yam vesting

        // // E
        // compStream(0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f, 60150);
        // // Chilly
        // compStream(0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C, 0);
        // // Designer
        // compStream(0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C, 0);
        // Ross
        compStream(0x88c868B1024ECAefDc648eb152e91C57DeA984d0, 7411);
        // Feddas
        compStream(0xbdac5657eDd13F47C3DD924eAa36Cf1Ec49672cc, 19173);
        // Jpgs
        compStream(0x653d63E4F2D7112a19f5Eb993890a3F27b48aDa5, 25564);

        executeStep++;
    }

    function createPOL(
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) public {
        require(msg.sender == 0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f);

        // Withdraw WETH
        withdrawToken(
            address(WETH),
            address(this),
            IERC20(WETH).balanceOf(RESERVES)
        );

        // Approve Sushiswap
        WETH.approve(address(Sushiswap), type(uint256).max);
        YAM.approve(address(Sushiswap), type(uint256).max);

        // Add liquidity
        Sushiswap.addLiquidity(
            address(YAM),
            address(WETH),
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            address(this),
            block.timestamp + 500
        );

        // Transfer remaining WETH to reserves
        uint256 wethBalance = WETH.balanceOf(address(this));
        WETH.transfer(RESERVES, wethBalance);

        // Transfer YAMSLP tokens to reserves
        uint256 slpBalance = YAMSLP.balanceOf(address(this));
        YAMSLP.transfer(RESERVES, slpBalance);

        // Burn leftovers
        YAMV3.burn(YAM.balanceOf(address(this)));
    }

    // Function to withdraw from treasury
    function withdrawToken(
        address tokenAddress,
        address toAddress,
        uint256 amount
    ) internal {
        IERC20(tokenAddress).transferFrom(RESERVES, toAddress, amount);
    }

    // Function to distribute comps
    function compSend(
        address _address,
        uint256 amountUSDC,
        uint256 amountYAM,
        uint256 months
    ) internal {
        if (amountUSDC > 0) {
            USDC.transfer(_address, amountUSDC * (10**6) * months);
        }
        if (amountYAM > 0) {
            YAM.transfer(_address, amountYAM * (10**18) * months);
        }
    }

    // Function to open steams
    function compStream(address _address, uint256 amountYAM) internal {
        if (amountYAM > 0) {
            uint256 stream = uint256(amountYAM * (10**18));
            uint256 streamOut = (uint256(stream) / 15778500) * 15778500;
            Sablier.createStream(
                _address,
                streamOut,
                address(YAM),
                block.timestamp + 900,
                block.timestamp + 900 + 15778500
            );
        }
    }
}
