 // SPDX-License-Identifier: UNLICENSED


 pragma solidity >=0.5.0 <0.8.0;

contract Staking {
    mapping(address => uint256) public stakedAmounts;
   // mapping(address => uint256) public rewards;
    uint256 public totalStakedAmount;
    uint256 public totalRewards;
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function deposit() public payable {
        require(msg.value > 0, "Cannot deposit zero or negative amount");
        stakedAmounts[msg.sender] += msg.value;
        totalStakedAmount += msg.value;
    }

    function claimRewards() public {
        require(stakedAmounts[msg.sender] > 0, "You need to stake before claiming rewards");
       //rewards[msg.sender] += calculateRewards();
        totalRewards += calculateRewards();
    }

    function calculateRewards() internal view returns (uint256) {
        // Example reward calculation, can be adjusted as per requirement
       return stakedAmounts[msg.sender] * 1000000000000000000 / 10;

    }

    function withdraw(uint256 amount) public {
        require(stakedAmounts[msg.sender] >= amount, "Insufficient balance");
        require(amount > 0, "Cannot withdraw zero or negative amount");
        stakedAmounts[msg.sender] -= amount;
        totalStakedAmount -= amount;
      //  msg.sender.transfer(amount + rewards[msg.sender]);
       // rewards[msg.sender] = 0;
    }
}



