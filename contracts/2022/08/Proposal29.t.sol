// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "../../../utils/YAMTest.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {ISablier} from "../../../utils/Sablier.sol";
import {YAMDelegate3} from "../../../utils/YAMDelegate3.sol";
import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {Proposal29} from "./Proposal29.sol";

interface YYCRV {
    function deposit(uint256 _amount) external;

    function withdraw(uint256 shares) external;
}

interface IETHDPIStaking {
    function _exitStaking() external;

    function _getTokenFromHere(address token) external;
}

contract Proposal29test is YAMTest {
    Proposal29 private proposal;

    IERC20 internal constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant YAM =
        IERC20(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);
    IERC20 internal constant DPI =
        IERC20(0x1494CA1F11D487c2bBe4543E90080AeBa4BA3C2b);
    IERC20 internal constant GTC =
        IERC20(0xDe30da39c46104798bB5aA3fe8B9e0e1F348163F);
    IERC20 internal constant UMA =
        IERC20(0x04Fa0d235C4abf4BcF4787aF4CF447DE572eF828);
    IERC20 internal constant INDEX =
        IERC20(0x0954906da0Bf32d5479e25f46056d22f08464cab);
    IERC20 internal constant SUSHI =
        IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    IERC20 internal constant XSUSHI =
        IERC20(0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272);
    IERC20 internal constant ETHDPILP =
        IERC20(0x4d5ef58aAc27d99935E5b6B4A6778ff292059991);
    IETHDPIStaking internal ethdpiStaking =
        IETHDPIStaking(0x205Cc7463267861002b27021C7108Bc230603d0F);
    ISablier internal constant Sablier =
        ISablier(0xCD18eAa163733Da39c232722cBC4E8940b1D8888);
    address internal constant RESERVES =
        0x97990B693835da58A281636296D2Bf02787DEa17;
    address internal constant MULTISIG =
        0x744D16d200175d20E6D8e5f405AEfB4EB7A962d1;
    address internal constant INCENTIVIZER =
        0xD67c05523D8ec1c60760Fd017Ef006b9F6e496D0;
    address internal constant twoKeyContract =
        0x8348c5EC31D486e6E4207fC0B17a906A0806550d;

    function setUp() public {
        setUpYAMTest();
        proposal = new Proposal29();
    }

    function test_proposal_29() public {
        address[] memory targets = new address[](7);
        uint256[] memory values = new uint256[](7);
        string[] memory signatures = new string[](7);
        bytes[] memory calldatas = new bytes[](7);
        string
            memory description = "Contributors comps for August, opening new streams, yam previous payouts, treasury tokens rebalancing on multisig and claiming sushi for reserves.";

        // Whitelist proposal for withdrawals
        targets[0] = address(reserves);
        signatures[0] = "whitelistWithdrawals(address[],uint256[],address[])";
        address[] memory whos = new address[](9);
        uint256[] memory amounts = new uint256[](9);
        address[] memory tokens = new address[](9);

        whos[0] = address(proposal);
        amounts[0] = type(uint256).max;
        tokens[0] = address(USDC);

        whos[1] = address(proposal);
        amounts[1] = type(uint256).max;
        tokens[1] = address(YAM);

        whos[2] = address(proposal);
        amounts[2] = type(uint256).max;
        tokens[2] = address(DPI);

        whos[3] = address(proposal);
        amounts[3] = type(uint256).max;
        tokens[3] = address(GTC);

        whos[4] = address(proposal);
        amounts[4] = type(uint256).max;
        tokens[4] = address(UMA);

        whos[5] = address(proposal);
        amounts[5] = type(uint256).max;
        tokens[5] = address(INDEX);

        whos[6] = address(proposal);
        amounts[6] = type(uint256).max;
        tokens[6] = address(SUSHI);

        whos[7] = address(proposal);
        amounts[7] = type(uint256).max;
        tokens[7] = address(XSUSHI);

        whos[8] = address(proposal);
        amounts[8] = type(uint256).max;
        tokens[8] = address(ETHDPILP);

        calldatas[0] = abi.encode(whos, amounts, tokens);

        // Claim sushi rewards from incentivizer
        targets[1] = address(INCENTIVIZER);
        signatures[1] = "sushiToReserves(uint256)";
        calldatas[1] = abi.encode(type(uint256).max);

        // Stream minting yam
        uint256 totalToMatchOld = (116647 * (10**18)) -
            IERC20(YAM).balanceOf(address(reserves));
        uint256 totalToMatch = (19125 + 10413) * (10**18);
        targets[2] = address(yamV3);
        signatures[2] = "mint(address,uint256)";
        calldatas[2] = abi.encode(
            address(proposal),
            totalToMatchOld + totalToMatch
        );

        // Withdraw all uma from twoKeyContract
        targets[3] = address(twoKeyContract);
        signatures[3] = "withdrawErc20(address,uint256)";
        calldatas[3] = abi.encode(
            address(UMA),
            IERC20(address(UMA)).balanceOf(address(twoKeyContract))
        );

        // Transfer uma to reserves
        targets[4] = address(UMA);
        signatures[4] = "transfer(address,uint256)";
        calldatas[4] = abi.encode(address(RESERVES), 41857958515969183997479);

        // Transfer index to reserves
        targets[5] = address(INDEX);
        signatures[5] = "transfer(address,uint256)";
        calldatas[5] = abi.encode(
            address(RESERVES),
            IERC20(address(INDEX)).balanceOf(address(timelock))
        );

        // Whitelist proposal for ethdpiStaking
        targets[6] = address(ethdpiStaking);
        signatures[6] = "setIsSubGov(address,bool)";
        calldatas[6] = abi.encode(address(proposal), true);

        // Get quorum for test proposal
        getQuorum(yamV3, proposer);
        bing();

        // Post, vote and execute proposal
        rollProposal(targets, values, signatures, calldatas, description);
        bing();

        proposal.execute();
        proposal.executeStreams();
        ff(61 minutes);

        // Multisig should have a portion of the DPI
        assertEq(
            IERC20(DPI).balanceOf(address(MULTISIG)),
            2050000000000000000000
        );

        // Multisig should have all the GTC
        assertEq(
            IERC20(GTC).balanceOf(address(MULTISIG)),
            5817000000000000000000
        );

        // Multisig should have all the UMA
        assertEq(
            IERC20(UMA).balanceOf(address(MULTISIG)),
            41857958515969183997479
        );

        // Multisig should have all the INDEX
        assertEq(
            IERC20(INDEX).balanceOf(address(MULTISIG)),
            17183288216747829755723
        );

        // Multisig should have all the SUSHI
        assertTrue(
            IERC20(SUSHI).balanceOf(address(MULTISIG)) > 5270000000000000000000
        );

        // Multisig should have all the XSUSHI
        assertTrue(
            IERC20(XSUSHI).balanceOf(address(MULTISIG)) >
                34000000000000000000000
        );

        // Multisig should have all the ETHDPILP
        assertEq(
            IERC20(ETHDPILP).balanceOf(address(MULTISIG)),
            326523965960486790664
        );

        // Reserves should have the sushi we should have
        assertEq(IERC20(SUSHI).balanceOf(address(reserves)), 0);

        // // Reserves should have the USDC we should have
        // assertTrue(IERC20(USDC).balanceOf(address(reserves)) > 65000000000);

        // Reserves should have the yUSDC we should have
        assertTrue(IERC20(yUSDC).balanceOf(address(reserves)) > 1430000000000);

        // Reserves should have the yam we should have
        assertEq(IERC20(YAM).balanceOf(address(reserves)), 0);

        // No WETH, YAM, USDC, yUSDC or any other tokens should be left in the proposal
        assertEq(IERC20(WETH).balanceOf(address(proposal)), 0);
        assertEq(IERC20(YAM).balanceOf(address(proposal)), 0);
        assertEq(IERC20(USDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(DPI).balanceOf(address(proposal)), 0);
        assertEq(IERC20(GTC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(UMA).balanceOf(address(proposal)), 0);
        assertEq(IERC20(INDEX).balanceOf(address(proposal)), 0);
        assertEq(IERC20(SUSHI).balanceOf(address(proposal)), 0);
        assertEq(IERC20(XSUSHI).balanceOf(address(proposal)), 0);
        assertEq(IERC20(ETHDPILP).balanceOf(address(proposal)), 0);
    }
}
