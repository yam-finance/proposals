// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;

import "yamV3/tests/test_tests/base.t.sol";
import {IERC20} from "yamV3/lib/IERC20.sol";
import {YAMDelegate3} from "yamV3/token/YAMDelegate3.sol";
import {YAMTokenInterface} from "yamV3/token/YAMTokenInterface.sol";
import {Proposal21} from "./Proposal21.sol";

contract Proposal21test is YAMv3Test {
    Proposal21 private proposal;

    IERC20 internal constant YAM =
        IERC20(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);

    function setUp() public {
        setUpCore();
        proposal = new Proposal21();
    }

    function test_proposal_21() public {
        address[] memory targets = new address[](3);
        uint256[] memory values = new uint256[](3);
        string[] memory signatures = new string[](3);
        bytes[] memory calldatas = new bytes[](3);
        string
            memory description = "Contributors comps for december, timelock delay update and vesting pool streams updates";

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

        // Update timelock delay
        targets[2] = address(timelock);
        signatures[2] = "setDelay(uint256)";
        calldatas[2] = abi.encode(uint256(432000), true);

        yamhelper.getQuorum(yamV3, me);
        yamhelper.bing();

        roll_prop(targets, values, signatures, calldatas, description);

        proposal.execute();
        yamhelper.ff(61 minutes);

        // Timelock should be updated
        assertEq(timelock.delay(), 432000);

        // Reserves should have the yUSDC we should have
        assertTrue(IERC20(yUSDC).balanceOf(address(reserves)) > 679253027501);

        // No USDC or yUSDC should be left in the proposal
        assertEq(IERC20(USDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDC).balanceOf(address(proposal)), 0);
    }
}
