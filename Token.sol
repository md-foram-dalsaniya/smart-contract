 // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    uint256 private _totalSupply;
    uint256 private _taxFee;
    uint256 private _burnAmount;
   
    uint256 private _oneEtherInTokens;
    uint256 public minInvestment = 10**17; // minimum investment is 0.1 ether
    uint256 public maxInvestment = 2 ether; // maximum investment is 2 ether
    mapping (address => bool) private _exemptAccounts;
   
    event Burn(address indexed burner, uint256 amount);
    event TaxFeeUpdated(uint256 taxFee);

    constructor() ERC20("MyToken", "TK") {
        _totalSupply = 200000000 * (10 ** uint256(decimals()));
        _oneEtherInTokens = 10000000 * (10 ** uint256(decimals()));
        _taxFee = 10; // 10% tax fee
        _exemptAccounts[msg.sender] = true; // owner address is exempted
      //  _mint(msg.sender, _totalSupply);
       
    }
    


    function transfer(address to, uint256 value) public override returns (bool) {
        uint256 taxAmount = calculateTaxFee(value);
        uint256 netValue = value - taxAmount;
        _transfer(msg.sender, to, netValue);
        if (taxAmount > 0) {
            _transfer(msg.sender, address(this), taxAmount);
            emit Transfer(msg.sender, address(this), taxAmount);
        }
        return true;
    }

    function setTaxFee(uint256 fee) public onlyOwner {
        require(fee <= 10, "Tax fee cannot exceed 10%");
        _taxFee = fee;
        emit TaxFeeUpdated(_taxFee);
    }

    function isExemptAccount(address account) public view returns (bool) {
        return _exemptAccounts[account];
    }

    function addExemptAccount(address account) public onlyOwner {
        _exemptAccounts[account] = true;
    }

    function removeExemptAccount(address account) public onlyOwner {
        _exemptAccounts[account] = false;
    }

    function calculateTaxFee(uint256 amount) private view returns (uint256) {
        if (isExemptAccount(msg.sender)) {
            return 0;
        }
        return amount * _taxFee / 100;
    }

    function burn(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Not enough balance to burn");
        _burn(msg.sender, amount);
        _burnAmount += amount;
        emit Burn(msg.sender, amount);
    }

    function mint() public payable {
        require(msg.value >= 0.1 ether, "Minimum investment is 0.1 ether");
        require(msg.value <= 2 ether, "Maximum investment is 2 ether");
        uint256 tokens = msg.value * _oneEtherInTokens / 1 ether;
        require(totalSupply() + tokens <= _totalSupply, "Exceeds total supply limit");
        _mint(msg.sender, tokens);
    }

   
}
