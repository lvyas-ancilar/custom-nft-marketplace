const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyToken", function () {

  let owner, user, token;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("MyToken");
    token = await Token.deploy("MyToken", "MTK", 1000);
    await token.waitForDeployment();
  });

  it("deploys with correct initial supply", async function () {
    const ownerBalance = await token.balanceOf(owner.address);
    expect(ownerBalance).to.equal(1000);
  });

  it("owner can mint tokens", async function () {
    await token.mint(user.address, 500);
    expect(await token.balanceOf(user.address)).to.equal(500);
  });

  it("non-owner cannot mint tokens", async function () {
    await expect(
      token.connect(user).mint(user.address, 100)
    ).to.be.revertedWith("Not owner");
  });

});
    