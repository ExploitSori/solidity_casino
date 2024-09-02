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
	STK public stk;
	address alice;
	address charlie;
	function setUp() public {
		address a = address(1);
		casino = new Casino();
		proxy = new Proxy(address(casino));
		stk = new STK(100 ether, address(proxy));
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
		Casino _proxy = Casino(address(proxy));
		_proxy.welcome();
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
			_proxy.makeGame(1 ether, 1);
		}
		vm.stopPrank();

	}

}
