const { expect, util } = require("chai");
const { ethers } = require("hardhat");
const { constants, BigNumber } = require("ethers");

require("dotenv").config();

describe("Vault - Aave V3", function () {
  before(async () => {
    this.signers = await ethers.getSigners();

    this.WMATIC = new ethers.Contract(
      process.env.WMATIC,
      [
        "function deposit() public payable",
        "function transfer(address dst, uint amt) public ",
        "function approve(address dst, uint amt) public",
      ],
      this.signers[0]
    );

    await this.WMATIC.deposit({ value: ethers.utils.parseEther("1000") });

    const AaveV3 = await hre.ethers.getContractFactory("AaveV3PoolDelegate");
    this.aaveV3 = await AaveV3.deploy();
    await this.aaveV3.deployed();

    // PROVIDER
    const ConfigProvider = await hre.ethers.getContractFactory(
      "ConfigProvider"
    );
    this.provider = await ConfigProvider.deploy();
    await this.provider.deployed();

    await this.provider.setPoolConfig(process.env.AAVE_V3_POOL, [
      this.aaveV3.address,
      ethers.constants.AddressZero,
      this.WMATIC.interface.encodeFunctionData("deposit"),
    ]);

    // AAVE V3
    await this.provider.setATokenFor(
      process.env.AAVE_V3_POOL,
      process.env.WMATIC,
      process.env.AAVE_V3_aMATIC
    );
    await this.provider.setVTokenFor(
      process.env.AAVE_V3_POOL,
      process.env.WMATIC,
      process.env.AAVE_V3_vWMATIC
    );
    await this.provider.setVTokenFor(
      process.env.AAVE_V3_POOL,
      process.env.DAI,
      process.env.AAVE_V3_vDAI
    );

    // REQUESTER
    const OneInchAdapter = await hre.ethers.getContractFactory(
      "OneInchAdapter"
    );
    this.requester = await OneInchAdapter.deploy(process.env.AGGREGATOR_v4);
    await this.requester.deployed();

    // VAULT GENERATOR
    const VaultGenerator = await hre.ethers.getContractFactory(
      "VaultGenerator"
    );
    this.vaultGenerator = await VaultGenerator.deploy(
      this.requester.address,
      "0x84aeCC12beDA93058467DF79529Ca3a40D0C4194",
      this.provider.address
    );
    await this.vaultGenerator.deployed();

    this.Vault = await hre.ethers.getContractFactory("Vault");
  });

  it("Should allow for creating a vault", async () => {
    let error;

    const tx = await this.vaultGenerator.createVault("TEST Vault");
    const receipt = await tx.wait();

    const event = receipt.events.find((e) => e.event === "VaultCreated");
    expect(event).to.not.be.undefined;
    this.vault = this.Vault.attach(event.args.vault).connect(this.signers[0]);

    await this.WMATIC.approve(this.vault.address, constants.MaxUint256);
  });

  it("should allow for supplying assets", async () => {
    await this.vault.supply([
      process.env.AAVE_V3_POOL,
      process.env.WMATIC,
      ethers.utils.parseEther("10"),
      constants.AddressZero,
    ]);
  });

  it("should allow for borrowing", async () => {
    await this.vault.borrow([
      process.env.AAVE_V3_POOL,
      process.env.WMATIC,
      ethers.utils.parseEther("1"),
      constants.AddressZero,
    ]);
    const lent = await this.vault.borrowed([
      process.env.AAVE_V3_POOL,
      process.env.WMATIC,
      constants.Zero,
      constants.AddressZero,
    ]);
    expect(lent.gte(ethers.utils.parseEther("1"))).to.be.true;
  });

  it("should repaying loans", async () => {
    const tx = await this.vault.repay([
      process.env.AAVE_V3_POOL,
      process.env.WMATIC,
      constants.MaxUint256,
      constants.AddressZero,
    ]);
    await tx.wait();
    const debt = await this.vault.currentDebtPool();

    expect(debt.eq(ethers.utils.parseEther("0"))).to.be.true;
  });

  it("should allow for skim withdrawing assets", async () => {
    await this.vault.withdrawExcesses([
      [
        process.env.AAVE_V3_POOL,
        process.env.WMATIC,
        constants.Zero,
        constants.AddressZero,
      ],
    ]);
  });

  it("should allow for withdrawing assets", async () => {
    await this.vault.withdraw([
      process.env.AAVE_V3_POOL,
      process.env.WMATIC,
      ethers.utils.parseEther("10"),
      constants.AddressZero,
    ]);
  });
});
