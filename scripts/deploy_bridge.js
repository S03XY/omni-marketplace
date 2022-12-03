const hre = require("hardhat");

async function main() {
  const connextAddress = "0xb35937ce4fFB5f72E90eAD83c10D33097a4F18D2";
  console.log("deploying bridge contract on", hre.network.name);

  const BridgeFactory = await hre.ethers.getContractFactory("Bridge");
  const Bridge = await BridgeFactory.deploy(connextAddress);
  await Bridge.deployed();
  console.log(`Bridge contract is deployed on ${Bridge.address}`);
  console.log("waiting for 1 minute");
  await sleep(60000);
  console.log("verifying contract..");
  await hre.run("verify:verify", {
    address: Bridge.address,
    constructorArguments: [connextAddress],
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
