// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "forge-std/stdlib.sol";
import "forge-std/Vm.sol";

import {ERC20VotesComp} from "@openzeppelin/contracts/governance/extensions/GovernorVotesComp.sol";
import {ICompoundTimelock} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockCompound.sol";
import {YamGovernor} from "./YamGovernor.sol";

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
}

contract YamGovernorTest is DSTest, stdCheats {
    using stdStorage for StdStorage;

    Vm internal constant vm = Vm(HEVM_ADDRESS);
    ERC20VotesComp internal constant yam = ERC20VotesComp(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);
    ICompoundTimelock internal constant timelock = ICompoundTimelock(payable(0x8b4f1616751117C38a0f84F9A146cca191ea3EC5));

    StdStorage internal stdstore;
    YamGovernor internal governor;

    function setUp() public {
        governor = new YamGovernor(yam, timelock);
    }

    function testContractBalance() public {
        vm.record();
        yam.balanceOf(address(this));
        (bytes32[] memory reads, ) = vm.accesses(address(yam));

        for (uint256 i = 0; i <= reads.length; i++) {
            emit log_bytes32(reads[i]);
        }

        vm.store(address(yam), reads[1], bytes32(uint256(1e24)));
        assert(yam.balanceOf(address(this)) == 1e24);
    }
}
