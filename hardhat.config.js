require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const WEB3_INFURA_PROJECT_ID = process.env.WEB3_INFURA_PROJECT_ID;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    local: {
      url: "http://127.0.0.1:8545/",
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${WEB3_INFURA_PROJECT_ID}`,
      accounts: [PRIVATE_KEY],
      saveDeployments: true,
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${WEB3_INFURA_PROJECT_ID}`,
      accounts: [PRIVATE_KEY],
      saveDeployments: true,
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${WEB3_INFURA_PROJECT_ID}`,
      accounts: [PRIVATE_KEY],
      saveDeployments: true,
    },
  },

  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  namedAccounts: {
    deployer: {
      default: 0,
      1: 0,
    },
    feeCollector: {
      default: 1,
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};
