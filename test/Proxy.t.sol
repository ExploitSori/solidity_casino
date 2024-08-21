// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Proxy} from "../src/Proxy.sol";
import {Casino} from "../src/Casino.sol";
contract CounterTest is Test {
	Proxy public proxy;
	
	Casino public casino;
	function setUp() public {
		address a = address(1);
		casino = new Casino();
		proxy = new Proxy(address(casino));
	}
	function test_GetAddress() public {
		address ret = proxy.getAddress();
		console.log(ret);
		require(ret == address(casino), "getAddress Error");
	}
	function test_modifyImplement() public{
		address modify = address(casino);
		//upgradeToAndCall(modify, "");
		(bool success, ) = address(proxy).call(
			abi.encodeWithSignature('upgradeToAndCall(address,bytes)', modify, "")
		);
		address ret = proxy.getAddress();
		console.log(ret);
		require(ret == modify);

	}

}
