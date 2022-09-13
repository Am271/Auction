// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract Auction {

    struct Bidder {
        string name;
        bool permissionToBid;
        address buyer;
    }

    struct Item {
        string name;
        bool isSold;
        uint highestBid;
        address highestBidder;
    }

    address public auctioneer;

    uint public item;

    mapping(address => Bidder) public bidders;

    Item[] public items;

    constructor(string[] memory itemNames) {
        auctioneer = msg.sender;

        for (uint i = 0; i < itemNames.length; i++) {
            items.push(Item({
                name: itemNames[i],
                highestBid: 0,
                isSold: false,
                highestBidder: payable(address(0))
            }));
        }
    }

    function getInitPrice(uint number) public view returns(uint) {
        require(
            msg.sender == auctioneer,
            "Only the auctioneer can use this method!"
        );
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % number;
    }

    function checkCanBid() public view {
        if(bidders[msg.sender].permissionToBid) {
            console.log("You have permission to bid!");
        }
        
        else {
            console.log("No permission to bid! Register yourself with the auctioneer.");
        }
    }

    function registerWithAuctioneer(string calldata name, address bidder) public { // register the bidder with the auctioneer
        require(
            msg.sender == auctioneer,
            "Only the auctioneer can give the permission to bid!"
        );

        require(
            !bidders[bidder].permissionToBid,
            "You have already been granted permission to bid!"
        );

        bidders[bidder].permissionToBid = true;
        bidders[bidder].name = name;

        console.log("%s, you have been successfully registered with the auctioneer.", name);
        console.log("You can now bid items.");
    }

    function putItemUpForBidding(uint itemIndex) public {
        require(
            msg.sender == auctioneer,
            "You cannot put an item up for bid, only the auctioneer can do it."
        );

        uint price = getInitPrice(10) * 1000;
        item = itemIndex;
        items[itemIndex - 1].highestBid = price;
        console.log("We have %s with index %d. The bid starts at %d", items[item - 1].name, item, price);
    }

    function bid() public view {
        require(
            bidders[msg.sender].permissionToBid,
            "You have no permission to bid! First register with the auctioneer."
        );

        Item memory it = items[item - 1];

        it.highestBid += 500;
        it.highestBidder = msg.sender;
        console.log("%s are bidding %s for %d", bidders[msg.sender].name, it.name, it.highestBid);
        console.log("Do we have %d?", it.highestBid + 500);
    }

    function endAuction() public view {
        require(
            msg.sender == auctioneer,
            "Only the auctioneer can end the auction!"
        );
        for (uint i = 0; i < items.length; i++) {
            console.log("%s has been sold to %s for %d.", items[i].name, items[i].highestBidder, items[i].highestBid);
        }
    }
}