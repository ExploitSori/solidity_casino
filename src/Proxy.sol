// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {StorageSlot} from "../lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol";
import {ERC1967Utils} from "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";
contract Proxy{
	bytes32 internal constant _IMPLEMENTATION_SLOT = keccak256("sori.implementation");
	constructor(address impl){
		StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = impl;
	}
	fallback() payable{
		//delegatecall
	}

}
