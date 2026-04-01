pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault ;
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address attacker = makeAddr("attacker");

       receive() external payable {}

    function setUp() public {
        vault = new Vault();
        vm.deal(user1,10 ether);
        vm.deal(user2,10 ether);
    }

    function test_User1CanDeposit() public {
        vm.prank(user1);
        vault.deposit{value:1 ether}();

        assertEq(vault.balances(user1),1 ether);
    }

    function test_MultipleUsers() public {
        vm.startPrank(user1);
        vault.deposit{value:1 ether}();
        vm.stopPrank();

        vm.prank(user2);
        vault.deposit{value:2 ether}();

        assertEq(vault.balances(user1),1 ether);
        assertEq(vault.balances(user2),2 ether);
    }

    function test_OnlyOwnerCanEmergencyWithdraw() public {
        vm.prank(attacker);
        vm.expectRevert("Not owner");
        vault.emergencyWithdraw();
    }

    function test_OwnerEmergencyWithdraw() public {
        address owner = vault.owner();

        vm.prank(user1);vault.deposit{value:1 ether}();

        uint256 initialBalance = address(this).balance;

        vm.prank(owner);
        vault.emergencyWithdraw();

        assertEq(address(vault).balance,0);
    }
}

contract VaultTimeTest is Test {
    Vault public vault ;
    address user = makeAddr("user");

    function setUp() public {
        vault = new Vault();
        vm.deal(user, 10 ether);

        vm.warp(1000);
        vm.roll(100);
    }

    function test_WithdrawAfterLockPeriod() public {
        vm.prank(user);
        vault.deposit{value:1 ether}();

        uint256 lockTime = vault.lockTime(user);
        assertEq(lockTime , 1000 + 7 days);

        vm.warp(lockTime);

        vm.prank(user);
        vault.withdraw(1 ether);

        assertEq(vault.balances(user),0);
    }

    function test_CannotWithdrawBeforeLockPeriod() public {
        vm.prank(user);
        vault.deposit{value:1 ether}();
        wm.warp(1000+6 days);
        wm.prank(user);
        wm.expectRevert("Locked");
        vault.withdraw(1 ether);
    }

    function test_WithdrawAtDifferentBlocks() public {

        vm.prank(user);
        vault.deposit{value : 1 ether};

        vm.roll(100);
        vm.prank(user);
        vm.expectRevert("Locked");
        vault.withdraw(1 ether);

        vm.warp(1000+8days);
        vm.roll(1000);

        vm.prank(user);
        vault.withdraw(1 ether);

        assertEq(vault.balances(user),0);
    }
}

contract VaultEventTest is Test{
    Vault public vault ;
    address user = makeAddr("user");

    function setUp() public {
        vault = new Vault();
        vm.deal(user,10 ether);
        vm.warp(1000);
    }

    function test_DepositEmitsEvent() public {
        vm.prank(user);

        vm.expectEmit(true,false,false,true);
        emit Deposited(user:1 ether);

        vault.deposit{value: 1 ether}();
    }

    function test_WithdrawEmitsEvent() public {
        vm.prank(user);
        vault.deposit{value:1 ether}();

        vm.warp(1000+8 days);

        vm.prank(user);

        vm.expectEmit(true , false , false , true);
        emit Withdrawn(user,0.5 ether);

        vault.withdraw(0.5 ether);
    }
}

contract VaultSnapshotTest is Test {
    Vault public vault ;
    address user = makeAddr("user");

    function setUp() public {
        vault = new Vault();
        vm.deal(user,10 ether);
        vm.warp(1000);
    }

    function test_SnapshotAndRevert() public {
        assertEq(address(vault).balance,0);

        uint256 snapshotId = vm.snapshot();

        vm.prank(user);
        vault.deposit{value : 1 ether}();
        assertEq(address(vault).balance, 1 ether);

        vm.revertTo(snapshotId);

        assertEq(address(vault).balance,0);
        assertEq(vault.balances(user),0);
    }

    function test_MultipleScenarios()public{}
}