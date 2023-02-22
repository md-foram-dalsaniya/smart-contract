// SPDX-License-Identifier: MIT
pragma solidity  >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Allowances is Ownable{
    receive() payable external{
    }

    function checkBal() public view returns(uint256){
        return address(this).balance;

    }

    mapping(address => uint256) public allowances;
    //address public owner;

    // constructor(){
    //     owner=msg.sender;
    // }

    function addAllowances(address _to,uint256 amt) public onlyOwner{
       // require(owner==msg.sender,"not owner")
       allowances[_to]+= amt;

    }

    function isOwner() internal view returns(bool){
        return owner() == msg.sender;
    }

    modifier ownerOrAllowed(uint256 _amt){
        require(isOwner() || allowances[msg.sender]>= _amt,"not allowed");
        _;
    }
     
     event MonaySent(string description, address to, uint256 amt);
     function withdraw(string memory _description, address payable _to, uint256 _amt)public ownerOrAllowed(_amt){
         require(address(this).balance <= _amt,"not enough funds left");
         if(isOwner()==false){
             allowances[msg.sender] -= _amt;
         }
         emit MonaySent(_description,_to,_amt);
         _to.transfer(_amt);
     }

     function renounceOwnership() public override view onlyOwner{
         revert("can't  renounce ownership");
     }
 
}
