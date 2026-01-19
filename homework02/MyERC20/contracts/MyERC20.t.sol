// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {MyERC20} from "./MyERC20.sol";
import {Test} from "forge-std/Test.sol";

contract MyERC20Test is Test {
    MyERC20 token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);
    
    uint256 constant INITIAL_SUPPLY = 1000000 * 10**18;
    string constant TOKEN_NAME = "MyERC20 Token";
    string constant TOKEN_SYMBOL = "MET";
    uint8 constant TOKEN_DECIMALS = 18;

    function setUp() public {
        vm.prank(owner);
        token = new MyERC20(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, INITIAL_SUPPLY / 10**18);
    }

    function test_InitialState() public view {
        // 测试代币基本信息
        assertEq(token.name(), TOKEN_NAME);
        assertEq(token.symbol(), TOKEN_SYMBOL);
        assertEq(token.decimals(), TOKEN_DECIMALS);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.owner(), owner);
        
        // 测试自动生成的 balanceOf 函数
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function test_Transfer() public {
        uint256 transferAmount = 1000 * 10**18;
        
        vm.prank(owner);
        bool success = token.transfer(user1, transferAmount);
        
        assertTrue(success);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - transferAmount);
        assertEq(token.balanceOf(user1), transferAmount);
    }

    function test_TransferInsufficientBalance() public {
        uint256 transferAmount = INITIAL_SUPPLY + 1;
        
        vm.prank(user1);
        vm.expectRevert("Insufficient balance");
        token.transfer(user2, transferAmount);
    }

    function test_ApproveAndTransferFrom() public {
        uint256 approveAmount = 500 * 10**18;
        uint256 transferAmount = 300 * 10**18;
        
        // 所有者授权给 user1
        vm.prank(owner);
        bool approveSuccess = token.approve(user1, approveAmount);
        assertTrue(approveSuccess);
        assertEq(token.allowance(owner, user1), approveAmount);
        
        // user1 使用 transferFrom 转账
        vm.prank(user1);
        bool transferFromSuccess = token.transferFrom(owner, user2, transferAmount);
        assertTrue(transferFromSuccess);
        
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - transferAmount);
        assertEq(token.balanceOf(user2), transferAmount);
        assertEq(token.allowance(owner, user1), approveAmount - transferAmount);
    }

    function test_MintFunction() public {
        uint256 mintAmount = 50000 * 10**18;
        
        // 只有所有者可以 mint
        vm.prank(owner);
        bool success = token.mint(user1, mintAmount);
        assertTrue(success);
        
        assertEq(token.totalSupply(), INITIAL_SUPPLY + mintAmount);
        assertEq(token.balanceOf(user1), mintAmount);
        
        // 非所有者尝试 mint 应该失败
        vm.prank(user1);
        vm.expectRevert("Only owner can call this function");
        token.mint(user2, 1000);
    }

    function test_TransferOwnership() public {
        // 所有者转移所有权
        vm.prank(owner);
        token.transferOwnership(user1);
        
        assertEq(token.owner(), user1);
        
        // 原所有者不能再 mint
        vm.prank(owner);
        vm.expectRevert("Only owner can call this function");
        token.mint(user2, 1000);
        
        // 新所有者可以 mint
        vm.prank(user1);
        bool success = token.mint(user2, 1000);
        assertTrue(success);
    }
}