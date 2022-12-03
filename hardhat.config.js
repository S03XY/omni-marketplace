require("@nomicfoundation/hardhat-toolbox");
const dotenv = require("dotenv");
dotenv.config();

module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    polygonMumbai: {
      url: process.env.MUMBAI_TESTNET_HTTPS,
      accounts:
        process.env.CONTRACT_DEPLOYER !== undefined
          ? [process.env.CONTRACT_DEPLOYER]
          : [],
      gas: 2100000,
      gasPrice: 8000000000,
    },
    goerli: {
      url: process.env.GOERLI_TESTNET_HTTPS,
      accounts:
        process.env.CONTRACT_DEPLOYER !== undefined
          ? [process.env.CONTRACT_DEPLOYER]
          : [],
      // accounts: { mnemonic: process.env.MNEMONIC },
      gas: 2100000,
      gasPrice: 8000000000,
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.MUMBAI_API,
      goerli: process.env.GOERLI_API,
    },
  },
};
