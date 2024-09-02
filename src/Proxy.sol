// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {StorageSlot} from "../lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol";
import {ERC1967Utils} from "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {console} from "forge-std/console.sol";
contract Proxy{
	address owner;
	bytes32 internal constant _IMPLEMENTATION_SLOT = keccak256("sori.implementation");
	constructor(address impl){
		StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = impl;
		owner = msg.sender;
	}
	function getAddress()public returns(address){
		return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
	}
	fallback(bytes calldata data) external payable returns(bytes memory ret){
		//delegatecall
		address impl = getAddress();
		console.log(impl);
//		console.logBytes32(data);
		(bool success, bytes memory res) = impl.delegatecall(data);
		require(success, "execution fail");
		return res;
	}

}
