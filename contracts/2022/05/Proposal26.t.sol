// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "../../../utils/YAMTest.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {YAMDelegate3} from "../../../utils/YAMDelegate3.sol";
import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {Proposal26} from "./Proposal26.sol";

interface YYCRV {
    function deposit(uint256 _amount) external;

    function withdraw(uint256 shares) external;
}

contract Proposal26test is YAMTest {
    Proposal26 private proposal;

    IERC20 internal constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant YAM =
        IERC20(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);
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
    address internal constant twoKeyContract =
        0x8348c5EC31D486e6E4207fC0B17a906A0806550d;
    IERC20 internal constant UGASDEC21 =
        IERC20(0xE3Df5e08b72704C23229cB92fe847B23BfDe9dBd);
    IERC20 internal constant UPUNKSDEC21 =
        IERC20(0x37a572b95d3FB5007a3519e73D4e9D6e0fc9De50);
    IERC20 internal constant SCJAN6 =
        IERC20(0x0B4470515228625ef51E6DB32699989046fCE4De);
    IERC20 internal constant SCDEC2 =
        IERC20(0xf447EF251De50E449107C8D687d10C91e0b7e4D4);
    IERC20 internal constant SCNOV3 =
        IERC20(0xff8f62855fD433347BbE62f1292F905f7aC1DF9d);

    function setUp() public {
        setUpYAMTest();
        proposal = new Proposal26();
    }

    function test_proposal_26() public {
        address[] memory targets = new address[](4);
        uint256[] memory values = new uint256[](4);
        string[] memory signatures = new string[](4);
        bytes[] memory calldatas = new bytes[](4);
        string
            memory description = "Contributors comps for May, backpay for VDM, settling synths tokens and success tokens, sending settled rewards tokens to reserves, sending and withdrawing test uma and claiming sushi for reserves.";

        // Whitelist proposal for withdrawals
        targets[0] = address(reserves);
        signatures[0] = "whitelistWithdrawals(address[],uint256[],address[])";
            address[] memory whos = new address[](7);
            uint256[] memory amounts = new uint256[](7);
            address[] memory tokens = new address[](7);

            //whitelist USDC
            whos[0] = address(proposal);
            amounts[0] = type(uint256).max;
            tokens[0] = address(USDC);

            //whitelist YAM
            whos[1] = address(proposal);
            amounts[1] = type(uint256).max;
            tokens[1] = address(YAM);

            //whitelist UMA synths and success tokens
            whos[2] = address(proposal);
            amounts[2] = type(uint256).max;
            tokens[2] = address(UGASDEC21);

            whos[3] = address(proposal);
            amounts[3] = type(uint256).max;
            tokens[3] = address(UPUNKSDEC21);

            whos[4] = address(proposal);
            amounts[4] = type(uint256).max;
            tokens[4] = address(SCJAN6);

            whos[5] = address(proposal);
            amounts[5] = type(uint256).max;
            tokens[5] = address(SCDEC2);

            whos[6] = address(proposal);
            amounts[6] = type(uint256).max;
            tokens[6] = address(SCNOV3);
        calldatas[0] = abi.encode(whos, amounts, tokens);

        // claim sushi rewards from incentivizer
        targets[1] = address(INCENTIVIZER);
        signatures[1] = "sushiToReserves(uint256)";
        calldatas[1] = abi.encode(type(uint256).max);

        // Send 2 uma to twoKeyContract
        targets[2] = address(RESERVES);
        signatures[2] = "oneTimeTransfers(address[],uint256[],address[])";
        address[] memory whosOne = new address[](1);
        uint256[] memory amountsOne = new uint256[](1);
        address[] memory tokensOne = new address[](1);
        whosOne[0] = address(twoKeyContract);
        amountsOne[0] = uint256(2000000000000000000);
        tokensOne[0] = address(UMA);
        calldatas[2] = abi.encode(whosOne, amountsOne, tokensOne);

        //withdraw 1 UMA from twoKeyContract
        targets[3] = address(twoKeyContract);
        signatures[3] = "withdrawErc20(address,uint256)";
        calldatas[3] = abi.encode(address(UMA), uint256(1000000000000000000));

        // Get quorum for test proposal
        getQuorum(yamV3, proposer);
        bing();

        // Post, vote and execute proposal
        rollProposal(targets, values, signatures, calldatas, description);
        bing();

        proposal.execute();
        ff(61 minutes);

        // twoKeyContract should have 1 uma
        assertEq(
            IERC20(UMA).balanceOf(address(twoKeyContract)),
            1000000000000000000
        );

        // Reserves should have the weth we should have
        assertTrue(
            IERC20(WETH).balanceOf(address(reserves)) > 540000000000000000000
        );

        // Reserves should have the yam we should have
        assertTrue(
            IERC20(YAM).balanceOf(address(reserves)) > 200000000000000000000000
        );

        // Reserves should have the uma we should have
        assertEq(
            IERC20(UMA).balanceOf(address(reserves)),
            41091589082431890628026
        );

        // Reserves should have the sushi rewards
        assertTrue(
            IERC20(SUSHI).balanceOf(address(reserves)) > 4600000000000000000000
        );

        // Reserves should have the yUSDC we should have
        assertTrue(IERC20(yUSDC).balanceOf(address(reserves)) > 1560000000000);

        // Reserves should have the USDC we should have
        assertTrue(IERC20(USDC).balanceOf(address(reserves)) > 35000000000);

        // Reserves should have the synths success tokens we should have
        assertEq(IERC20(SCJAN6).balanceOf(address(reserves)), 0);
        assertEq(IERC20(SCDEC2).balanceOf(address(reserves)), 0);
        assertEq(IERC20(SCNOV3).balanceOf(address(reserves)), 0);

        // No WETH, USDC or yUSDC should be left in the proposal
        assertEq(IERC20(WETH).balanceOf(address(proposal)), 0);
        assertEq(IERC20(USDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDCV2).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDC).balanceOf(address(proposal)), 0);
    }
}
