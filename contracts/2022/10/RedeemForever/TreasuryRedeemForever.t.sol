// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "../../../../utils/YAMTest.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {NewToken} from "../../../../utils/NewToken.sol";
import {TreasuryRedeemForever} from "./TreasuryRedeemForever.sol";

contract TreasuryRedeemForeverTest is YAMTest {
    NewToken private testYAM;
    NewToken private testWETH;
    NewToken private testWBTC;
    NewToken private testDPI;
    NewToken private testYSTETH;
    TreasuryRedeemForever private redeemer;

    uint256 private constant BASE = 10**18;
    uint256 private constant MINT_BASE = 15000000 * BASE;
    address private owner = address(this);
    address private user2 = address(50);
    uint256 private user2YAM = 100000 * BASE;

    function test_redeemer_forever() public {
        testYAM = new NewToken("TestYAM", "YAM");
        testWETH = new NewToken("TestWETH", "WETH");
        testWBTC = new NewToken("TestWBTC", "WBTC");
        testDPI = new NewToken("TestDPI", "DPI");
        testYSTETH = new NewToken("TestYSTETH", "YSTETH");

        address[] memory tokens = new address[](4);
        tokens[0] = address(testWETH);
        tokens[1] = address(testWBTC);
        tokens[2] = address(testDPI);
        tokens[3] = address(testYSTETH);

        redeemer = new TreasuryRedeemForever(address(testYAM), tokens, MINT_BASE);

        testYAM.mint(address(owner), MINT_BASE);
        testWETH.mint(address(redeemer), 641 * BASE);
        testWBTC.mint(address(redeemer), 2 * BASE);
        testDPI.mint(address(redeemer), 1820 * BASE);
        testYSTETH.mint(address(redeemer), 123 * BASE);

        // Redemption contract is deployed correctly
        (
            address[] memory tokensAddresses,
            uint256[] memory tokensAmounts
        ) = redeemer.previewRedeem(MINT_BASE);
        assertEq(redeemer._redeemBase(), MINT_BASE);

        // Tokens are deployed correctly
        assertEq(tokensAddresses.length, 4);
        assertEq(tokensAmounts.length, 4);
        assertEq(tokensAddresses[0], address(testWETH));
        assertEq(tokensAmounts[0], 641 * BASE);
        assertEq(tokensAddresses[1], address(testWBTC));
        assertEq(tokensAmounts[1], 2 * BASE);
        assertEq(tokensAddresses[2], address(testDPI));
        assertEq(tokensAmounts[2], 1820 * BASE);
        assertEq(tokensAddresses[3], address(testYSTETH));
        assertEq(tokensAmounts[3], 123 * BASE);

        // User redemption works
        uint256 amountToRedeem = 10000000 * BASE;
        testYAM.approve(address(redeemer), type(uint256).max);
        redeemer.redeem(owner, amountToRedeem);
        assertEq(testYAM.balanceOf(owner), 5000000000000000000000000);
        assertEq(
            testYAM.balanceOf(address(redeemer)),
            10000000000000000000000000
        );

        // Tokens are transferred to user after redemption
        assertEq(testWETH.balanceOf(owner), 427333333333333333333);
        assertEq(testWBTC.balanceOf(owner), 1333333333333333333);
        assertEq(testDPI.balanceOf(owner), 1213333333333333333333);
        assertEq(testYSTETH.balanceOf(owner), 82000000000000000000);

        // Redemption contract should have the tokens left
        assertEq(testWETH.balanceOf(address(redeemer)), 213666666666666666667);
        assertEq(testWBTC.balanceOf(address(redeemer)), 666666666666666667);
        assertEq(testDPI.balanceOf(address(redeemer)), 606666666666666666667);
        assertEq(testYSTETH.balanceOf(address(redeemer)), 41000000000000000000);

        // // Tokens are transferred to User2 after redemption of 100k testYAM
        // testYAM.transfer(user2, user2YAM);
        // hevm.startPrank(user2);
        // testYAM.approve(address(redeemer), type(uint256).max);
        // redeemer.redeem(user2, user2YAM);
        // assertEq(testYAM.balanceOf(user2), 0);
        // assertEq(testYAM.balanceOf(address(redeemer)), MINT_BASE);
        // assertEq(testWETH.balanceOf(user2), 641 * BASE);
        // assertEq(testWBTC.balanceOf(user2), 2 * BASE);
        // assertEq(testDPI.balanceOf(user2), 1820 * BASE);
        // assertEq(testWETH.balanceOf(address(redeemer)), 0);
        // assertEq(testWBTC.balanceOf(address(redeemer)), 0);
        // assertEq(testDPI.balanceOf(address(redeemer)), 0);
        // hevm.stopPrank();
    }
}
