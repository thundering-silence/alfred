// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const fs = require('fs');
const { constants } = require('ethers')

require('dotenv').config()


async function main() {
  const ConfigProvider = await hre.ethers.getContractFactory("ConfigProvider");
  const provider = await ConfigProvider.deploy();

  await provider.deployed();
  fs.writeFileSync('../../.env', `CONFIG_PROVIDER=${provider.address}\n`)

  console.log(`CONFIG_PROVIDER=${provider.address}\n`);

  await provider.setPoolConfig(process.env.AAVE_V2_POOL, [
    process.env.AAVE_V2_DELEGATE, constants.AddressZero, ethers.utils.randomBytes(10)
  ])
  await provider.setPoolConfig(process.env.AAVE_V3_POOL, [
    process.env.AAVE_V3_DELEGATE, constants.AddressZero, ethers.utils.randomBytes(10)
  ])
  await provider.setATokenFor(process.env.AAVE_V2_POOL, process.env.WMATIC, process.env.AAVE_V2_aMATIC)
  await provider.setATokenFor(process.env.AAVE_V3_POOL, process.env.WMATIC, process.env.AAVE_V3_aMATIC)
  await provider.setVTokenFor(process.env.AAVE_V2_POOL, process.env.DAI, process.env.AAVE_V2_vDAI)
  await provider.setVTokenFor(process.env.AAVE_V3_POOL, process.env.DAI, process.env.AAVE_V3_vDAI)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
