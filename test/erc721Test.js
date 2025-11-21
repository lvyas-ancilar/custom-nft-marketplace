const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyNFT721", function () {

  let owner, user, nft;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    const NFT = await ethers.getContractFactory("MyNFT721");
    nft = await NFT.deploy("TestNFT", "TNFT");
    await nft.waitForDeployment();
  });

  it("owner can mint NFT", async function () {
    await nft.mint(user.address);

    expect(await nft.ownerOf(0)).to.equal(user.address);
  });

  it("non-owner cannot mint", async function () {
    await expect(
      nft.connect(user).mint(user.address)
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

});
