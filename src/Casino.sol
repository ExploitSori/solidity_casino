// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {StorageSlot} from "../lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol";
import {ERC1967Utils} from "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
contract Casino{
	address owner;	
	IERC20 stk;
	Game[] storage game_list;
	mapping(address=>uint) insertedMoney;
	bytes32 internal constant _IMPLEMENTATION_SLOT = keccak256("sori.implementation");
	enum Status{
		Wait,
		In_progress,
		ended,
		stoped,
	}
	struct Game{
		bytes32 id;
		uint256 userCnt;
		address[] users;
		uint256 money;
		uint totalMoney;
		uint256 maxUser;
		Status stat;
		uint createdAt;
		uint endedAt;
	}
	modifier ownerChk{
		require(owner == msg.sender, "not owner");
		_;
	}
	function initialize() external{
		
	}
	function insertToken(uint256 amount) external{
		//approve chk => transferFrom
		uint approved = stk.allowance(msg.sender, address(this));
		uint balanced = stk.balanceOf(msg.sender);
		require(balanced >= amount, "amount err1");
		require(approved >= amount, "amount err2");
		stk.transferFrom(msg.sender, address(this), amount);
		insertedMoney[msg.sender] += amount;
	}
	function gameJoin() external{
		//game chk 
		// joined game
	}
	function makeGame() external{
		//makeGame
	}
	function claim() external {
		//transfer
	}
	function games() external {
		//print open Games
	}
	function totalGames() external{

	}
	function upgradeTo(address impl) internal {
		StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = impl;
	}
	function upgradeToAndCall(address newImplementation, bytes memory data) ownerChk public payable {
		upgradeTo(newImplementation);
		if(data.length > 0){
			(bool success, ) = newImplementation.delegatecall(data);
			require(success, "Upgrade and call failed");
		}
	}
}
