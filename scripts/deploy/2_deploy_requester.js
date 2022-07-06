// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const fs = require('fs')

require('dotenv').config()


async function main() {
  const OneInchAdapter = await hre.ethers.getContractFactory("OneInchAdapter");
  const requester = await OneInchAdapter.deploy(process.env.AGGREGATOR_v4);

  await requester.deployed();
  fs.writeFileSync('../../.env', `SWAP_DATA_REQUESTER=${requester.address}\n`)

  console.log(`SWAP_DATA_REQUESTER=${requester.address}\n`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
