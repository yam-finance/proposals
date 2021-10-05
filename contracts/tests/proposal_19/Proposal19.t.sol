// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;

import "../../../node_modules/yam/contracts/tests/test_tests/base.t.sol";
import {IERC20} from "../../../node_modules/yam/contracts/lib/IERC20.sol";
import {UGAS1221Farming} from "../../../node_modules/yam/contracts/tests/ugas_farming/UGAS1221Farming.sol";
import {UPUNKS1221Farming} from "../../../node_modules/yam/contracts/tests/upunks_farming/UPUNKS1221Farming.sol";
import {YAMDelegate3} from "../../../node_modules/yam/contracts/token/YAMDelegate3.sol";

import {Proposal19} from "../../proposals/proposal_19/Proposal19.sol";

// Prop for July contributor payment and stream setup
contract Prop19 is YAMv3Test {
    Proposal19 private proposal =
        Proposal19(0xffA396b7490dDAa4230B34aF365620Fa1802c4B3);

    UGAS1221Farming internal UGAS_0921_FARMING =
        UGAS1221Farming(0x54837096585faB2E45B9a9b0b38B542136d136D5);
    UGAS1221Farming internal UGAS_1221_FARMING;

    UPUNKS1221Farming internal UPUNKS_1221_FARMING;

    address internal constant TREASURY_MULTISIG =
        0x744D16d200175d20E6D8e5f405AEfB4EB7A962d1;

    function setUp() public {
        setUpCore();
        UGAS_1221_FARMING = new UGAS1221Farming(address(timelock));
        UPUNKS_1221_FARMING = new UPUNKS1221Farming(address(timelock));
        proposal = new Proposal19();
    }

    /**
     * Summary:
     * 1. Give Proposal permissions to use index staking contract and Yam's synth farming contracts
     * 2. Send YAM to distributor - uPUNK rewards payout
     * 3. Send USDC to distributor - monthly contributor payout
     * 4. Delegate INDEX to Feddas
     **/
    function test_onchain_prop_19() public {

        address[] memory targets = new address[](5);
        uint256[] memory values = new uint256[](5);
        string[] memory signatures = new string[](5);
        bytes[] memory calldatas = new bytes[](5);

        string
            memory description = "Setup proposol as sub gov on vestingPool, approve moving of uGas/uPunks farming, whitelist withdrawals for contributor payments and for uGas/uPunks farming";

        // -- Approve exiting UGAS_0921_Farming
        targets[0] = address(UGAS_0921_FARMING);
        signatures[0] = "_approveExit()";
        calldatas[0] = "";

        // -- Approve entering UGAS_1221_Farming
        targets[1] = address(UGAS_1221_FARMING);
        signatures[1] = "_approveEnter()";
        calldatas[1] = "";

        // -- Set proposal as sub gov for new USTONKS Sept Farming
        targets[2] = address(UPUNKS_1221_FARMING);
        signatures[2] = "_approveEnter()";
        calldatas[2] = "";

        // -- Set proposal as sub gov for old USTONKS Sept Farming
        targets[3] = address(vestingPool);
        signatures[3] = "setSubGov(address,bool)";
        calldatas[3] = abi.encode(address(proposal), true);

        // -- Whitelist proposal to withdraw usdc. whitelist Swapper to withdraw WETH, SUSHI, and DPI
        targets[4] = address(reserves);
        signatures[4] = "whitelistWithdrawals(address[],uint256[],address[])";
        address[] memory whos = new address[](3);
        uint256[] memory amounts = new uint256[](3);
        address[] memory tokens = new address[](3);

        whos[0] = address(proposal);
        amounts[0] = uint256(-1);
        tokens[0] = address(yUSDC);

        whos[1] = address(UPUNKS_1221_FARMING);
        amounts[1] = uint256(-1);
        tokens[1] = address(weth);

        whos[2] = address(UGAS_1221_FARMING);
        amounts[2] = uint256(-1);
        tokens[2] = address(weth);

        calldatas[4] = abi.encode(whos, amounts, tokens);

        yamhelper.getQuorum(yamV3, me);
        yamhelper.bing();

        roll_prop(targets, values, signatures, calldatas, description);

        executeProposal();
        tests();
        testWithdrawals();
    }

    function executeProposal() internal {
        proposal.executeStepOne();
        UGAS_0921_FARMING.update_twap();
        UGAS_1221_FARMING.update_twap();
        UPUNKS_1221_FARMING.update_twap();
        indexStaking.update_twap();
        yamhelper.ff(61 minutes);

        UGAS_0921_FARMING.exit();
        UGAS_1221_FARMING.enter();
        UPUNKS_1221_FARMING.enter();

        // proposal.executeStepTwo();
    }

    function tests() internal {
        // Assert reserves have the yUSDC we should have
        assertTrue(
            IERC20(address(yUSDC)).balanceOf(address(reserves)) >
                390000 * (10**6)
        );
        // Assert reserves have the WETH we should have
        assertTrue(IERC20(address(WETH)).balanceOf(address(reserves)) > 33005041943861866342);
        assertTrue(IERC20(0xF6E15Cdf292D36A589276C835cC576F0DF0Fe53A).balanceOf(address(UGAS_1221_FARMING)) > 210628913073199628716);
        assertTrue(IERC20(0x9469313a1702dC275015775249883cFc35Aa94d8).balanceOf(address(UPUNKS_1221_FARMING)) > 70062703759388895375);
        assertEq(IERC20(USDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDC).balanceOf(address(proposal)), 0);
    }

    // Creates and executes 2nd proposal that withdraws all assets from synth farming and dpi/eth pooling, testing that they work as expected
    // Not strictly necessary, as withdrawals are tested elsewhere, but just as an extra sanity check
    function testWithdrawals() internal {
        address[] memory targets = new address[](2);
        uint256[] memory values = new uint256[](2);
        string[] memory signatures = new string[](2);
        bytes[] memory calldatas = new bytes[](2);

        string memory description = "Exit farming and LPing";

        // -- Set proposal as sub gov for indexStaking
        targets[0] = address(UGAS_1221_FARMING);
        signatures[0] = "_approveExit()";
        calldatas[0] = "";

        // -- Set proposal as sub gov for indexStaking
        targets[1] = address(UPUNKS_1221_FARMING);
        signatures[1] = "_approveExit()";
        calldatas[1] = "";

        yamhelper.getQuorum(yamV3, me);
        yamhelper.bing();

        roll_prop(targets, values, signatures, calldatas, description);

        // Try withdrawing UGAS, USTONKS, and UPUNKS
        UGAS_1221_FARMING.update_twap();
        UPUNKS_1221_FARMING.update_twap();
        yamhelper.ff(61 minutes);
        UGAS_1221_FARMING.exit();
        UPUNKS_1221_FARMING.exit();

        // Assert we have the WETH we should have
        assertTrue(IERC20(WETH).balanceOf(address(reserves)) >= 440429080405428532386);
    }
}
