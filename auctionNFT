// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MyNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    //1000 NFT done
    //pay ETH to mint NFT done
    //unique metadata for each NFT

    uint256 maxSupply = 10;
    uint256 cost = 0.001 ether; //0.001 BNB
    string baseURI = "ipfs://QmVJwRRkRzhhpptnGMBqcqurvsz75qEiDW299oTz3T3boX/"; //"https://raw.githubusercontent.com/durdomtut0/airdropStarter/main/NFT-data/metadata/";//"https://raw.githubusercontent.com/durdomtut0/NFT-metadata/main/metadata/";

    //NFT storage

    //on chain => svg => base64
    //central server (cloudinary, file storage, firestore, github)
    //IPFS (decentralized file storage), arweave.

    constructor() ERC721("Chain17NFT", "1NFT7") {}

    //ON-CHAIN DATA
    //EVENT

    function _baseURI() internal view override returns (string memory) {
        return baseURI;

        //
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        //string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }

    function changeBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function safeMint(address _to) public payable {
        uint256 _currentSupply = totalSupply();
        require(_currentSupply < maxSupply, "You reached max supply");
        require(msg.value == cost, "Please add valid amount of ETH");
        _safeMint(_to, _currentSupply);
    }

    function withdraw() public onlyOwner {
        //
        //payable(msg.sender).transfer(address(this).balance);
        //(bool os, ) = payable(owner()).call{value: address(this).balance}(""); require(os);
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
}

contract MyAuction {
    MyNFT public nft; // контракт NFT, который мы будем аукционировать

    // структура для хранения информации о победителе
    struct Winner {
        address winnerAddress;
        uint256 bidAmount;
    }

    Winner[3] public winners; // массив для хранения информации о трех победителях

    uint256 public auctionStart; // время начала аукциона в формате Unix time
    uint256 public auctionEnd; // время окончания аукциона в формате Unix time

    address payable public auctionOwner; // адрес владельца аукциона
    uint256 public highestBid; // текущая максимальная ставка
    address payable public highestBidder; // адрес текущего лидера аукциона
    mapping(address => uint256) public bids; // маппинг для хранения ставок каждого участника

    bool public ended; // флаг, указывающий на то, завершен ли аукцион

    event AuctionEnded(address winner1, uint256 bidAmount1, address winner2, uint256 bidAmount2, address winner3, uint256 bidAmount3);

    constructor(MyNFT _nft, uint256 _duration) {
        nft = _nft;
        auctionOwner = payable(msg.sender);
        auctionStart = block.timestamp;
        auctionEnd = auctionStart + _duration;
    }

    function bid() public payable {
        require(block.timestamp >= auctionStart, "Auction has not started yet");
        require(!ended, "Auction has already ended");
        require(msg.value >= 0.0001 ether, "Bid amount too low");
        require(bids[msg.sender] + msg.value <= 0.0003 ether, "You can only bid up to 0.0003 ether");

        if (msg.value > highestBid) {
            if (highestBidder != address(0)) {
                // возврат предыдущей максимальной ставки
                bids[highestBidder] += highestBid;
            }
            highestBid = msg.value;
            highestBidder = payable(msg.sender);
        } else {
            bids[msg.sender] += msg.value;
        }
    }

    function endAuction() public {
        require(msg.sender == auctionOwner, "Only auction owner can end the auction");
        require(!ended, "Auction has already ended");
        require(block.timestamp >= auctionEnd, "Auction has not ended yet");

        ended = true;

        // сохраняем информацию о победителях аукциона
        if (highestBidder != address(0)) {
            winners[0].winnerAddress = highestBidder;
            winners[0].bidAmount = highestBid;
        }
        uint256 i = 1;
        for (uint256 j = 0; j < 3 && i < winners.length; j++) {
            if (bids[highestBidder] > bids[winners[j].winnerAddress]) {
                for (uint256 k = 2; k > j; k--) {
                    winners[k] = winners[k-1];
                }
                winners[j].bidAmount = bids[highestBidder];
            i++;
        }
    }

    // отправляем NFT трем победителям
  //  for (uint256 j = 0; j < 3 && winners[j].winnerAddress != address(0); j++) {
  //      nft.transferFrom(auctionOwner, winners[j].winnerAddress, 0);
  //  }

    emit AuctionEnded(winners[0].winnerAddress, winners[0].bidAmount, winners[1].winnerAddress, winners[1].bidAmount, winners[2].winnerAddress, winners[2].bidAmount);
}
}
