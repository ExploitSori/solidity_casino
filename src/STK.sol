// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {StorageSlot} from "../lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol";
import {ERC1967Utils} from "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
contract STK{
	address owner;
	constructor(uint256 total, address casino) ERC20("solidity_casino_Token","STK"){
		//_mint(casino, total);
		owner = casino;
	}
	modifier ownerChk{
		require(owner == msg.sender, "not owner");
		_;
	}
/*	function mint(uint256 cnt) ownerChk external{
		_mint(owner, cnt);
	}*/
}
