const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Marketplace transferAnyNft Test", function () {

  it("Should transfer NFT from marketplace to another address", async function () {

    const [owner, receiver] = await ethers.getSigners();
    console.log("Owner:", owner.address);
    console.log("Receiver:", receiver.address);

    // Deploy the demo NFT
    const TestNFT = await ethers.getContractFactory("MyNFT721");
    const nft = await TestNFT.deploy("TestNFT", "TN");
    await nft.waitForDeployment();
    console.log("NFT Address:", await nft.getAddress());

    // Minting the  NFT (tokenId = 0)
    await nft.mint(owner.address);
    console.log("Minted tokenId:", 0);

  // Deploying the Marketplace
    const Marketplace = await ethers.getContractFactory("Marketplace");
    const market = await Marketplace.deploy();
    await market.waitForDeployment();
    console.log("Marketplace Address:", await market.getAddress());

    // Approve marketplace to transfer tokenId 0
    await nft.approve(await market.getAddress(), 0);
    console.log("Marketplace approved for tokenId 0");

    // Transfer NFT into marketplace
    await nft.transferFrom(owner.address, await market.getAddress(), 0);
    console.log("NFT moved to marketplace");

    // Call transferAnyNft
    await market.transferAnyNft(await nft.getAddress(), receiver.address, 0);
    console.log("transferAnyNft called successfully");

    // Check final owner
    const newOwner = await nft.ownerOf(0);
    console.log("New Owner of token 0:", newOwner);

    expect(newOwner).to.equal(receiver.address);
  });

});



// step 1 derploy nft contracts (1,2)
    // step 2 deploy market place which contains tranferAnyNft
    // step3 writ simple test in which user1 calling transferAnyNft method and transfering NFT to user2
    // step 4 make direct call you will get error 
    // step5 resollve error 
    // step now you have understnding of assingnment.