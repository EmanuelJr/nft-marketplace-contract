// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;

    event ItemStored(
        uint256 itemId,
        IERC721 indexed nftContract,
        uint256 indexed tokenId,
        address indexed owner,
        uint256 price
    );

    event ItemSold(
        uint256 itemId,
        IERC721 indexed nftContract,
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price
    );

    event ItemWithdrawn(
        uint256 itemId,
        IERC721 indexed nftContract,
        uint256 indexed tokenId,
        address indexed owner
    );

    struct StorageItem {
        IERC721 nftContract;
        uint256 tokenId;
        address owner;
        uint256 price;
    }

    Counters.Counter private _itemId;
    mapping(uint256 => StorageItem) private _vault;
    uint256 storageFee;

    constructor(uint256 fee) {
        storageFee = fee;
    }

    function sellItem(
        IERC721 nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable {
        require(msg.value >= storageFee, "You must pay the storage fee");
        uint256 itemId = _itemId.current();
        _itemId.increment();

        _vault[itemId] = StorageItem(
            nftContract,
            tokenId,
            payable(msg.sender),
            price
        );
        nftContract.transferFrom(msg.sender, address(this), tokenId);

        emit ItemStored(itemId, nftContract, tokenId, msg.sender, price);
    }

    function buyItem(uint256 itemId) public payable nonReentrant {
        StorageItem memory item = _vault[itemId];

        require(
            msg.value >= item.price,
            "Not enough balance to complete transaction"
        );
        payable(item.owner).transfer(msg.value);
        _transferVaultItem(itemId, msg.sender);

        emit ItemSold(
            itemId,
            item.nftContract,
            item.tokenId,
            msg.sender,
            item.price
        );
    }

    function withdrawItem(uint256 itemId) public nonReentrant {
        StorageItem memory item = _vault[itemId];
        require(item.owner == msg.sender, "You are not the owner of this item");
        _transferVaultItem(itemId, msg.sender);

        emit ItemWithdrawn(itemId, item.nftContract, item.tokenId, msg.sender);
    }

    function _transferVaultItem(uint256 itemId, address to) private {
        StorageItem memory item = _vault[itemId];
        item.nftContract.transferFrom(address(this), to, item.tokenId);
        delete _vault[itemId];
    }

    function getStorageFee() public view returns (uint256) {
        return storageFee;
    }

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function changeStorageFee(uint256 fee) public onlyOwner {
        storageFee = fee;
    }
}
