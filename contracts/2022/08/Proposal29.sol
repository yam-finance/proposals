// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {ISablier} from "../../../utils/Sablier.sol";
import "../../../utils/YAMDelegator.sol";

interface IYVault {
    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);
}

interface IETHDPIStaking {
    function _exitStaking() external;

    function _getTokenFromHere(address token) external;
}

contract Proposal29 {
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
    IERC20 internal constant DPI =
        IERC20(0x1494CA1F11D487c2bBe4543E90080AeBa4BA3C2b);
    IERC20 internal constant GTC =
        IERC20(0xDe30da39c46104798bB5aA3fe8B9e0e1F348163F);
    IERC20 internal constant INDEX =
        IERC20(0x0954906da0Bf32d5479e25f46056d22f08464cab);
    IERC20 internal constant SUSHI =
        IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    IERC20 internal constant XSUSHI =
        IERC20(0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272);
    IERC20 internal constant ETHDPILP =
        IERC20(0x4d5ef58aAc27d99935E5b6B4A6778ff292059991);
    IETHDPIStaking internal ethdpiStaking =
        IETHDPIStaking(0x205Cc7463267861002b27021C7108Bc230603d0F);
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

        // Exit staking
        ethdpiStaking._exitStaking();
        ethdpiStaking._getTokenFromHere(address(ETHDPILP));

        // Withdraw to multisig
        withdrawToken(address(DPI), MULTISIG, IERC20(DPI).balanceOf(RESERVES));
        withdrawToken(address(GTC), MULTISIG, IERC20(GTC).balanceOf(RESERVES));
        withdrawToken(
            address(INDEX),
            MULTISIG,
            IERC20(INDEX).balanceOf(RESERVES)
        );
        withdrawToken(
            address(SUSHI),
            MULTISIG,
            IERC20(SUSHI).balanceOf(RESERVES)
        );
        withdrawToken(
            address(XSUSHI),
            MULTISIG,
            IERC20(XSUSHI).balanceOf(RESERVES)
        );
        withdrawToken(
            address(ETHDPILP),
            MULTISIG,
            IERC20(ETHDPILP).balanceOf(RESERVES)
        );

        // Comp transfers

        // // E
        // compSend(0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f, 8000, 31250, 1);
        // Chilly
        compSend(0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C, 7854, 25500, 1);
        // // Designer
        // compSend(0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C, 7140, 20625, 1);
        // // Ross
        // compSend(0x88c868B1024ECAefDc648eb152e91C57DeA984d0, 4008, 27022, 1);
        // // Feddas
        // compSend(0xbdac5657eDd13F47C3DD924eAa36Cf1Ec49672cc, 8925, 0, 1);
        // Mona
        compSend(0xdADc6F71986643d9e9CB368f08Eb6F1333F6d8f9, 0, 12250, 1);

        // Return remaining USDC to reserves
        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.transfer(RESERVES, usdcBalance);

        executeStep++;
    }

    function executeStreams() public {
        require(executeStep == 1);

        // Approve Sablier
        YAM.approve(address(Sablier), type(uint256).max);

        // Yam streams

        // // E
        // compStream(0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f, 37500);
        // Chilly
        compStream(0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C, 21038);
        // // Designer
        // compStream(0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C, 19125);
        // // Ross
        // compStream(0x88c868B1024ECAefDc648eb152e91C57DeA984d0, 16047);
        // // Feddas
        // compStream(0xbdac5657eDd13F47C3DD924eAa36Cf1Ec49672cc, 39844);
        // Mona
        compStream(0xdADc6F71986643d9e9CB368f08Eb6F1333F6d8f9, 10413);
        // // Jpgs
        // compStream(0x653d63E4F2D7112a19f5Eb993890a3F27b48aDa5, 21250);

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
            uint256 streamOut = (uint256(stream) / 12960000) * 12960000;
            Sablier.createStream(
                _address,
                streamOut,
                address(YAM),
                block.timestamp + 900,
                block.timestamp + 900 + 12960000
            );
        }
    }
}
