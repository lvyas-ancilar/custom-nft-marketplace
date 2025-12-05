//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256) external;
    function transfer(address to, uint256 value) external returns (bool);
}

// this interface helps my buy marketplace to intercat with weth

 // conversion : If a sale is created for ETH, buyer can pay in WETH.
                    //If a sale is created for WETH, buyer can pay in ETH.

    // case 1: Sale wants ETH -> buyer pays WETH 
            // so we will unrap weth into eth 
    // Case 2:  Sale wants WETH -> buyer pays ETH 
    // we will wrap eth into weth
