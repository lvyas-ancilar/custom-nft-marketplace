const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyToken (ERC1155)", function () {

  let owner, user, token;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("MyERC1155Token");
    token = await Token.deploy(owner.address);
    await token.waitForDeployment();
  });

  it("owner can mint ERC1155 tokens", async function () {
    await token.mint(user.address, 1, 10, "0x");

    expect(await token.balanceOf(user.address, 1)).to.equal(10);
    const balance =await token.balanceOf(user.address , 1)
    console.log(balance)
  });

  it("non-owner cannot mint", async function () {
    await expect(
      token.connect(user).mint(user.address, 1, 10, "0x")
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("owner can mint batch", async function () {
    const ids = [1, 2, 3];
    const amounts = [10, 20, 30];

    await token.mintBatch(user.address, ids, amounts, "0x");

    expect(await token.balanceOf(user.address, 1)).to.equal(10);
    expect(await token.balanceOf(user.address, 2)).to.equal(20);
    expect(await token.balanceOf(user.address, 3)).to.equal(30);
  });

});
