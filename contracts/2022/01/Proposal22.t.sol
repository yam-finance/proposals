// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "../../../utils/YAMTest.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {YAMDelegate3} from "../../../utils/YAMDelegate3.sol";
import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {LongShortPair} from "uma/financial-templates/long-short-pair/LongShortPair.sol";
import {PricelessPositionManager} from "uma/financial-templates/expiring-multiparty/PricelessPositionManager.sol";
import {Proposal22} from "./Proposal22.sol";

contract Proposal22test is YAMTest {
    Proposal22 private proposal;

    IERC20 internal constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant UMA =
        IERC20(0x04Fa0d235C4abf4BcF4787aF4CF447DE572eF828);
    IERC20 internal constant SUSHI =
        IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    address internal constant RESERVES =
        0x97990B693835da58A281636296D2Bf02787DEa17;
    address internal constant MULTISIG =
        0x744D16d200175d20E6D8e5f405AEfB4EB7A962d1;
    address internal constant INCENTIVIZER =
        0xD67c05523D8ec1c60760Fd017Ef006b9F6e496D0;

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

    function setUp() public {
        setUpYAMTest();
        proposal = new Proposal22();
    }

    function test_proposal_22() public {
        address[] memory targets = new address[](3);
        uint256[] memory values = new uint256[](3);
        string[] memory signatures = new string[](3);
        bytes[] memory calldatas = new bytes[](3);
        string
            memory description = "Contributors comps for January, vesting pool streams updates, settling synths tokens and success tokens, sending settled and rewards tokens to reserves, claiming sushi for reserves, converting all usdc to yusdc and multisig token refill";

        // Set proposal as sub gov for vestingPool
        targets[0] = address(vestingPool);
        signatures[0] = "setSubGov(address,bool)";
        calldatas[0] = abi.encode(address(proposal), true);

        // Whitelist proposal to withdraw usdc
        targets[1] = address(reserves);
        signatures[1] = "whitelistWithdrawals(address[],uint256[],address[])";
        address[] memory whos = new address[](12);
        uint256[] memory amounts = new uint256[](12);
        address[] memory tokens = new address[](12);
        whos[0] = address(proposal);
        amounts[0] = type(uint256).max;
        tokens[0] = address(yUSDCV2);

        whos[1] = address(proposal);
        amounts[1] = type(uint256).max;
        tokens[1] = address(WETH);

        whos[2] = address(proposal);
        amounts[2] = type(uint256).max;
        tokens[2] = address(USDC);

        whos[3] = address(proposal);
        amounts[3] = type(uint256).max;
        tokens[3] = address(UMA);

        whos[4] = address(proposal);
        amounts[4] = type(uint256).max;
        tokens[4] = address(SCJAN6);

        whos[5] = address(proposal);
        amounts[5] = type(uint256).max;
        tokens[5] = address(SCDEC2);

        whos[6] = address(proposal);
        amounts[6] = type(uint256).max;
        tokens[6] = address(SCNOV3);

        whos[7] = address(proposal);
        amounts[7] = type(uint256).max;
        tokens[7] = address(UGASSEP21);

        whos[8] = address(proposal);
        amounts[8] = type(uint256).max;
        tokens[8] = address(UGASJUN21);

        whos[9] = address(proposal);
        amounts[9] = type(uint256).max;
        tokens[9] = address(USTONKSSEP21);

        whos[10] = address(proposal);
        amounts[10] = type(uint256).max;
        tokens[10] = address(USTONKSAPR21);

        whos[11] = address(proposal);
        amounts[11] = type(uint256).max;
        tokens[11] = address(USTONKSJUN21);

        calldatas[1] = abi.encode(whos, amounts, tokens);

        targets[2] = address(INCENTIVIZER);
        signatures[2] = "sushiToReserves(uint256)";
        calldatas[2] = abi.encode(type(uint256).max);

        // Get quorum for test proposal
        getQuorum(yamV3, proposer);
        vm.roll(block.number + 1);

        // Post, vote and execute proposal
        rollProposal(targets, values, signatures, calldatas, description);
        vm.roll(block.number + 1);
        proposal.execute();
        ff(61 minutes);

        // Reserves should have the weth we should have
        assertTrue(
            IERC20(WETH).balanceOf(address(reserves)) > 277000000000000000000
        );

        // Reserves should have the uma rewards
        assertTrue(
            IERC20(UMA).balanceOf(address(reserves)) > 29000000000000000000000
        );

        // Reserves should have the sushi rewards
        assertTrue(
            IERC20(SUSHI).balanceOf(address(reserves)) > 4400000000000000000000
        );

        // Reserves should have the yUSDC we should have
        assertTrue(IERC20(yUSDC).balanceOf(address(reserves)) > 1400000000000);

        // No synths tokens should be left in the treasury
        assertEq(IERC20(SCJAN6).balanceOf(address(reserves)), 0);
        assertEq(IERC20(SCDEC2).balanceOf(address(reserves)), 0);
        assertEq(IERC20(SCNOV3).balanceOf(address(reserves)), 0);
        assertEq(IERC20(UGASSEP21).balanceOf(address(reserves)), 0);
        assertEq(IERC20(UGASJUN21).balanceOf(address(reserves)), 0);
        assertEq(IERC20(USTONKSSEP21).balanceOf(address(reserves)), 0);
        assertEq(IERC20(USTONKSAPR21).balanceOf(address(reserves)), 0);
        assertEq(IERC20(USTONKSJUN21).balanceOf(address(reserves)), 0);

        // No USDC or yUSDC should be left in the proposal
        assertEq(IERC20(USDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDCV2).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDC).balanceOf(address(proposal)), 0);
    }
}
