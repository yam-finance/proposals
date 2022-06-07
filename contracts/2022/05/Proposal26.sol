// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {VestingPool} from "../../../utils/VestingPool.sol";
import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {LongShortPair} from "uma/financial-templates/long-short-pair/LongShortPair.sol";
import {PricelessPositionManager} from "uma/financial-templates/expiring-multiparty/PricelessPositionManager.sol";

interface IYVault {
    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);
}

contract Proposal26 {
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
    IERC20 internal constant UGASDEC21 =
        IERC20(0xE3Df5e08b72704C23229cB92fe847B23BfDe9dBd);
    IERC20 internal constant UPUNKSDEC21 =
        IERC20(0x37a572b95d3FB5007a3519e73D4e9D6e0fc9De50);
    LongShortPair internal constant LSPSCJAN6 =
        LongShortPair(0xd68761A94302A854C4a368186Af3030378ef8d37);
    LongShortPair internal constant LSPSCDEC2 =
        LongShortPair(0xb8B3583F143B3a4c2AA052828d8809b0818A16E9);
    LongShortPair internal constant LSPSCNOV3 =
        LongShortPair(0x75dBfa9D22CFfc5D8D8c1376Acc75CfCacd77DfB);
    PricelessPositionManager internal constant EMPUGASDEC21 =
        PricelessPositionManager(0x7C62e5c39b7b296f4f2244e7EB51bea57ed26e4B);
    PricelessPositionManager internal constant EMPUPUNKSDEC21 =
        PricelessPositionManager(0xf35a80E4705C56Fd345E735387c3377baCcd8189);

    function execute() public {
        
        // Send USDC from Treasury to this contract
        IERC20(address(USDC)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(USDC)).balanceOf(RESERVES)
        );

        // Send YAM from Treasury to this contract
        IERC20(address(YAM)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(YAM)).balanceOf(RESERVES)
        );

        // Send compensation to contributors using the compSend() function
        // compSend(receivingAddress, USDC amount, YAM Amount, # of months);

        // // E
        // compSend(0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f, 9917, 21250, 1);
        // Chilly
        compSend(0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C, 5600, 12000, 1);
        // Designer
        compSend(0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C, 5863, 12563, 1);
        // Ross
        compSend(0x88c868B1024ECAefDc648eb152e91C57DeA984d0, 7000, 15000, 1);
        // Mona
        compSend(0xdADc6F71986643d9e9CB368f08Eb6F1333F6d8f9, 0, 8330, 1);
        // VMD backpay
        compSend(0x06d0F6b856bB4ea42C6b0f7e99101EeC3755EEcd, 3625, 1690, 1);

        // Return all remaining USDC back to Treasury
        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.transfer(RESERVES, usdcBalance);
        
        // Return all remaining YAM back to Treasury
        uint256 yamBalance = YAM.balanceOf(address(this));
        YAM.transfer(RESERVES, yamBalance);

        // Synths
        
        // Send all UGASDEC21 and UPUNKSDEC21 from Treasury to this contract
        IERC20(address(UGASDEC21)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(UGASDEC21)).balanceOf(RESERVES)
        );
        IERC20(address(UPUNKSDEC21)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(UPUNKSDEC21)).balanceOf(RESERVES)
        );
        
        //Approve and settle UGASDEC21 and UPUNKSDEC21
        UGASDEC21.approve(address(EMPUGASDEC21), type(uint256).max);
        UPUNKSDEC21.approve(address(EMPUPUNKSDEC21), type(uint256).max);
        EMPUGASDEC21.settleExpired();
        EMPUPUNKSDEC21.settleExpired();

        // Send all Success tokens from Treasury to this contract
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
        // settle all Success Tokens for underlying
        LSPSCJAN6.settle(IERC20(address(SCJAN6)).balanceOf(address(this)), 0);
        LSPSCDEC2.settle(IERC20(address(SCDEC2)).balanceOf(address(this)), 0);
        LSPSCNOV3.settle(IERC20(address(SCNOV3)).balanceOf(address(this)), 0);

        // Return all WETH and UMA to the Treasury
        WETH.transfer(RESERVES, WETH.balanceOf(address(this)));
        UMA.transfer(RESERVES, UMA.balanceOf(address(this)));

    }
    
    // Function used to distribute compensation to contributors
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
