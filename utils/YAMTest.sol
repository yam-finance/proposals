// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "./YAMHelper.sol";
import "./YAMDelegator.sol";
import "./VestingPool.sol";

interface Vm {
    function warp(uint) external;
    function roll(uint) external;
    function store(address,bytes32,bytes32) external;
    function load(address,bytes32) external returns (bytes32);
}

interface Timelock {
    function admin() external returns (address);
    function delay() external returns (uint256);
}

interface YAMGovernorAlpha {
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    function latestProposalIds(address proposer) external returns (uint256);

    function propose(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256); 

    function queue(uint256 proposalId) external ;

    function execute(uint256 proposalId) external payable;

    function castVote(uint256 proposalId, bool support) external;

    function state(uint256 proposalId) external view returns (ProposalState);
    function getPriorVotes(address account, uint256 blockNumber) external returns (uint256);
}

interface YAMReserves {}


contract YAMTest is YAMHelper {
    Timelock internal timelock = Timelock(0x8b4f1616751117C38a0f84F9A146cca191ea3EC5);
    YAMReserves internal reserves = YAMReserves(0x97990B693835da58A281636296D2Bf02787DEa17);
    YAMDelegator internal yamV3 = YAMDelegator(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);
    VestingPool internal vestingPool = VestingPool(0xDCf613db29E4d0B35e7e15e93BF6cc6315eB0b82);
    address internal constant yUSDCV2 = address(0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9);
    address internal constant yUSDC = address(0xa354F35829Ae975e850e23e9615b11Da1B3dC4DE);
    address internal constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address internal proposer;
    Vm internal vm;

    function setUpYAMTest() internal {
        vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        proposer = address(this);
        addKnown(address(yamV3), "pendingGov()", 4);
        addKnown(address(yamV3), "totalSupply()", 8);
        addKnown(address(yamV3), "balanceOfUnderlying(address)", 10);
        addKnown(address(yamV3), "initSupply()", 12);
        addKnown(address(yamV3), "checkpoints(address,uint32)", 15);
        addKnown(address(yamV3), "numCheckpoints(address)", 16);
        // 0 out balance
        writeBoU(yamV3, proposer, 0);
    }

    function rollProposal(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    )
        internal
    {
        YAMGovernorAlpha gov = YAMGovernorAlpha(timelock.admin());

        gov.propose(
            targets,
            values,
            signatures,
            calldatas,
            description
        );

        uint256 id = gov.latestProposalIds(proposer);

        voteOnLatestProposal();

        vm.roll(block.number +  12345);

        YAMGovernorAlpha.ProposalState state = gov.state(id);

        assertTrue(state == YAMGovernorAlpha.ProposalState.Succeeded);

        gov.queue(id);

        vm.warp(block.timestamp + timelock.delay());

        gov.execute(id);
    }

    function voteOnLatestProposal() public {
        vm.roll(block.number + 10);
        YAMGovernorAlpha gov = YAMGovernorAlpha(timelock.admin());
        uint256 id = gov.latestProposalIds(proposer);
        gov.castVote(id, true);
    }
}