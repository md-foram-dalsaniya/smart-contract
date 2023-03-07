// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTAuction {
    // Variables
    address public owner;
    IERC721 public nft;
    uint public auctionStart;
    uint public auctionEnd;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bids;

    // Events
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    // Constructor
    constructor(address _nft, uint _start, uint _end) {
        owner = msg.sender;
        nft = IERC721(_nft);
        auctionStart = _start;
        auctionEnd = _end;
    }

    // Bid function
    function bid() public payable {
        require(block.timestamp >= auctionStart && block.timestamp <= auctionEnd, "Auction not active");
        require(msg.value > highestBid, "Bid too low");

        if (highestBid != 0) {
            // Refund the previous highest bidder
           // bids[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        bids[msg.sender] = msg.value;

        emit HighestBidIncreased(highestBidder, highestBid);
    }

    // End auction function
    function endAuction() public {
        require(msg.sender == owner, "Only owner can end auction");
        require(block.timestamp > auctionEnd, "Auction not ended yet");

        if (highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, 0);

            payable(owner).transfer(highestBid);
        }

       // emit AuctionEnded(highestBidder, highestBid);
    }

    // Withdraw function
    function withdraw() public {
        uint amount = bids[msg.sender];
        require(amount > 0, "No funds to withdraw");

        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}

contract NFTAuctionFactory {
    // Variables
    mapping(address => bool) public isNFTAuction;
    address[] public nftAuctions;

    // Events
    event NFTAuctionCreated(address nftAuction, address owner);

    // Create NFTAuction contract
    function createNFTAuction(address _nft, uint _start, uint _end) public returns (address) {
        address nftAuction = address(new NFTAuction(_nft, _start, _end));
        isNFTAuction[nftAuction] = true;
        nftAuctions.push(nftAuction);

        emit NFTAuctionCreated(nftAuction, msg.sender);

        return nftAuction;
    }

    // Get number of NFTAuctions
    function getNFTAuctionCount() public view returns (uint) {
        return nftAuctions.length;
    }
}
