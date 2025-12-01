// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT721 is ERC721, Ownable {
    uint256 public nextTokenId;

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol){}

    function mint(address to) external onlyOwner {
        _mint(to, nextTokenId);
        nextTokenId++;
    }
}
