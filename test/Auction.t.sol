// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Auction.sol";
import "../src/NFT.sol";

contract AuctionTest is Test {
    Auction public auction;
    NFT public nft;

    address vincent = vm.addr(0x1);
    address dunie = vm.addr(0x2);
    address nonso = vm.addr(0x3);
    address kenny = vm.addr(0x4);

    function setUp() public {
        nft = new NFT();
        nft.safeMint(dunie, 1);

        vm.startPrank(dunie);
        auction = new Auction(address(nft), 1);
    }

    function testStartAuction() public {
        // vm.prank(dunie);
        nft.approve(address(auction), 1);
        auction.startAuction(2);
        vm.stopPrank();
        vm.prank(nonso);
        bytes32 seal1 = auction.sealedBid(1, "Vincent");
        vm.deal(nonso, 100);
        vm.prank(nonso);
        auction.bid{value: 10}(seal1);

        vm.prank(kenny);
        bytes32 seal2 = auction.sealedBid(20, "Vincent");
        vm.deal(kenny, 100);
        vm.prank(kenny);
        auction.bid{value: 20}(seal2);

vm.warp(4 minutes);

        vm.prank(kenny);
        auction.revealBid(20, "Vincent");

        vm.prank(nonso);
        auction.revealBid(1, "Vincent");
    }

    function testEndAuction() public{
        // vm.prank(dunie);
        nft.approve(dunie, 1);
        auction.endAuction();
    }
    // function testWithdraw() public{
    //     // vm.prank(dunie);
    //     vm.stopPrank();
    //     nft.approve(dunie, 1);
    //     auction.withdraw();
    // }
}


