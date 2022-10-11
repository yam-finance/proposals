// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "../../../utils/YAMTest.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {ISablier} from "../../../utils/Sablier.sol";
import {YAMDelegate3} from "../../../utils/YAMDelegate3.sol";
import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {Proposal32} from "./Proposal32.sol";

interface YYCRV {
    function deposit(uint256 _amount) external;

    function withdraw(uint256 shares) external;
}

interface IIncentivizer {
    function breaker() external view returns (bool);

    function setBreaker(bool breaker_) external;
}

contract Proposaltest is YAMTest {
    Proposal32 private proposal;

    IERC20 internal constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant YAM =
        IERC20(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);
    IERC20 internal constant YAMSLP =
        IERC20(0x0F82E57804D0B1F6FAb2370A43dcFAd3c7cB239c);
    IERC20 internal constant SUSHI =
        IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    IIncentivizer incentivizer =
        IIncentivizer(0xD67c05523D8ec1c60760Fd017Ef006b9F6e496D0);
    ISablier internal constant Sablier =
        ISablier(0xCD18eAa163733Da39c232722cBC4E8940b1D8888);
    address internal constant RESERVES =
        0x97990B693835da58A281636296D2Bf02787DEa17;
    address internal constant MULTISIG =
        0x744D16d200175d20E6D8e5f405AEfB4EB7A962d1;
    address internal constant INCENTIVIZER =
        0xD67c05523D8ec1c60760Fd017Ef006b9F6e496D0;

    function setUp() public {
        setUpYAMTest();
        proposal = new Proposal32();
    }

    function test_proposal_32() public {
        address[] memory targets = new address[](4);
        uint256[] memory values = new uint256[](4);
        string[] memory signatures = new string[](4);
        bytes[] memory calldatas = new bytes[](4);
        string
            memory description = "Contributors comps for September, creating protocol owned liquidity, stopping incentivizer rewards and claiming sushi for reserves.";

        // Whitelist proposal for withdrawals
        targets[0] = address(reserves);
        signatures[0] = "whitelistWithdrawals(address[],uint256[],address[])";
        address[] memory whos = new address[](2);
        uint256[] memory amounts = new uint256[](2);
        address[] memory tokens = new address[](2);

        whos[0] = address(proposal);
        amounts[0] = type(uint256).max;
        tokens[0] = address(USDC);

        whos[1] = address(proposal);
        amounts[1] = type(uint256).max;
        tokens[1] = address(WETH);

        calldatas[0] = abi.encode(whos, amounts, tokens);

        // Claim sushi rewards from incentivizer
        targets[1] = address(INCENTIVIZER);
        signatures[1] = "sushiToReserves(uint256)";
        calldatas[1] = abi.encode(type(uint256).max);

        // Minting yam
        uint256 totalToMatch = (110150 + 7411 + 19173 + 25564 + 2600000) * (10**18);
        targets[2] = address(yamV3);
        signatures[2] = "mint(address,uint256)";
        calldatas[2] = abi.encode(address(proposal), totalToMatch);

        // Stop incentivizer rewards
        targets[3] = address(INCENTIVIZER);
        signatures[3] = "setBreaker(bool)";
        calldatas[3] = abi.encode(true);

        // Get quorum for test proposal
        getQuorum(yamV3, proposer);
        bing();

        // Post, vote and execute proposal
        rollProposal(targets, values, signatures, calldatas, description);
        bing();

        proposal.execute();
        proposal.executeStreams();
        proposal.createPOL(
            2175660000000000000000000,
            230000000000000000000,
            2072057142857142700000000,
            219047619047619040000
        );
        ff(61 minutes);

        // Incentivizer rewards should be stopped
        assertTrue(incentivizer.breaker() == true);

        // Reserves should have the YAMSLP we should have
        assertTrue(
            IERC20(YAMSLP).balanceOf(address(reserves)) > 2000000000000000
        );

        // Reserves should have the weth we should have
        assertTrue(
            IERC20(WETH).balanceOf(address(reserves)) > 500000000000000000000
        );

        // Reserves should have the USDC we should have
        assertTrue(IERC20(USDC).balanceOf(address(reserves)) > 60000000000);

        // No WETH, YAM, USDC, yUSDC, YAMSLP should be left in the proposal
        assertEq(IERC20(WETH).balanceOf(address(proposal)), 0);
        assertEq(IERC20(YAM).balanceOf(address(proposal)), 0);
        assertEq(IERC20(USDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(YAMSLP).balanceOf(address(proposal)), 0);
    }
}
