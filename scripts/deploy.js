const { ethers, upgrades } = require("hardhat");

async function main(deployer) {
  const CustomERC721UpgradeableV1 = await ethers.getContractFactory(
    "CustomERC721UpgradeableV1"
  );
  console.log("Deploying Smart Contract");
  const proxy = await upgrades.deployProxy(
    CustomERC721UpgradeableV1,
    [
      "https://gateway.pinata.cloud/ipfs/QmTArHWTbjNjcbeuewQggfRPN2PV8jrW6NQiBW4keAcb2p/",
      "https://gateway.pinata.cloud/ipfs/QmTArHWTbjNjcbeuewQggfRPN2PV8jrW6NQiBW4keAcb2p/1.json",
      "0xd227ba3c0d84000375a7b712e9dedf829760728f7ac90f8056723cd6bb757257",
    ],
    {
      initializer: "initialize",
      kind: "uups",
    }
  );

  console.log("Proxy depoyed at:", proxy.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
