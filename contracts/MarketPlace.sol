// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Marketplace is Ownable {
    struct Sale1155 {
        address seller;
        address sftToken;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        address paymentToken;
    }

    struct Sale721 {
        address seller;
        address nftAddress;
        uint256 tokenId;
        uint256 price;
        address paymentToken;
    }

    mapping(address => mapping(uint256 => uint256)) public activeSale721; // this nested mapping will basically store and also help me to update
    // nftAddress -> tokenId -> saleId
    mapping(address => mapping(uint256 => uint256)) public activeSale1155;


     // user => saleId
    mapping(address => uint256) public collectedFees;

    mapping(uint256 => Sale1155) public sales1155;
    mapping(uint256 => Sale721) public sales721; // ye mapping har saleId ko sale se store kar rahi haii
    uint256 public saleCounter721;
    uint256 public saleCounter1155;

    function transferAnyNft(
        address nftAddress,
        address to,
        uint256 tokenId
    ) external onlyOwner {
        IERC721 nft = IERC721(nftAddress);

        // Check contract owns this NFT
        require(
            nft.ownerOf(tokenId) == address(this),
            "Marketplace does not own this NFT"
        );

        // Transfer NFT
        nft.transferFrom(address(this), to, tokenId);
    }

    // Create sale 721 - done
    // Create sale 1155 - done
    // Update sale -done
    // Buy with ETH for 721 and 1155 - done
    // Buy with ERC20
    // Buy with WETH
    // conversion weth and eth
    // Fee calculation - done
    // NFT transfer
    // onReceived() revert
    // withdraw fn for owner - done

    // sale function for nft 721 , where the seller can put its digital asset without giving ownership to the market
    function createSaleOrderFor721(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        address paymentToken
    ) external {
        // Ensure the price is valid
        require(price > 0, "Price must be above zero");

        // Ensure the seller actually owns the tokens they are trying to sell
        IERC721 nft = IERC721(nftAddress); // type of ierc721 is nft and we are creating the instance of that
        require(nft.ownerOf(tokenId) == msg.sender, "Not owner of token");

        // Ensure the marketplace is approved to move the tokens on behalf of seller
        require(
            nft.getApproved(tokenId) == address(this) ||
                nft.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
        );

        //If the seller passes address(0)  it means they want ETH payment
        //Because address(0) = no ERC20 token provided  default to ETH
        address normalizePaymentToken;

        if (paymentToken == address(0)) {
            // Treat zero address as ETH
            normalizePaymentToken = address(0);
        } else {
            normalizePaymentToken = paymentToken;
        }

        // Checking  if this token already has a sale (same nftAddress + tokenId)
        uint256 existingSaleId = activeSale721[nftAddress][tokenId];

        if (existingSaleId != 0) {
            Sale721 storage s = sales721[existingSaleId]; // this is basically copy by reference pointer
            // storage vs memory  : diff : copy by value and copy by reference
            require(s.seller == msg.sender, "Only seller can update");
            s.price = price;
            s.paymentToken = paymentToken;
            return;
        }

        saleCounter721++; // increment basic sale id

        sales721[saleCounter721] = Sale721({
            seller: msg.sender,
            nftAddress: nftAddress,
            tokenId: tokenId,
            price: price,
            paymentToken: paymentToken
        });
        // this will tell me , kis token ki kya sale id haii
        activeSale721[nftAddress][tokenId] = saleCounter721;
    }

    function createSaleOrderFor1155(
        address sftToken,
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        address paymentToken
    ) external {
        require(price > 0, "Price must be above zero");
        require(amount > 0, "Amount must be above zero");

        IERC1155 sft = IERC1155(sftToken);

        // Seller must own enough tokens to sell
        require(
            sft.balanceOf(msg.sender, tokenId) >= amount,
            "Not enough tokens"
        );

        // Marketplace must be approved
        require(
            sft.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
        );

        // Normalize payment token (address(0) = ETH)
        address normalizePaymentToken = paymentToken == address(0)
            ? address(0)
            : paymentToken;

        // Check if this token already has a sale
        uint256 existingSaleId = activeSale1155[sftToken][tokenId];

        if (existingSaleId != 0) {
            Sale1155 storage s = sales1155[existingSaleId];
            require(s.seller == msg.sender, "Only seller can update");

            s.amount = amount;
            s.price = price;
            s.paymentToken = normalizePaymentToken;
            return;
        }

        saleCounter1155++;

        sales1155[saleCounter1155] = Sale1155({
            seller: msg.sender,
            sftToken: sftToken,
            tokenId: tokenId,
            amount: amount,
            price: price,
            paymentToken: normalizePaymentToken
        });

        activeSale1155[sftToken][tokenId] = saleCounter1155;
    }

    function withdrawFees(address token) external onlyOwner {
        uint256 amount = collectedFees[token];
        require(amount > 0, "No fees to withdraw");

        collectedFees[token] = 0; // reset first

        if (token == address(0)) {
            payable(owner()).transfer(amount);
        } else {
            require(
                IERC20(token).transfer(owner(), amount),
                "ERC20 transfer failed"
            );
        }
    }
}
