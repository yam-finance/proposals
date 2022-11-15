// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "../../../utils/YAMTest.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {ISablier} from "../../../utils/Sablier.sol";
import {YAMDelegate3} from "../../../utils/YAMDelegate3.sol";
import {YAMTokenInterface} from "../../../utils/YAMTokenInterface.sol";
import {Proposal33} from "./Proposal33.sol";
import {YamRedeemer} from "./TreasuryRedeem.sol";

interface YYCRV {
    function deposit(uint256 _amount) external;

    function withdraw(uint256 shares) external;
}

contract Proposaltest is YAMTest {
    Proposal33 private proposal;
    YamRedeemer private redeemer;

    IERC20 internal constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant WBTC =
        IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20 internal constant YAM =
        IERC20(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);
    IERC20 internal constant YAMSLP =
        IERC20(0x0F82E57804D0B1F6FAb2370A43dcFAd3c7cB239c);
    IERC20 internal constant SUSHI =
        IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    IERC20 internal constant DPI =
        IERC20(0x1494CA1F11D487c2bBe4543E90080AeBa4BA3C2b);
    IERC20 internal constant ystETH =
        IERC20(0xdCD90C7f6324cfa40d7169ef80b12031770B4325);
    IERC20 internal constant UMA =
        IERC20(0x04Fa0d235C4abf4BcF4787aF4CF447DE572eF828);
    YAMTokenInterface internal constant YAMV3 =
        YAMTokenInterface(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);
    ISablier internal constant Sablier =
        ISablier(0xCD18eAa163733Da39c232722cBC4E8940b1D8888);
    address internal constant twoKeyContract =
        0x8348c5EC31D486e6E4207fC0B17a906A0806550d;
    address internal constant RESERVES =
        0x97990B693835da58A281636296D2Bf02787DEa17;
    address internal constant MULTISIG =
        0x744D16d200175d20E6D8e5f405AEfB4EB7A962d1;
    address internal constant INCENTIVIZER =
        0xD67c05523D8ec1c60760Fd017Ef006b9F6e496D0;

    address internal constant charity1 =
        0x0000000000000000000000000000000000000001;
    address internal constant charity2 =
        0x0000000000000000000000000000000000000002;

    function setUp() public {
        setUpYAMTest();
        proposal = new Proposal33();

        address[] memory tokens = new address[](7);
        tokens[0] = address(WETH);
        tokens[1] = address(WBTC);
        tokens[2] = address(DPI);
        tokens[3] = address(USDC);
        tokens[4] = address(yUSDC);
        tokens[5] = address(ystETH);
        tokens[6] = address(UMA);
        address[] memory charities = new address[](2);
        charities[0] = address(charity1);
        charities[1] = address(charity2);
        redeemer = new YamRedeemer(
            address(YAM),
            tokens,
            charities,
            14586738954685070682848328
        );
    }

    function test_proposal_33() public {
        address[] memory targets = new address[](6);
        uint256[] memory values = new uint256[](6);
        string[] memory signatures = new string[](6);
        bytes[] memory calldatas = new bytes[](6);
        string
            memory description = "Contributors comps for October, treasury redemption.";

        // Whitelist proposal for withdrawals
        targets[0] = address(reserves);
        signatures[0] = "whitelistWithdrawals(address[],uint256[],address[])";
        address[] memory whos = new address[](10);
        uint256[] memory amounts = new uint256[](10);
        address[] memory tokens = new address[](10);

        whos[0] = address(proposal);
        amounts[0] = type(uint256).max;
        tokens[0] = address(WETH);

        whos[1] = address(proposal);
        amounts[1] = type(uint256).max;
        tokens[1] = address(WBTC);

        whos[2] = address(proposal);
        amounts[2] = type(uint256).max;
        tokens[2] = address(DPI);

        whos[3] = address(proposal);
        amounts[3] = type(uint256).max;
        tokens[3] = address(USDC);

        whos[4] = address(proposal);
        amounts[4] = type(uint256).max;
        tokens[4] = address(yUSDC);

        whos[5] = address(proposal);
        amounts[5] = type(uint256).max;
        tokens[5] = address(ystETH);

        whos[6] = address(proposal);
        amounts[6] = type(uint256).max;
        tokens[6] = address(YAMSLP);

        whos[7] = address(proposal);
        amounts[7] = type(uint256).max;
        tokens[7] = address(YAM);

        whos[8] = address(proposal);
        amounts[8] = type(uint256).max;
        tokens[8] = address(UMA);

        whos[9] = address(proposal);
        amounts[9] = type(uint256).max;
        tokens[9] = address(SUSHI);

        calldatas[0] = abi.encode(whos, amounts, tokens);

        // Claim sushi rewards from incentivizer
        targets[1] = address(INCENTIVIZER);
        signatures[1] = "sushiToReserves(uint256)";
        calldatas[1] = abi.encode(type(uint256).max);

        // Minting yam
        uint256 totalToMatch = (44199 + 37292 + 9392) * (10**18);
        targets[2] = address(yamV3);
        signatures[2] = "mint(address,uint256)";
        calldatas[2] = abi.encode(address(proposal), totalToMatch);

        // Withdraw UMA from twoKeyContract
        targets[3] = address(twoKeyContract);
        signatures[3] = "withdrawErc20(address,uint256)";
        calldatas[3] = abi.encode(
            address(UMA),
            IERC20(UMA).balanceOf(twoKeyContract)
        );

        // Transfer UMA to reserves
        targets[4] = address(UMA);
        signatures[4] = "transfer(address,uint256)";
        calldatas[4] = abi.encode(address(RESERVES), 43247684522568207410183);

        // Update to 30 days
        targets[5] = address(timelock);
        signatures[5] = "setDelay(uint256)";
        calldatas[5] = abi.encode(uint256(2592000), true);

        // Get quorum for test proposal
        getQuorum(yamV3, proposer);
        bing();

        // Post, vote and execute proposal
        rollProposal(targets, values, signatures, calldatas, description);
        bing();

        proposal.execute();
        proposal.executeStreams();
        ff(61 minutes);

        // Approve Redeemer and redeem 100k YAM
        YAM.approve(address(redeemer), type(uint256).max);
        redeemer.redeem(address(this), 100000 * (10**18));

        // Charity donation
        ff(366 days);
        redeemer.donate();

        // User should have tokens after redemption
        assertTrue(IERC20(WETH).balanceOf(address(this)) < 6500000000000000000);
        assertTrue(IERC20(WBTC).balanceOf(address(this)) < 2000000);
        assertTrue(IERC20(DPI).balanceOf(address(this)) < 15000000000000000000);
        assertTrue(IERC20(USDC).balanceOf(address(this)) < 600000000);
        assertTrue(IERC20(yUSDC).balanceOf(address(this)) < 10000000000);
        assertTrue(
            IERC20(ystETH).balanceOf(address(this)) < 900000000000000000
        );
        assertTrue(
            IERC20(UMA).balanceOf(address(this)) < 300000000000000000000
        );

        // Charity 1 should have the allocated tokens percentage (0.385)
        assertTrue(
            IERC20(WETH).balanceOf(address(charity1)) > 300000000000000000000
        );
        assertTrue(IERC20(WBTC).balanceOf(address(charity1)) > 78000000);
        assertTrue(
            IERC20(DPI).balanceOf(address(charity1)) > 680000000000000000000
        );
        assertTrue(IERC20(USDC).balanceOf(address(charity1)) > 40000000000);
        assertTrue(IERC20(yUSDC).balanceOf(address(charity1)) > 540000000000);
        assertTrue(
            IERC20(ystETH).balanceOf(address(charity1)) > 46000000000000000000
        );
        assertTrue(
            IERC20(UMA).balanceOf(address(charity1)) > 16000000000000000000000
        );

        // Charity 2 should have the allocated tokens percentage (0.615)
        assertTrue(
            IERC20(WETH).balanceOf(address(charity2)) > 510000000000000000000
        );
        assertTrue(IERC20(WBTC).balanceOf(address(charity2)) > 120000000);
        assertTrue(
            IERC20(DPI).balanceOf(address(charity2)) > 1000000000000000000000
        );
        assertTrue(IERC20(USDC).balanceOf(address(charity2)) > 30000000000);
        assertTrue(IERC20(yUSDC).balanceOf(address(charity2)) > 870000000000);
        assertTrue(
            IERC20(ystETH).balanceOf(address(charity2)) > 74000000000000000000
        );
        assertTrue(
            IERC20(UMA).balanceOf(address(charity2)) > 26000000000000000000000
        );

        // Redemption contract should have no tokens
        assertTrue(IERC20(WETH).balanceOf(address(redeemer)) < 100);
        assertTrue(IERC20(WBTC).balanceOf(address(redeemer)) < 100);
        assertTrue(IERC20(DPI).balanceOf(address(redeemer)) < 100);
        assertTrue(IERC20(USDC).balanceOf(address(redeemer)) < 100);
        assertTrue(IERC20(yUSDC).balanceOf(address(redeemer)) < 100);
        assertTrue(IERC20(ystETH).balanceOf(address(redeemer)) < 100);
        assertTrue(IERC20(UMA).balanceOf(address(redeemer)) < 100);

        // No tokens should be left in the proposal
        assertEq(IERC20(WETH).balanceOf(address(proposal)), 0);
        assertEq(IERC20(YAM).balanceOf(address(proposal)), 0);
        assertEq(IERC20(USDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(yUSDC).balanceOf(address(proposal)), 0);
        assertEq(IERC20(YAMSLP).balanceOf(address(proposal)), 0);
    }
}
