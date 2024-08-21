// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Proxy} from "../src/Proxy.sol";

contract CounterTest is Test {
	Proxy public proxy;

	function setUp() public {
		address a = address(1);
		proxy = new Proxy(a);
	}
	function test_GetAddress() public {
		address ret = proxy.getAddress();
		console.log(ret);
		require(ret == address(1), "getAddress Error");
	}

}
