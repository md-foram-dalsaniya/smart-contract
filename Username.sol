// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Usernames {
  mapping (string => address) public usernames;

  function register(string memory _username) public {
    require(usernames[_username] == address(0), "Username already taken");
    usernames[_username] = msg.sender;
  }

  function update(string memory _oldUsername, string memory _newUsername) public {
    require(usernames[_oldUsername] == msg.sender, "Only owner can update username");
    require(usernames[_newUsername] == address(0), "New username already taken");
    usernames[_newUsername] = msg.sender;
    //delete usernames[_oldUsername];
  }
  
}
