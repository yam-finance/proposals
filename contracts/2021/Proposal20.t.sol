// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;

import "yamV3/tests/test_tests/base.t.sol";
import {IERC20} from "yamV3/lib/IERC20.sol";
import {YAMDelegate3} from "yamV3/token/YAMDelegate3.sol";
import {Proposal20} from "./Proposal20.sol";

contract Prop20 is YAMv3Test {
    Proposal20 private proposal;

    function setUp() public {
        setUpCore();
        proposal = new Proposal20();
    }

    function test_proposal_20() public {
        address[] memory targets = new address[](2);
        uint256[] memory values = new uint256[](2);
        string[] memory signatures = new string[](2);
        bytes[] memory calldatas = new bytes[](2);
        string memory description = "Contributors previous 2 months comps and VestingPool streams updates";

        // Set proposal as sub gov for vestingPool
        targets[0] = address(vestingPool);
        signatures[0] = "setSubGov(address,bool)";
        calldatas[0] = abi.encode(address(proposal), true);

        // Whitelist proposal to withdraw usdc
        targets[1] = address(reserves);
        signatures[1] = "whitelistWithdrawals(address[],uint256[],address[])";
        address[] memory whos = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        address[] memory tokens = new address[](1);
        whos[0] = address(proposal);
        amounts[0] = uint256(-1);
        tokens[0] = address(yUSDC);
        calldatas[1] = abi.encode(whos, amounts, tokens);

        yamhelper.getQuorum(yamV3, me);
        yamhelper.bing();

        roll_prop(targets, values, signatures, calldatas, description);

        proposal.execute();
        yamhelper.ff(61 minutes);

        // Reserves should have the yUSDC we should have
        assertTrue(IERC20(yUSDC).balanceOf(address(reserves)) > 721577216663);

        // No USDC or yUSDC should be left in the proposal
        assertEq(IERC20(USDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDC).balanceOf(address(proposal)), 0);
    }

}