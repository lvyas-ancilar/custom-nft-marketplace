//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract WETH is ERC20{
  address public owner;


    constructor(string memory name , string memory symbol , uint256 initialSupply)
    ERC20(name, symbol) {
        owner = msg.sender;                     
        _mint(msg.sender, initialSupply);      
    }

    fallback() external payable {
        deposit();
    }

    function deposit() public payable{
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {

    }
}