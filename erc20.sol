// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract TaxToken is Context, ERC20 {
    uint256 public constant TAX_RATE = 10;
    uint256 public constant TOKEN_GEN_RATE = 10 ** 7;
    uint256 public constant TOKEN_BURN_AMOUNT = 10 * TOKEN_GEN_RATE;
    uint256 public constant MIN_INVEST_AMOUNT = 10 ** 17; // 0.1 ether
    uint256 public constant MAX_INVEST_AMOUNT = 2 ether;
    address public _owner;

    mapping(address => bool) private _exemptedAccounts;

    constructor() ERC20("TaxToken", "TAX") {
        _owner = _msgSender();
        uint256 initialSupply = 200000000 * 10 ** decimals();
        _mint(_owner, initialSupply);
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Only the owner can perform this action");
        _;
    }

    function setExemptedAccount(address account, bool isExempted) public onlyOwner {
        _exemptedAccounts[account] = isExempted;
    }

    function isExemptedAccount(address account) public view returns (bool) {
        return _exemptedAccounts[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(_msgSender()) >= amount, "Insufficient balance");

        uint256 tax = 0;
        if (!_exemptedAccounts[_msgSender()]) {
            tax = amount * TAX_RATE / 100;
        }
        uint256 netAmount = amount - tax;

        _transfer(_msgSender(), recipient, netAmount);
        if (tax > 0) {
            _transfer(_msgSender(), address(this), tax);
        }
        return true;
    }

    function mint() public payable {
        require(msg.value >= MIN_INVEST_AMOUNT, "Minimum investment amount not met");
        require(msg.value <= MAX_INVEST_AMOUNT, "Maximum investment amount exceeded");
        uint256 tokenAmount = msg.value * TOKEN_GEN_RATE;
        require(totalSupply() + tokenAmount <= 200000000 * 10 ** decimals(), "Exceeds maximum token supply");
        _mint(_msgSender(), tokenAmount);
    }

    function burn() public {
        require(balanceOf(_msgSender()) >= TOKEN_BURN_AMOUNT, "Insufficient balance for burning");
        uint256 ethAmount = TOKEN_BURN_AMOUNT / TOKEN_GEN_RATE;
        _burn(_msgSender(), TOKEN_BURN_AMOUNT);
        payable(_msgSender()).transfer(ethAmount);
    }
}
