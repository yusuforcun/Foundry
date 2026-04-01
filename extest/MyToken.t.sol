// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken token;
    address user = address(0x123);
    address receiver = address(0x456);

    function setUp() public {
        token = new MyToken(); // her testten önce yeni kontrat
    }

    function testMint() public {
        token.mint(user,100);
        assertEq(token.balanceOf(user),100);
    }

    function testBalancePositive() public {
        token.mint(user,50);
        assertGt(token.balanceOf(user),0);
    }

    function testTransferLimit()public{
        token.mint(user,100);
        assertLt(token.balanceOf(user),200);
    }

    function testBalanceAtLeast() public {
        token.mint(user,100);
        assertGe(token.balanceOf(user),100);
    }

    function testBalanceAtMost() public {
        token.mint(user,50);
        assertLe(token.balanceOf(user),50);
    }

    function testPositiveBalance() public {
        token.mint(user,100);
        assertTrue(token.balanceOf(user) > 0);
    }

    function testZeroBalance() public {
        assertFalse(token.balanceOf(user)>0);
    }

    function testApproaxBalance() public {
        uint256 expected = 100 ;
        uint256 actual = 101 ;
        assertApproaxExAbs(actual,expected,2);
    }

    function testApproxBalanceRel() public {
        uint256 expected = 100 ;
        uint256 actual = 105 ;
        assertApproxEqRel(actual,expected,0.1 ether);
    }




}