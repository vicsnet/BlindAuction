// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract Auction {
    // Variables
    address payable public seller;

    // nft Details
    IERC721 public nft;
    uint public nftId;

    address public highestBidder;
    uint public highestAmount;

    uint public startingTime;
    uint public endingTime;

    // no of bidders
    uint public noOfBidders;

    struct Bid {
        bytes32 sealedBid;
        uint depositAmt;
    }

    bool public bidStarted;
    mapping(address => Bid[]) public bidMap;
    mapping(address => bool) public youAreABidder;
    mapping(address => uint) public revealedBalance;
    // events
    event Start();
    event end();
    event TimeBidToend(uint Time);

    event TotalBidders(uint sumBidder);

    // constructor
    constructor(address _nft, uint _nftId) {
        seller = payable(msg.sender);
        // endingTime = block.timestamp +(_endingTime * 1 minutes);
        nft = IERC721(_nft);
        nftId = _nftId;
    }

    // function

    function startAuction(uint _endingTime) external {
        require(!bidStarted, "started");
        require(msg.sender == seller, "not seller");

        nft.transferFrom(msg.sender, address(this), nftId);
        bidStarted = true;
        endingTime = block.timestamp + (_endingTime * 1 minutes);
        emit Start();
        emit TimeBidToend(endingTime);
    }

    function sealedBid(
        uint _value,
        string calldata _passCode
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked(_value, _passCode, msg.sender));
    }

    function bid(bytes32 _sealedBid) public payable {
        // require(youAreABidder[msg.sender] == true, "You can only Bid Once");
        require(msg.value > 0, "you can't bid nothing");

        bidMap[msg.sender].push(
            Bid({sealedBid: _sealedBid, depositAmt: msg.value})
        );
        noOfBidders += 1;
        emit TotalBidders(noOfBidders);
    }

    function revealBid(uint _value, string memory _passcode) public {
        Bid storage myBid = bidMap[msg.sender][0];
        uint value = _value;
        string memory passcode = _passcode;
        require(
            myBid.sealedBid ==
                keccak256(abi.encodePacked(value, passcode, msg.sender))
        );
        if (highestBidder == address(0)) {
            highestBidder = msg.sender;
            highestAmount = value;
        } else {
            if (highestAmount > value) {
                revealedBalance[msg.sender] = value;
            } else if (highestAmount < value) {
                revealedBalance[highestBidder] = highestAmount;
                highestBidder = msg.sender;
                highestAmount = value;
            } else if (highestAmount == value) {
                revealedBalance[msg.sender] = value;
            }
        }
    }

    function endAuction() public {
        require(bidStarted = true, "bid not started");
        require(seller == payable(msg.sender), "you are not the Owner of the bid");
        bidStarted = false;
        payable(seller).transfer(highestAmount);
        nft.safeTransferFrom(address(this), highestBidder, nftId);
    }

    function withdraw () public{
        require(revealedBalance[msg.sender] > 0);
        revealedBalance[msg.sender] = 0;

        payable(msg.sender).transfer(revealedBalance[msg.sender]);
    }
}
