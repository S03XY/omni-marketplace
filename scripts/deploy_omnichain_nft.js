const hre = require("hardhat");

async function main() {
  console.log("deploying omnichainNFT contract on", hre.network.name);

  const OmnichainNFTFactory = await hre.ethers.getContractFactory(
    "OnmichainNFT"
  );
  const OmnichainNFT = await OmnichainNFTFactory.deploy("shashank.omni", "SPO");
  await OmnichainNFT.deployed();
  console.log(`OmnichainNFT contract is deployed on ${OmnichainNFT.address}`);
  console.log("waiting for 1 minute");
  await sleep(60000);
  console.log("verifying contract..");
  await hre.run("verify:verify", {
    address: OmnichainNFT.address,
    constructorArguments: ["shashank.omni", "SPO"],
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
