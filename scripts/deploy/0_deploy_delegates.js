// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const fs = require('fs')

require('dotenv').config()


async function main() {
    const AaveV2 = await hre.ethers.getContractFactory("AaveV2PoolDelegate");
    const aaveV2 = await AaveV2.deploy();
    await aaveV2.deployed();
    fs.writeFileSync('../../.env', `AAVE_V2_DELEGATE=${aaveV2.address}\n`)
    console.log(`AAVE_V2_DELEGATE=${aaveV2.address}\n`);

    const AaveV3 = await hre.ethers.getContractFactory("AaveV3PoolDelegate");
    const aaveV3 = await AaveV3.deploy();
    await aaveV3.deployed();
    fs.writeFileSync('../../.env', `AAVE_V3_DELEGATE=${aaveV3.address}\n`)
    console.log(`AAVE_V3_DELEGATE=${aaveV3.address}\n`);

    // const Comp = await hre.ethers.getContractFactory("CompPoolDelegate");
    // const comp = await Comp.deploy();
    // await comp.deployed();
    // fs.writeFileSync('../../.env', `COMP_DELEGATE=${comp.address}\n`)
    // console.log(`COMP_DELEGATE=${comp.address}\n`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
