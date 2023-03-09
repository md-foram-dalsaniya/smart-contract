// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract ERC1155Auction is ERC1155Holder {
    // Variables
    address public owner;
    ERC1155 public nft;
    uint256 public auctionStart;
    uint256 public auctionEnd;
    uint256 public highestBid;
    address public highestBidder;
    mapping(address => uint256) public bids;

    // Events
    event HighestBidIncreased(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    // Constructor
    constructor(
        address _nft,
        uint256 _start,
        uint256 _end
    ) {
        owner = msg.sender;
        nft = ERC1155(_nft);
          nft.safeTransferFrom(address(this), highestBidder, 0, 1, "");
        //auctionCount++;
        auctionStart = _start;
        auctionEnd = _end;
    }

    // Bid function
    function bid() public payable {
        require(
            block.timestamp >= auctionStart && block.timestamp <= auctionEnd,
            "Auction not active"
        );
        require(msg.value > highestBid, "Bid too low");

        // if (highestBid != 0) {
        //     // Refund the previous highest bidder with a deduction of 1% fees
        //     uint refundAmount = (bids[highestBidder] * 99) / 100;
        //    // payable(highestBidder).transfer(refundAmount);
        // }

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
            
           // Transfer the NFT to the highest bidder
            nft.safeTransferFrom(address(this), highestBidder, 0, 1, "");

            // Transfer the highest bid minus 1% fees to the owner
            uint256 amountAfterFees = (highestBid * 99) / 100;
            payable(owner).transfer(amountAfterFees);
        }

        emit AuctionEnded(highestBidder, highestBid);
    }

    // Withdraw function
    function withdraw() public {
        uint256 amount = bids[msg.sender];
        require(amount > 0, "No funds to withdraw");

        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
