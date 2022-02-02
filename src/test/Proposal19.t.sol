// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

// Interfaces
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

// Contracts
import {Proposal19} from "../Proposal19.sol";
import "../utils/YAMTest.sol";
import {YAMDelegate3} from "../utils/YAMDelegate3.sol";


// Proposal for July contributor payment and stream setup.
contract Proposal19Test is YAMTest {
    Proposal19 private proposal;

    function setUp() public {
        setUpYAMTest();
        proposal = new Proposal19();
    }

    function testProposal19() public {
        address[] memory targets = new address[](2);
        uint256[] memory values = new uint256[](2);
        string[] memory signatures = new string[](2);
        bytes[] memory calldatas = new bytes[](2);
        string memory description = "Setup proposol as sub gov on vestingPool, whitelist withdrawals for contributor payments.";

        /// @notice Set proposal as sub gov for vesting pool. 
        targets[0] = address(vestingPool);
        signatures[0] = "setSubGov(address,bool)";
        calldatas[0] = abi.encode(address(proposal), true);

        /// @notice Whitelist propogal to withdraw usdc.
        targets[1] = address(reserves);
        signatures[1] = "whitelistWithdrawals(address[],uint256[],address[])";
        address[] memory whos = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        address[] memory tokens = new address[](1);
        whos[0] = address(proposal);
        amounts[0] = type(uint256).max;
        tokens[0] = address(yUSDC);
        calldatas[1] = abi.encode(whos, amounts, tokens);

        /// @notice Get quorum for test proposal.
        getQuorum(yamDelegator, proposer);
        vm.roll(block.number + 1);

        /// @notice Post and vote on proposal.
        rollProposal(targets, values, signatures, calldatas, description);

        vm.roll(block.number + 1);
        proposal.execute();
        ff(61 minutes);

        // Assert reserves have the yUSDC we should have.
        assertTrue(IERC20(address(yUSDC)).balanceOf(address(reserves)) > 760000 * (10**6));

        // Assert no USDC or yUSDC was left in the proposal.
        assertEq(IERC20(USDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDC).balanceOf(address(proposal)), 0);
    }
}
