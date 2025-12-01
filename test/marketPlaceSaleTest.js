const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Test for createSaleOrderFor721", function () {
  let owner, seller, nft, marketplace;

  beforeEach(async () => {
    [owner, seller] = await ethers.getSigners();

    // Deploy simple ERC721
    const NFT = await ethers.getContractFactory("MyNFT721");
    nft = await NFT.deploy("MyNFT", "MNFT");
    await nft.waitForDeployment();

    // Deploy marketplace
    const Marketplace = await ethers.getContractFactory("Marketplace");
    marketplace = await Marketplace.deploy();
    await marketplace.waitForDeployment();

    // Mint token for seller 
    await nft.connect(owner).mint(seller.address);
  });

  it("should create a sale for ERC721", async () => {
    // Approve marketplace
    await nft.connect(seller).approve(await marketplace.getAddress(), 0); // here we approving the market place so tha it can tranfer on behalf of seller
    // tokenId = 0 because nextTokenId starts from 0

    // Creating the sale at marketplace 
    await marketplace.connect(seller).createSaleOrderFor721(
      await nft.getAddress(),
      0,                           // tokenId = 0
      ethers.parseEther("1"),      // price = 1 ETH
      ethers.ZeroAddress           // accept ETH
    );

    // saleCounter should now be 1
    expect(await marketplace.saleCounter721()).to.equal(1);

    // activeSale should map NFT + tokenId -> saleId
    const saleId = await marketplace.activeSale721(await nft.getAddress(), 0);
    expect(saleId).to.equal(1);

    // sale details check
    const sale = await marketplace.sales721(1);
    console.log(sale)
    console.log(sale.seller)
    console.log(sale.tokenId)
    console.log(sale.price)


    expect(sale.seller).to.equal(seller.address);
    
    expect(sale.tokenId).to.equal(0n);
    
    expect(sale.price).to.equal(ethers.parseEther("1"));
   

    console.log("sale created for 721");
  });
});
