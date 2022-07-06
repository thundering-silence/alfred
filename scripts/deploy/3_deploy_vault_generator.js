// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const fs = require('fs/promises');

require('dotenv').config()


async function main() {
  const VaultGenerator = await hre.ethers.getContractFactory("VaultGenerator");
  const vaultGenerator = await VaultGenerator.deploy(process.env.SWAP_DATA_REQUESTER, '0x84aeCC12beDA93058467DF79529Ca3a40D0C4194', process.env.CONFIG_PROVIDER);

  await vaultGenerator.deployed();
  await fs.appendFile('../../.env', `VAULT_GENERATOR=${vaultGenerator.address}\n`, err => console.log(err))
  console.log(`VAULT_GENERATOR=${vaultGenerator.address}\n`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
