// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "../../../utils/YAMTest.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {YAMDelegate3} from "../../../utils/YAMDelegate3.sol";
import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {Proposal25} from "./Proposal25.sol";

interface YYCRV {
    function deposit(uint256 _amount) external;
    function withdraw(uint256 shares) external;
}

contract Proposal25test is YAMTest {
    Proposal25 private proposal;

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
    IERC20 internal constant SCJAN6 =
        IERC20(0x0B4470515228625ef51E6DB32699989046fCE4De);
    IERC20 internal constant SCDEC2 =
        IERC20(0xf447EF251De50E449107C8D687d10C91e0b7e4D4);
    IERC20 internal constant SCNOV3 =
        IERC20(0xff8f62855fD433347BbE62f1292F905f7aC1DF9d);
    IUSynthFarming internal UGASFarming =
        IUSynthFarming(0xDFE435ade40Bbf7476a0847d5ae6B1df9BD5Ba30);
    IUSynthFarming internal USTONKSFarming =
        IUSynthFarming(0x9789204c43bbc03E9176F2114805B68D0320B31d);
    IUSynthFarming internal UPUNKSFarming =
        IUSynthFarming(0xA5163cE5331413715c1023f28499cbdC9a8b8b3E);

    function setUp() public {
        setUpYAMTest();
        proposal = new Proposal25();
    }

    function test_proposal_25() public {
        address[] memory targets = new address[](7);
        uint256[] memory values = new uint256[](7);
        string[] memory signatures = new string[](7);
        bytes[] memory calldatas = new bytes[](7);
        string
            memory description = "Contributors comps for April, exit UGAS USTONKS UPUNKS positions, claiming all reward tokens from synths farms, transfer yam from vesting pool to reserves, transfer yam tokens to mainnet multisig, mint and send yam to reserves and claim rewards for reserves.";

        // Set proposal as sub gov for vestingPool
        targets[0] = address(vestingPool);
        signatures[0] = "setSubGov(address,bool)";
        calldatas[0] = abi.encode(address(proposal), true);

        targets[1] = address(INCENTIVIZER);
        signatures[1] = "sushiToReserves(uint256)";
        calldatas[1] = abi.encode(type(uint256).max);

        // Whitelist proposal to withdraw usdc
        targets[2] = address(reserves);
        signatures[2] = "whitelistWithdrawals(address[],uint256[],address[])";
        address[] memory whos = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        address[] memory tokens = new address[](1);

        whos[0] = address(proposal);
        amounts[0] = type(uint256).max;
        tokens[0] = address(USDC);

        calldatas[2] = abi.encode(whos, amounts, tokens);

        targets[3] = address(UGASFarming);
        signatures[3] = "setIsSubGov(address,bool)";
        calldatas[3] = abi.encode(address(proposal), true);

        targets[4] = address(USTONKSFarming);
        signatures[4] = "setIsSubGov(address,bool)";
        calldatas[4] = abi.encode(address(proposal), true);

        targets[5] = address(UPUNKSFarming);
        signatures[5] = "setIsSubGov(address,bool)";
        calldatas[5] = abi.encode(address(proposal), true);

        targets[6] = address(yamV3);
        signatures[6] = "mint(address,uint256)";
        calldatas[6] = abi.encode(address(proposal), 370000 * (10**18));

        // Get quorum for test proposal
        getQuorum(yamV3, proposer);
        bing();

        // Post, vote and execute proposal
        rollProposal(targets, values, signatures, calldatas, description);
        bing();

        proposal.execute();
        ff(720 minutes);

        UGASFarming.update_twap();
        UPUNKSFarming.update_twap();
        ff(61 minutes);

        UGASFarming.exit();
        UPUNKSFarming.exit();

        // Reserves should have the weth we should have
        assertTrue(
            IERC20(WETH).balanceOf(address(reserves)) > 540000000000000000000
        );

        // Reserves should have the yam we should have
        assertTrue(
            IERC20(YAM).balanceOf(address(reserves)) > 270000000000000000000000
        );

        // Reserves should have the uma we should have
        assertEq(
            IERC20(UMA).balanceOf(address(reserves)),
            30860162972362817448015
        );

        // Reserves should have the sushi rewards
        assertTrue(
            IERC20(SUSHI).balanceOf(address(reserves)) > 4600000000000000000000
        );

        // Reserves should have the yUSDC we should have
        assertTrue(IERC20(yUSDC).balanceOf(address(reserves)) > 1560000000000);

        // Reserves should have the USDC we should have
        assertTrue(IERC20(USDC).balanceOf(address(reserves)) > 67000000000);

        // Reserves should have the synths success tokens we should have
        assertEq(
            IERC20(SCJAN6).balanceOf(address(reserves)),
            4092365051836079280568
        );
        assertEq(
            IERC20(SCDEC2).balanceOf(address(reserves)),
            4006124534396574916305
        );
        assertEq(
            IERC20(SCNOV3).balanceOf(address(reserves)),
            1796702909564921172554
        );

        // No USDC or yUSDC should be left in the proposal
        assertEq(IERC20(USDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDCV2).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDC).balanceOf(address(proposal)), 0);
    }

}

interface IUSynthFarming {
    function _approveEnter() external;
    function _approveExit() external;
    function _getTokenFromHere(address token) external;
    function update_twap() external;
    function enter() external;
    function exit() external;
}