const { ethers, upgrades } = require("hardhat");

async function main() {
  console.log("Upgrading smart contract");
  const CustomERC721UpgradeableV2 = await ethers.getContractFactory(
    "CustomERC721UpgradeableV2"
  );
  let upgradeNft = await upgrades.upgradeProxy(
    "0x21310F5329e7B8767FE20dFd65ad83510b53f1c2",
    CustomERC721UpgradeableV2,
    { kind: "uups" }
  );

  console.log("Your upgrading proxies is done", upgradeNft.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
