// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './MarketPlace.sol'  ;

contract MarketplaceBuy is Marketplace {
    

    function buy721WithETH(uint256 saleId) external payable {
        Sale721 memory s = sales721[saleId]; // copy by value 
        require(s.seller != address(0), "Sale not found");
        require(s.paymentToken == address(0), "Not ETH sale");
        require(msg.value == s.price, "Wrong ETH");
        // 1% == 100 basis points , so 100% = 10,000 basis points 
        // so 0.55 % = 55 basis points 
        // 0.55 = 55/100 but in basis points term below 
        uint256 fee = (s.price * 55) / 10000;
        uint256 sellerAmount = s.price - fee;

        collectedFees[address(0)] += fee;

        payable(s.seller).transfer(sellerAmount); // basically transfeering to seller aftr cutting the fee of 0.55% 

        IERC721(s.nftAddress).transferFrom(s.seller, msg.sender, s.tokenId); // transferring the owner of token id to seller to the caller which is msg.sender

        delete activeSale721[s.nftAddress][s.tokenId];
        delete sales721[saleId];
    }



    function buy1155WithETH(uint256 saleId) external payable {
    Sale1155 memory s = sales1155[saleId]; // here we are dong copy by value 
    require(s.seller != address(0), "Sale not found");
    require(s.paymentToken == address(0), "Not ETH sale");

    uint256 price = s.price;

    // Buyer must send correct ETH
    require(msg.value == price, "Incorrect ETH sent");

    // Fee calculation
    uint256 fee = (price * 55) / 10000;
    uint256 sellerAmount = price - fee;

    // Store fee
    collectedFees[address(0)] += fee;

    // Pay seller
    payable(s.seller).transfer(sellerAmount);

    // Transfer ERC1155 tokens to buyer
    IERC1155(s.sftToken).safeTransferFrom(
        s.seller,
        msg.sender,
        s.tokenId,
        s.amount,
        ""
    );
    delete activeSale1155[s.sftToken][s.tokenId];
    delete sales1155[saleId];
}

}
