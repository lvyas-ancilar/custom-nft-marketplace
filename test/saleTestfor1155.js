const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Test for createSaleOrderFor1155", function () {
  let owner, seller, sft, marketplace;
    // Dummy WETH address for testing

  beforeEach(async () => {
    [owner, seller] = await ethers.getSigners();

    // Deploy ERC1155
    const SFT = await ethers.getContractFactory("MyERC1155Token");
    sft = await SFT.deploy();
    await sft.waitForDeployment();

    // Deploy Marketplace
    const Marketplace = await ethers.getContractFactory("Marketplace");
    marketplace = await Marketplace.deploy();
    await marketplace.waitForDeployment();

    // Mint tokenId=1, amount=100 to seller
    await sft.connect(owner).mint(seller.address, 1, 100);
  });

  it("create a sale for ERC1155", async () => {
    // Approve marketplace
    await sft.connect(seller).setApprovalForAll(
      await marketplace.getAddress(),
      true
    );

    // Create sale (tokenId = 1, selling amount = 10, price = 2 ETH)
    await marketplace.connect(seller).createSaleOrderFor1155(
      await sft.getAddress(),       // sftToken
      1,                             // tokenId
      10,                            // amount for sale
      ethers.parseEther("2"),        // price
      ethers.ZeroAddress             // payment in ETH
    );

    // saleCounter should now be 1
   const saleCounter =  expect(await marketplace.saleCounter1155()).to.equal(1);
    console.log(saleCounter)

    // activeSale1155 mapping check
    const saleId = await marketplace.activeSale1155(await sft.getAddress(), 1);
    expect(saleId).to.equal(1);
    console.log(saleId)

    // Get sale struct
    const sale = await marketplace.sales1155(1);
    console.log(sale)

    expect(sale.seller).to.equal(seller.address);
    expect(sale.sftToken).to.equal(await sft.getAddress());
    expect(sale.tokenId).to.equal(1n);
    expect(sale.amount).to.equal(10n);
    expect(sale.price).to.equal(ethers.parseEther("2"));
    expect(sale.paymentToken).to.equal(ethers.ZeroAddress);

    console.log("Sale created for ERC1155 successfully!");
  });
});
