// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './MarketPlace.sol'  ;
import './WETH.sol';

contract MarketplaceBuy is Marketplace {

    function buy721WithETH(uint256 saleId) public payable {
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

    function buy721WithERC20(uint256 saleId) public {
        Sale721 memory s = sales721[saleId]; // copy by value

        // Basic checks
        require(s.seller != address(0), "Sale not found");
        require(s.paymentToken != address(0), "Not an ERC20 sale"); // Ensure it is an ERC20 sale
        require(s.price > 0, "Price must be greater than zero");

        uint256 fee = (s.price * 55) / 10000;
        uint256 sellerAmount = s.price - fee;

        // Transfer the ERC20 tokens from the buyer (msg.sender) to the seller/contract
        // The buyer must have previously called the ERC20 token's `approve` function
        // to grant this contract an allowance. The `transferFrom` is called by our
        // marketplace contract, pulling from the buyer's balance.

        // Get an instance of the ERC20 token contract
        IERC20 tokenContract = IERC20(s.paymentToken);

        // Transfer seller's portion
        // The require statement checks that the transfer was successful and reverts if not
        require(tokenContract.transferFrom(msg.sender, s.seller, sellerAmount), "Token transfer to seller failed");

   
       
        collectedFees[s.paymentToken] += fee; // now here the key will be s.paymentToken

        // 4. Transfer the NFT from the seller to the buyer (caller)
        IERC721(s.nftAddress).transferFrom(s.seller, msg.sender, s.tokenId);

        delete activeSale721[s.nftAddress][s.tokenId];
        delete sales721[saleId];
    }

    // paymentToken 
    // collectedFes[paymentToken] += fee 

    function buyWithAnyIn721(uint256 saleId) external payable{
         Sale721 memory s = sales721[saleId]; // copy by value 
        if(s.paymentToken == address(0)){
            buy721WithETH(saleId);
        }
        else{
            buy721WithERC20(saleId);
        }
    }

    function buy1155WithETH(uint256 saleId) public payable {
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


function buy1155WithERC20(uint256 saleId) public {
    Sale1155 memory s = sales1155[saleId];
    require(s.seller != address(0), "Sale not found");
    require(s.paymentToken != address(0), "Not an ERC20 sale"); // ERC20 sale only
    require(s.price > 0, "Price must be above zero");

    uint256 fee = (s.price * 55) / 10000;
    uint256 sellerAmount = s.price - fee;

    IERC20 payToken = IERC20(s.paymentToken);

    // Buyer must have approved this contract so transferFrom works
    require(
        payToken.transferFrom(msg.sender, s.seller, sellerAmount),
        "Token transfer to seller failed"
    );

    // Transfer fee to marketplace contract
    require(
        payToken.transferFrom(msg.sender, address(this), fee),
        "Fee transfer failed"
    );

    // Add fee to collectedFees for this specific token
    collectedFees[s.paymentToken] += fee;

    // Transfer ERC1155 token to buyer
    IERC1155(s.sftToken).safeTransferFrom(
        s.seller,
        msg.sender,
        s.tokenId,
        s.amount,
        ""
    );

    // Delete sale
    delete activeSale1155[s.sftToken][s.tokenId];
    delete sales1155[saleId];
}



    function buyWithAnyIn1155(uint256 saleId) external payable{
         Sale1155 memory s = sales1155[saleId]; // copy by value 
        if(s.paymentToken == address(0)){
            buy1155WithETH(saleId);
        }
        else{
            buy1155WithERC20(saleId);
        }
    }

}
