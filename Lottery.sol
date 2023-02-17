// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.0;
contract Lottery {
    address public owner;
    uint256 public jackpot;
    
    address payable[] public players;

    constructor() public {
        owner = msg.sender;
    }

    function enter() public payable {
        require(msg.value >= 1 ether, "Must enter with a positive amount");
        players.push(msg.sender);
        jackpot += msg.value;
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) ;
    }
    

    
    function pickWinner() public {
        require(msg.sender == owner, "Only the owner can pick the winner");
        require(players.length > 0, "No players have entered the lottery");
        address payable winnerAddress = players[random() % players.length];
        winnerAddress.transfer(jackpot);
       // players=new address payable[](0);
        delete players;
        jackpot = 0;
    }

    function getplayers() view public returns(address payable[]memory){
        return players;
     }
}


