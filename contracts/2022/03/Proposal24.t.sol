// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "../../../utils/YAMTest.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {YAMDelegate3} from "../../../utils/YAMDelegate3.sol";
import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {Proposal24} from "./Proposal24.sol";


interface YYCRV {
  function deposit(uint256 _amount) external;
  function withdraw(uint256 shares) external;
}

contract Proposal24test is YAMTest {
    Proposal24 private proposal;

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
    address public constant yyCRV = 0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c;
    address public constant yCRV = 0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8;
    address public constant crvstETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address public constant steCRV = 0x06325440D014e39736583c165C2963BA99fAf14E;
    address public constant ystETH = 0xdCD90C7f6324cfa40d7169ef80b12031770B4325;

    function setUp() public {
        setUpYAMTest();
        proposal = new Proposal24();
    }

    function test_proposal_24() public {
        address[] memory targets = new address[](2);
        uint256[] memory values = new uint256[](2);
        string[] memory signatures = new string[](2);
        bytes[] memory calldatas = new bytes[](2);
        string
            memory description = "Contributors comps for February, vesting pool streams updates, settling synths tokens and success tokens, sending settled and rewards tokens to reserves, claiming sushi for reserves and converting all usdc to yusdc";

        // Set proposal as sub gov for vestingPool
        targets[0] = address(vestingPool);
        signatures[0] = "setSubGov(address,bool)";
        calldatas[0] = abi.encode(address(proposal), true);

        // Whitelist proposal to withdraw usdc
        targets[1] = address(reserves);
        signatures[1] = "whitelistWithdrawals(address[],uint256[],address[])";
        address[] memory whos = new address[](3);
        uint256[] memory amounts = new uint256[](3);
        address[] memory tokens = new address[](3);

        whos[0] = address(proposal);
        amounts[0] = type(uint256).max;
        tokens[0] = address(USDC);

        whos[1] = address(proposal);
        amounts[1] = type(uint256).max;
        tokens[1] = address(yyCRV);

        whos[2] = address(proposal);
        amounts[2] = type(uint256).max;
        tokens[2] = address(WETH);

        calldatas[1] = abi.encode(whos, amounts, tokens);

        // Get quorum for test proposal
        getQuorum(yamV3, proposer);
        vm.roll(block.number + 1);

        // Post, vote and execute proposal
        rollProposal(targets, values, signatures, calldatas, description);
        vm.roll(block.number + 1);
        proposal.execute();
        proposal.executeStep2();
        ff(61 minutes);

        // Reserves should have the WETH we should have
        assertTrue(IERC20(WETH).balanceOf(address(reserves)) > 138000000000000000000);

        // Reserves should have the ystETH we should have
        assertTrue(IERC20(ystETH).balanceOf(address(reserves)) > 123000000000000000000);

        // Reserves should have the yUSDC we should have
        assertTrue(IERC20(yUSDC).balanceOf(address(reserves)) > 1560000000000);

        // Reserves should have the USDC we should have
        assertEq(IERC20(USDC).balanceOf(address(reserves)), 100000000000);

        // No USDC or yUSDC should be left in the proposal
        assertEq(IERC20(USDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDCV2).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDC).balanceOf(address(proposal)), 0);

    }

}
