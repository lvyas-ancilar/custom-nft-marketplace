// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import {MyToken} from './MyToken.sol';

contract Marketplace is Ownable{
    MyToken public mytoken;

    
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



mapping(uint256 => Sale1155) public sales1155;
mapping(uint256 => Sale721) public sales721; // ye mapping har saleId ko sale se store kar rahi haii
uint256 public saleCounter721;
uint256 public saleCounter1155;



    function transferAnyNft(  address nftAddress, address to, uint256 tokenId ) external onlyOwner {

        IERC721 nft = IERC721(nftAddress);

        // Check contract owns this NFT
        require(
            nft.ownerOf(tokenId) == address(this),
            "Marketplace does not own this NFT"
        );

        // Transfer NFT
        nft.transferFrom(address(this), to, tokenId);
    }

    // Create sale 721
    // Create sale 1155
    // Update sale
    // Buy with ETH
    // Buy with ERC20
    // Buy with WETH
    // Fee calculation
    // Ownership validation
    // NFT transfer
    // onReceived() revert




    // sale function for nft 721 , where the seller can put its digital asset without giving ownership to the market 
    function createSellOrderFor721(address nftAddress, uint256 tokenId,  uint256 price , address paymentToken) external {
    
        // Ensure the price is valid
        require(price > 0, "Price must be above zero");

        // Ensure the seller actually owns the tokens they are trying to sell
        IERC721 nft = IERC721(nftAddress); // type of ierc721 is nft and we are creating the instance of that 
        require(nft.ownerOf(tokenId) == msg.sender, "Not owner of token");

       // Ensure the marketplace is approved to move the tokens on behalf of seller
        require(nft.getApproved(tokenId) == address(this));
        
        //If the seller passes address(0)  it means they want ETH payment
        //Because address(0) = no ERC20 token provided  default to ETH
        address normalizePaymentToken;

        if (paymentToken == address(0)) {
            // Treat zero address as ETH
            normalizePaymentToken = address(0);
        } else {
            normalizePaymentToken = paymentToken;
        }
         saleCounter721++; // increment basic sale id


        sales721[saleCounter721] = Sale721({
        seller: msg.sender,
        nftAddress: nftAddress,
        tokenId: tokenId,
        price: price, 
        paymentToken:paymentToken
        });


    }

    function createSellOrderFor1155(address sftToken, uint256 tokenId, uint amount, uint256 price, address paymentToken )external{
        // Ensure the price is valid
      require(price > 0, "Price must be above zero");
    require(amount > 0, "Amount must be above zero");   
        IERC1155 sft = IERC1155(sftToken); 


     saleCounter1155++; // increment sale id

     sales1155[saleCounter1155] = Sale1155({
        seller: msg.sender,
        sftToken: sftToken,
        tokenId: tokenId,
        amount: amount,
        price: price,
        paymentToken: paymentToken
    });

    }

}

