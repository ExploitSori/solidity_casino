// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Proxy} from "../src/Proxy.sol";
import {Casino} from "../src/Casino.sol";
import {STK} from "../src/STK.sol";
contract ProxyTest is Test {
	Proxy public proxy;
	
	Casino public casino;
	Casino public newCasino;
	Casino public _proxy;
	STK public stk;
	address alice;
	address charlie;
	function setUp() public {
		address a = address(1);
		casino = new Casino();
		proxy = new Proxy(address(casino));
		stk = new STK(100 ether, address(proxy));
		_proxy = Casino(address(proxy));
		_proxy.initialize(address(proxy), address(stk));
		console.log(address(proxy));
		alice = makeAddr("alice");
		charlie = makeAddr("charlie");
	}
	function test_GetAddress() public {
		address ret = proxy.getAddress();
		console.log(ret);
		require(ret == address(casino), "getAddress Error");
	}
	function test_modifyImplement() public{
		newCasino = new Casino();
		address ret = proxy.getAddress();
		address stk_addr = address(stk);
		address modify = address(newCasino);
		console.log(ret);
		console.log(modify);
		//upgradeToAndCall(modify, "");
		(bool success, ) = address(proxy).call(
			abi.encodeWithSignature('upgradeToAndCall(address,bytes)', modify, abi.encodeWithSignature("initialize(address,address)", modify, stk_addr))
		);
		require(ret != modify, "proxy not changed");

	}
	function test_getRandom() public{
		Casino _p = Casino(address(proxy));
		uint a = _p.randoms();
		console.log(a);
	}
	function welcome_a_b() public{
		_proxy = Casino(address(proxy));
		vm.startPrank(alice);
		{
			_proxy.welcome();
		}
		vm.stopPrank();
		vm.startPrank(charlie);
		{
			_proxy.welcome();
		}
		vm.stopPrank();
	}
	function testFail_welcome() public{
		welcome_a_b();
		welcome_a_b();
		
	}
	function test_makeGame() public {
		Casino _proxy = Casino(address(proxy));
		welcome_a_b();
		vm.startPrank(alice);
		{
			stk.approve(address(proxy), 100 ether);
			_proxy.insertToken(10 ether);
			_proxy.makeGame(1 ether, 1);
		}
		vm.stopPrank();
	}
	function testFail_makeGame() public {
		Casino _proxy = Casino(address(proxy));
		welcome_a_b();
		vm.startPrank(alice);
		{
			stk.approve(address(proxy), 100 ether);
			_proxy.insertToken(10 ether);
			_proxy.makeGame(1 ether, 1);
			_proxy.makeGame(1 ether, 1);
		}
		vm.stopPrank();
	}
	function test_joinGame() public{
		Casino _proxy = Casino(address(proxy));
		welcome_a_b();
		vm.startPrank(alice);
		{
			stk.approve(address(proxy), 100 ether);
			_proxy.insertToken(10 ether);
			_proxy.makeGame(1 ether, 1);
		}
		vm.stopPrank();
		vm.startPrank(charlie);
		{
			stk.approve(address(proxy), 100 ether);
			_proxy.insertToken(10 ether);
			_proxy.gameJoin(1);
			
		}
		vm.stopPrank();
	}
	function testFail_joinGame1() public{
		Casino _proxy = Casino(address(proxy));
		welcome_a_b();
		vm.startPrank(alice);
		{
			stk.approve(address(proxy), 100 ether);
			_proxy.insertToken(10 ether);
			_proxy.makeGame(1 ether, 1);
		}
		vm.stopPrank();
		vm.startPrank(charlie);
		{
			stk.approve(address(proxy), 100 ether);
			_proxy.insertToken(10 ether);
			_proxy.gameJoin(1);
			_proxy.gameJoin(2);
		}
		vm.stopPrank();
	}
	function testFail_joinGame2() public{
		Casino _proxy = Casino(address(proxy));
		welcome_a_b();
		vm.startPrank(alice);
		{
			stk.approve(address(proxy), 100 ether);
			_proxy.insertToken(10 ether);
			_proxy.makeGame(1 ether, 1);
			_proxy.gameJoin(1);
		}
		vm.stopPrank();
	}
	function test_gameEnd() public{
		Casino _proxy = Casino(address(proxy));
		welcome_a_b();
		vm.startPrank(alice);
		{
			stk.approve(address(proxy), 100 ether);
			_proxy.insertToken(10 ether);
			_proxy.makeGame(1 ether, 122);
			uint256 alice_ins = _proxy.howManyMoney();
			require(alice_ins == 9 ether);
		}
		vm.stopPrank();
		vm.startPrank(charlie);
		{
			stk.approve(address(proxy), 100 ether);
			_proxy.insertToken(10 ether);
			_proxy.gameJoin(1);
			uint256 charlie_ins = _proxy.howManyMoney();
			require(charlie_ins == 9 ether);
		}
		vm.stopPrank();
		//vm.roll(block.number + 1);
		vm.warp(5 minutes + 1 seconds);
		_proxy.gameEnd();
		vm.startPrank(charlie);
		{
			uint256 charlie_ins = _proxy.howManyMoney();
			console.log(charlie_ins);
			require(charlie_ins == 11 ether);
		}
		vm.stopPrank();
	}
	function testFail_gameEnd() public{
		Casino _proxy = Casino(address(proxy));
		welcome_a_b();
		vm.startPrank(alice);
		{
			stk.approve(address(proxy), 100 ether);
			_proxy.insertToken(10 ether);
			_proxy.makeGame(1 ether, 1);
			uint256 alice_ins = _proxy.howManyMoney();
			require(alice_ins == 9 ether);
		}
		vm.stopPrank();
		vm.startPrank(charlie);
		{
			stk.approve(address(proxy), 100 ether);
			_proxy.insertToken(10 ether);
			_proxy.gameJoin(1);
			uint256 charlie_ins = _proxy.howManyMoney();
			require(charlie_ins == 9 ether);
		}
		vm.stopPrank();
		_proxy.gameEnd();
		
	}
	function test_makeGameEnd() public{
		Casino _proxy = Casino(address(proxy));
		welcome_a_b();
		vm.startPrank(alice);
		{
			stk.approve(address(proxy), 100 ether);
			_proxy.insertToken(10 ether);
			_proxy.makeGame(1 ether, 11212);
		}
		vm.stopPrank();
		vm.startPrank(charlie);
		{
			stk.approve(address(proxy), 100 ether);
			_proxy.insertToken(10 ether);
			_proxy.gameJoin(1);
			
		}
		vm.stopPrank();
		vm.warp(5 minutes + 1 seconds);
		vm.startPrank(charlie);
		{
			uint256 charlie_ins = _proxy.howManyMoney();
			require(charlie_ins == 9 ether);	
			_proxy.makeGame(1 ether, 1);
			charlie_ins = _proxy.howManyMoney();
			require(charlie_ins == 10 ether);
		}
		vm.startPrank(alice);
		{
			uint256 alice_ins = _proxy.howManyMoney();
			require(alice_ins == 9 ether);	
		}
	}
}
