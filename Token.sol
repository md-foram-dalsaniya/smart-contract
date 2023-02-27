// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Tokens is ERC20 {
    uint256 public amount;
    address Owner;
    uint256 taxPercentage;
    
    constructor(uint256 _amount) ERC20("TokenTest", "Test") {
        amount = _amount;
        Owner = msg.sender;
        taxPercentage = 10; 
    }

    modifier onlyOwner {
        require(msg.sender == Owner, "Access to only Owner");
        _;
    }

    mapping(address => bool) exemptedAccounts;
    mapping(address => uint256) spent;

    function setExemptedAccount(address acc) public onlyOwner {
        exemptedAccounts[acc] = true;
    }

    function mint() public payable returns(bool) {
        require(msg.value >= 0.1 ether, "Investment amount is low");
        require(msg.value <= 2 ether, "Investement amount is too high");
        
        uint256 mintAmount = (msg.value * 10000000);
        
        require((totalSupply() + mintAmount) <= amount, "investment amount should be less then total mount");
        require(spent[msg.sender] + msg.value <= 2 ether, "Max limit reached");

        _mint(msg.sender, mintAmount);
        spent[msg.sender] += msg.value;
        
        return true;
    }

    function transfer(address _to, uint256 _amount) public override returns(bool)  {
        uint256 taxAmount;
        if(!exemptedAccounts[msg.sender]) {
            taxAmount = (taxPercentage * _amount)/100;
            _amount -= taxAmount;
        }
        _transfer(msg.sender, _to, _amount);
        if(taxAmount > 0)
            _burn(msg.sender, taxAmount);
        return true;
    }

    function burn(uint256 _amount) public {
        uint256 transferAmount = _amount / 10000000;
        payable(msg.sender).transfer(transferAmount);
        _burn(msg.sender, _amount);
    }

    function getTaxPercentage() public view returns(uint256) {
        return taxPercentage;
    }
}
