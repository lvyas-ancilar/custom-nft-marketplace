const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("MyNFT721Module2", (m) => {
  
  // constructor arguments
  const name = "MyNFT-2";
  const symbol = "MN-2";

  const myNFT = m.contract("MyNFT721", [name, symbol]);

  return { myNFT };
});

// THIS IS THE FIRST NFT WHICH I DEPLOYED 
// MyNFT721Module#MyNFT721 - 0x5FbDB2315678afecb367f032d93F642f64180aa3


// MyNFT721Module#MyNFT721 - 0x5FbDB2315678afecb367f032d93F642f64180aa3
// MyNFT721Module2#MyNFT721 - 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512