// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {StorageSlot} from "../lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol";
import {ERC1967Utils} from "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract Casino{
	address owner;
	bytes32 internal constant _IMPLEMENTATION_SLOT = keccak256("sori.implementation");
	mapping(address=>uint) insertedMoney;
	struct game{
		bytes32 id;
		uint256 userCnt;
		address[] users;
		uint256 money;
		uint totalMoney;
		uint256 maxUser;
	}
	modifier ownerChk{
		require(owner == msg.sender, "not owner");
		_;
	}
	function insertToken() external{
		//approve chk => transferFrom
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
