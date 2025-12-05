const { expect } = require("chai");
const { ethers } = require("hardhat");


function calculateFee(amountWei) {
  const basis_point_fee = 55n;        // 55 basis points = 0.55%
  const basis_point_div = 10000n; // standard basis point divisor as 100% is 10,000

  return (amountWei * basis_point_fee) / basis_point_div;
}

describe("Marketplace Buy Functions", function () {
  let owner, seller, buyer, nft721, nft1155, marketplace, erc20;


  beforeEach(async () => {
    [owner, seller, buyer] = await ethers.getSigners();

    // Deploy 721 NFT
    const NFT721 = await ethers.getContractFactory("MyNFT721");
    nft721 = await NFT721.deploy("MyNFT", "MNFT");
    await nft721.waitForDeployment();

    // Deploy 1155 NFT
    const NFT1155 = await ethers.getContractFactory("MyERC1155Token");
    nft1155 = await NFT1155.deploy();
    await nft1155.waitForDeployment();

    // Deploy MyToken erc20 token 
    const Token = await ethers.getContractFactory("MyToken");
    erc20 = await Token.deploy("MyToken", "MTK", ethers.parseEther("1000000"));
    await erc20.waitForDeployment();

    // Deploy MarketplaceBuy (inheriting the Marketplace)
    const Marketplace = await ethers.getContractFactory("MarketplaceBuy");
    marketplace = await Marketplace.deploy();
    await marketplace.waitForDeployment();

    // Mint NFTs
    await nft721.connect(owner).mint(seller.address); // tokenId = 0
    await nft1155.connect(owner).mint(seller.address, 1, 100);

    // Seller approves marketplace
    await nft721.connect(seller).approve(await marketplace.getAddress(), 0);
    await nft1155.connect(seller).setApprovalForAll(await marketplace.getAddress(), true);

    // Give buyer ERC20 tokens
    await erc20.transfer(buyer.address, ethers.parseEther("1000"));
  });

  
  it("Buy ERC721 with ETH", async () => {
    await marketplace.connect(seller).createSaleOrderFor721(
      await nft721.getAddress(),
      0,
      ethers.parseEther("1"),
      ethers.ZeroAddress
    );

    const sellerBefore = await ethers.provider.getBalance(seller.address);
    console.log(sellerBefore)
    await marketplace.connect(buyer).buy721WithETH(1, { value: ethers.parseEther("1") });

    const sellerAfter = await ethers.provider.getBalance(seller.address);
    console.log(sellerAfter)
    //1e18 wei = 1 ETH
    //55 / 10000 = 0.55%
    //fee = 1 ETH ka 0.55%
    //sellerAmount = 1 ETH - fee
   // const ONE_ETH = 10n ** 18n; // 1 ETH in wei
    //const fee = (ONE_ETH * 55n) / 10000n;
    //const sellerAmount = ONE_ETH - fee;
    const ONE_ETH = ethers.parseEther("1");
    const fee = calculateFee(ONE_ETH);
    const sellerAmount = ONE_ETH - fee;
    //const fee = (1e18 * 55n) / 10000n; // 0.55%
    //const sellerAmount = 1e18 - fee;

    expect(sellerAfter - sellerBefore).to.be.closeTo(
      sellerAmount,
      ethers.parseEther("0.0001") // gas tolerance
    );

    expect(await nft721.ownerOf(0)).to.equal(buyer.address);
  });

  
  it("Buy ERC721 with ERC20", async () => {
    await marketplace.connect(seller).createSaleOrderFor721(
      await nft721.getAddress(),
      0,
      ethers.parseEther("10"),
      await erc20.getAddress()
    );

    await erc20.connect(buyer).approve(await marketplace.getAddress(), ethers.parseEther("10"));
    // the buyer approve to marketplace to withdraw 10 erc2 token 
    await marketplace.connect(buyer).buy721WithERC20(1);
    //buyer calls buy721WithERC20 with the listing ID 1.
    expect(await nft721.ownerOf(0)).to.equal(buyer.address);
    // confirms that nft is transfeed
    const fee = (10n * 10n ** 18n * 55n) / 10000n; // price set is 10 so 10 * 10 power 18 and then mul;tiply by 55 basis points     
    expect(await marketplace.collectedFees(await erc20.getAddress())).to.equal(fee);
  });


  it("Buy ERC1155 with ETH", async () => {
    await marketplace.connect(seller).createSaleOrderFor1155(
      await nft1155.getAddress(),
      1,
      10,
      ethers.parseEther("2"),
      ethers.ZeroAddress
    );
  const sellerBefore = await ethers.provider.getBalance(seller.address);
    await marketplace.connect(buyer).buy1155WithETH(1, { value: ethers.parseEther("2") });

    const sellerAfter = await ethers.provider.getBalance(seller.address);

    const TWO_ETH = 2n * 10n ** 18n;
    const fee = (TWO_ETH * 55n) / 10000n;
    const sellerAmount = TWO_ETH - fee;

  expect(sellerAfter - sellerBefore).to.be.closeTo(
    sellerAmount,
    ethers.parseEther("0.0001")
  );

    expect(await marketplace.collectedFees(ethers.ZeroAddress)).to.equal(fee);

    const balance = await nft1155.balanceOf(buyer.address, 1);
    expect(balance).to.equal(10);
  });


  it("Buy ERC1155 with ERC20", async () => {
    await marketplace.connect(seller).createSaleOrderFor1155(
      await nft1155.getAddress(),
      1,
      20,
      ethers.parseEther("5"),
      await erc20.getAddress()
    );

    await erc20.connect(buyer).approve(await marketplace.getAddress(), ethers.parseEther("5"));

    await marketplace.connect(buyer).buy1155WithERC20(1);

   const fee = (5n * 10n ** 18n * 55n) / 10000n; 

  expect(await marketplace.collectedFees(await erc20.getAddress())).to.equal(fee);


    const balance = await nft1155.balanceOf(buyer.address, 1);
    expect(balance).to.equal(20);
  });
});
