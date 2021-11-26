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
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        string[] memory signatures = new string[](1);
        bytes[] memory calldatas = new bytes[](1);
        string memory description = "Setup proposol as sub gov on vestingPool, whitelist withdrawals for contributor payments.";

        /// @notice Whitelist proposal to withdraw usdc.
        targets[0] = address(reserves);
        signatures[0] = "whitelistWithdrawals(address[],uint256[],address[])";
        address[] memory whos = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        address[] memory tokens = new address[](1);

        whos[0] = address(proposal);
        amounts[0] = type(uint256).max;
        tokens[0] = address(yUSDC);

        calldatas[0] = abi.encode(whos, amounts, tokens);

        yamHelper.getQuorum(yamDelegator, proposer);
        vm.roll(block.number + 1);

        // ---- 
        address yamAddr = address(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);
        yamHelper.write_balanceOf(yamAddr, proposer, 210000 * 10**24);
    
        YAMGovernorAlpha gov = YAMGovernorAlpha(timelock.admin());
        uint256 votes = gov.getPriorVotes(proposer, block.number - 1);
        uint256 msgVotes = gov.getPriorVotes(address(msg.sender), block.number - 1);

        emit log_named_uint("blance", IERC20(yamAddr).balanceOf(proposer));
        emit log_named_address("proposer address", proposer);
        emit log_named_address("msg.sender address", address(msg.sender));
        emit log_named_uint("proposer votes", votes);
        emit log_named_uint("msg.sender votes", msgVotes);
        // ---- 

        rollProposal(targets, values, signatures, calldatas, description);

        proposal.execute();
        yamHelper.ff(61 minutes);

        // Assert reserves have the yUSDC we should have.
        assertTrue(IERC20(address(yUSDC)).balanceOf(address(reserves)) > 800000 * (10**6));

        // Assert no USDC or yUSDC was left in the proposal.
        assertEq(IERC20(USDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDC).balanceOf(address(proposal)), 0);
    }
}
