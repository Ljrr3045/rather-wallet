require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("dotenv").config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  solidity: {
    compilers: [{
      version: "0.7.4"
    },
    {
      version: "0.8.4"
    }]
  },
  networks: {
    hardhat: {
      forking: {
        url: process.env.MAINNET_URL, 
        blockNumber: 16422981,
      }
    },
    bsc_testnet: {
      url: process.env.BSC_TESTNET,
      accounts:{
        mnemonic: process.env.MNEMONIC
      },
    },
    mumbai: {
      url: process.env.MUMBAI_URL,
      accounts:{
        mnemonic: process.env.MNEMONIC
      },
    },
    goerli: {
      url: process.env.GOERLI_URL,
      accounts:{
        mnemonic: process.env.MNEMONIC
      },
    },
  },
  etherscan: {
    apiKey: {
      goerli: process.env.ETHERSCAN_API_KEY,
      bscTestnet: process.env.BSC_API_KEY,
      polygonMumbai: process.env.POLYGONSCAN_API_KEY
    }
  },
  gasReporter: {
    enabled: true,
    currency: 'USD',
    token: "ETH",
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
  },
};
