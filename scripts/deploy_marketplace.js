const hre = require("hardhat");

async function main() {
  const omnichainNFTContract = "0x83dC011B1ddA76B6ba7733ba58dcf9D260C41364";
  console.log("deploying marketplace contract on", hre.network.name);

  const MarketplaceFactory = await hre.ethers.getContractFactory("Marketplace");
  const Marketplace = await MarketplaceFactory.deploy(omnichainNFTContract);
  await Marketplace.deployed();
  console.log(`Marketplace contract is deployed on ${Marketplace.address}`);
  console.log("waiting for 1 minute");
  await sleep(60000);
  console.log("verifying contract..");
  await hre.run("verify:verify", {
    address: Marketplace.address,
    constructorArguments: [omnichainNFTContract],
  });
}

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
