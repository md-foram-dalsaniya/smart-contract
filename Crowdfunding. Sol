// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

contract Crowdfunding {
    address public owner;
    uint256 public goal;
    uint256 public minAmount;
    uint256 public numOfFunders;
    uint256 public fundsRaised;
    uint256 public timePeriod; //timestamp
    mapping(address => uint256) public funders;

    constructor(uint256 _goal, uint256 _timePeriod)public {
        goal = _goal;
        timePeriod = block.timestamp + _timePeriod;
        owner = msg.sender;
        minAmount = 1000 wei;
    }

    function contribution() public payable {
        require(block.timestamp < timePeriod, "funding time is over!");
        require(msg.value >= minAmount, "minimum amount criteria not satisfied");
        if (funders[msg.sender] == 0) {
            numOfFunders++;
        }
        funders[msg.sender] += msg.value;
        fundsRaised += msg.value;
    }

    function receive() external payable {
        contribution();
    }

    function getrefFund() public {
        require(block.timestamp > timePeriod, "funding time is still on!!");
        require(fundsRaised < goal, "funding was successful!!");
        require(funders[msg.sender] > 0, "not a funder");

      payable(msg.sender).transfer(funders[msg.sender]);
        fundsRaised -= funders[msg.sender];
        funders[msg.sender] = 0;
    }

    struct request {
        string description;
        uint256 amount;
        address payable reciver;
        uint256 numofVoters;
        mapping(address => bool) votes;
        bool completed;
    }
    mapping(uint256 => request) public allrequests;
    uint256 public numRequest;

    modifier isOwner(){
        require(msg.sender==owner,"you are not the owner");
        _;
    }

    function createRequest(
        string memory _description,
        uint256 _amount,
        address payable _reciver) isOwner public {
      
        request storage newRequest = allrequests[numRequest];
        numRequest++;
        newRequest.description = _description;
        newRequest.amount = _amount;
        newRequest.reciver = _reciver;
        newRequest.completed = false;
        newRequest.numofVoters = 0;
    }

    function votingForRequest(uint256 reqNum) public {
        require(funders[msg.sender]>0,"not a funder");

        request storage thisRequest =allrequests[reqNum];
        require (thisRequest.votes[msg.sender]==false,"already voted");
        thisRequest.votes[msg.sender]=true;
        thisRequest.numofVoters++;
    }

    function makePayment(uint256 reqNum) isOwner public {
         request storage thisRequest =allrequests[reqNum];
         require(thisRequest.completed == false,"completed already");
         require(thisRequest.numofVoters >=numOfFunders/2,"voting not in favour");
         thisRequest.reciver.transfer(thisRequest.amount);
         thisRequest.completed=true;
    }
}
