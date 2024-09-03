// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {console} from "forge-std/console.sol";
import {StorageSlot} from "../lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol";
import {ERC1967Utils} from "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {STK} from "./STK.sol";
contract Casino{
	STK stk;
	Game run_game;
	Game prev_game;
	mapping(address=>User) users;
	struct User{
		uint insertedToken;
		uint winningToken; // 고민중
		uint[] joinedGame;
	}
	machineStat status;
	bool initialized;
	uint game_idx;
	uint game_cr;
	mapping(address=>bool) welcome_user;
	bytes32 internal constant _IMPLEMENTATION_SLOT = keccak256("sori.implementation");
	bytes32 internal constant _ADMIN_SLOT = keccak256("sori.admin");
	bytes32 internal constant _PROXY_SLOT = keccak256("sori.proxy");
	constructor(){
		StorageSlot.getAddressSlot(_ADMIN_SLOT).value = tx.origin;
		StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = address(this);
	}
	function getAddress(bytes32 slot)public returns(address){
		return StorageSlot.getAddressSlot(slot).value;
	}
	enum Status{
		Wait,
		Maked,
		Running,
		Ended
	}
	enum machineStat{
		Run,
		Stop,
		NotClaim
	}
	struct Game{
		uint256 idx;
		uint256 userCnt;
		address[] users;
		uint256 money;
		uint totalMoney;
		uint256 maxUser;
		uint256 select;
		Status stat;
		uint lastJoinBlock;
		uint createdAt;
		uint endedAt;
		mapping(address=>uint) userSelect;
	}
	modifier ownerChk{
		address owner = getAddress(_ADMIN_SLOT);
		require(owner == msg.sender, "not owner@@");
		_;
	}
	modifier proxyChk{
		address proxy = getAddress(_PROXY_SLOT);
		require(proxy == address(this), "not proxy");
		_;
	}
	modifier machineStatChk{
		if(status == machineStat.Stop ){
			revert("machine stop!");
		}
		_;
	}
	modifier machineStatChkClaim{
		if(status == machineStat.NotClaim ){
			revert("machine claim stop!");
		}
		_;
	}
	function initialize(address _proxy, address _stk) ownerChk external{
		//require(!initailized, "initialized");
		StorageSlot.getAddressSlot(_PROXY_SLOT).value = _proxy;
		stk = STK(address(_stk));
		initialized = true;
	}
	function insertToken(uint256 amount) proxyChk machineStatChk external{
		//approve chk => transferFrom
		uint approved = stk.allowance(msg.sender, address(this));
		uint balanced = stk.balanceOf(msg.sender);
		require(balanced >= amount, "amount err1");
		require(approved >= amount, "amount err2");
		(bool success, ) = address(stk).call(abi.encodeWithSignature("transferFrom(address,address,uint256)",msg.sender, address(this), amount));
		users[msg.sender].insertedToken += amount;
	}
	function randoms() public returns(uint){
		// random > block difict, num, time mix...
		uint256 pick = 2;
		uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, block.difficulty, block.number))) % 2;
		return rand;
	}
	function clearGame(Game storage game) internal {
		require(game.stat == Status.Ended || game.idx == 0 , "game not ended");
        game.idx = 0;
        game.userCnt = 0;
        delete game.users; // Clears the array
        game.money = 0;
        game.totalMoney = 0;
        game.maxUser = 0;
        game.select = 0;
        game.stat = Status.Wait;
        game.lastJoinBlock = 0;
        game.createdAt = 0;
        game.endedAt = 0;

        // Clear the mapping
        for (uint i = 0; i < game.users.length; i++) {
            address user = game.users[i];
            delete game.userSelect[user];
        }
    }
	function endGame() internal {
        clearGame(prev_game);
		require(run_game.stat == Status.Maked || run_game.stat == Status.Running, "game not found");
		run_game.select = randoms();
		run_game.stat = Status.Ended;
        prev_game.idx = run_game.idx;
        prev_game.userCnt = run_game.userCnt;
        prev_game.money = run_game.money;
        prev_game.totalMoney = run_game.totalMoney;
        prev_game.maxUser = run_game.maxUser;
        prev_game.select = run_game.select;
        prev_game.stat = run_game.stat;
        prev_game.lastJoinBlock = run_game.lastJoinBlock;
        prev_game.createdAt = run_game.createdAt;
        prev_game.endedAt = run_game.endedAt;
        // Copy the array of users
        for (uint i = 0; i < run_game.users.length; i++) {
            prev_game.users.push(run_game.users[i]);
            address user = run_game.users[i];
            prev_game.userSelect[user] = run_game.userSelect[user];
			delete run_game.userSelect[user];
			delete run_game.users[i];
        }
		uint256 winner = 0;
		for(uint i =0; i < prev_game.users.length; i++){
			
            if(prev_game.userSelect[prev_game.users[i]] == prev_game.select){
                winner += 1;
            }
        }
        for(uint i =0; i < prev_game.users.length; i++){
            if(prev_game.userSelect[prev_game.users[i]] == prev_game.select){
                users[prev_game.users[i]].insertedToken +=  (prev_game.totalMoney / winner);
            }
        }
		prev_game.totalMoney = 0;
        // Optionally, reset run_game if needed
        clearGame(run_game);
    }
	function gameEnd() proxyChk machineStatChk external {
		if(run_game.createdAt + 5 minutes <= block.timestamp && run_game.idx != 0){
			endGame();
		}
		if(run_game.createdAt + 5 >= block.timestamp && run_game.createdAt != 0 ){
			revert("game run");
		}
	}
	function gameJoin(uint256 selectNumber) proxyChk machineStatChk external {
		//game chk 
		//joined game
		if( run_game.createdAt + 5 minutes <= block.timestamp ) {
			revert("game end");
		}
		else{
			require(run_game.stat == Status.Maked || run_game.stat == Status.Running, "game not found");
			require(run_game.userSelect[msg.sender] == 0, "game joined");
			require(users[msg.sender].insertedToken >= run_game.money, "inserted token < money");
			users[msg.sender].insertedToken -= run_game.money;
			run_game.userSelect[msg.sender] = selectNumber;
			run_game.users.push(msg.sender);
			run_game.lastJoinBlock = block.number;
			run_game.userCnt += 1;
			run_game.stat = Status.Running;
			run_game.totalMoney += run_game.money;
		}
		
	}
	function makeGame(uint256 money, uint256 sel) proxyChk machineStatChk external{
		//makeGame
		//이전 게임이 이전게임이 있다면 종료 후 생성
		require(users[msg.sender].insertedToken >= money, "inserted token < money");
		if(run_game.createdAt + 5 minutes <= block.timestamp && run_game.idx != 0){
			// 게임 종료 로직 구현해야함
//			gameEnd();
			endGame();
		}
		if(run_game.createdAt + 5 >= block.timestamp && run_game.createdAt != 0 ){
			revert("game opend");
		}
		if(run_game.stat == Status.Wait){
			game_idx += 1;
			run_game.idx = game_idx;
			run_game.userCnt = 1;
			run_game.users.push(msg.sender);
			run_game.money = money;
			run_game.totalMoney += money;
			run_game.stat = Status.Maked;
			run_game.userSelect[msg.sender] = sel;
			run_game.createdAt = block.timestamp;
			run_game.lastJoinBlock = block.number;
			users[msg.sender].insertedToken -= money;
		}
		
	}
	
	function howManyMoney() proxyChk external returns(uint){
		return users[msg.sender].insertedToken;
	}
	function claim(uint256 amount) proxyChk machineStatChk machineStatChkClaim external {
		//transfer
		require(users[msg.sender].insertedToken >= amount, "amount err 3");
		users[msg.sender].insertedToken -= amount;
		stk.transfer(msg.sender, amount);
	}

	function stopMachine() proxyChk ownerChk external{
		status = machineStat.Stop;
	}
	function reRunMachine() proxyChk ownerChk external{
		status = machineStat.Run;
	}
	function claimStopMachine() proxyChk ownerChk external{
		status = machineStat.NotClaim;
	}
	function welcome() proxyChk machineStatChk external{
		if(!welcome_user[msg.sender]){
			welcome_user[msg.sender] = true;
			address impl = getAddress(_IMPLEMENTATION_SLOT);
			(bool stat1, ) = address(stk).call(abi.encodeWithSignature("mint(uint256)",10 ether));
			require(stat1, "calling fails");
			(bool stat2, ) = address(stk).call(abi.encodeWithSignature("transfer(address,uint256)",msg.sender,10 ether));
			require(stat2, "calling fails");
		}
		else{
			revert("Already paid");
		}
	}
	function upgradeTo(address impl) internal {
		StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = impl;
	}
	function upgradeToAndCall(address newImplementation, bytes memory data) proxyChk ownerChk machineStatChk public payable {
		upgradeTo(newImplementation);
		if(data.length > 0) {
			(bool success, ) = newImplementation.delegatecall(data);
			require(success, "Upgrade and call failed");
		}
	}
}
