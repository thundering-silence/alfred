const { expect, util } = require("chai");
const { ethers } = require("hardhat");
const { constants, BigNumber, utils } = require("ethers");
const { parseEther } = require("ethers/lib/utils");

require("dotenv").config();

describe("Vault - 0vix", function () {
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

    const Vix = await hre.ethers.getContractFactory("ZeroVixPoolDelegate");
    this.vix = await Vix.deploy();
    await this.vix.deployed();

    // PROVIDER
    const ConfigProvider = await hre.ethers.getContractFactory(
      "ConfigProvider"
    );
    this.provider = await ConfigProvider.deploy();
    await this.provider.deployed();

    await this.provider.setPoolConfig(process.env["0VIX_MATIC"], [
      this.vix.address,
      ethers.constants.AddressZero,
      this.WMATIC.interface.encodeFunctionData("deposit"),
    ]);

    await this.provider.setPoolConfig(process.env["0VIX_DAI"], [
      this.vix.address,
      ethers.constants.AddressZero,
      this.WMATIC.interface.encodeFunctionData("deposit"),
    ]);

    // 0VIX
    await this.provider.setATokenFor(
      process.env["0VIX_MATIC"],
      process.env.WMATIC,
      process.env["0VIX_MATIC"]
    );
    await this.provider.setVTokenFor(
      process.env["0VIX_MATIC"],
      process.env.WMATIC,
      process.env["0VIX_MATIC"]
    );
    await this.provider.setVTokenFor(
      process.env["0VIX_DAI"],
      process.env.DAI,
      process.env["0VIX_DAI"]
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
    console.log(event.args.vault);
    expect(event).to.not.be.undefined;
    this.vault = this.Vault.attach(event.args.vault).connect(this.signers[0]);

    await this.WMATIC.approve(this.vault.address, constants.MaxUint256);
  });

  it("should allow for supplying assets to 0vix", async () => {
    await this.vault.supply(
      [
        process.env["0VIX_MATIC"],
        process.env.WMATIC,
        constants.Zero,
        process.env["0VIX_CONTROLLER"],
      ],
      {
        value: ethers.utils.parseEther("10"),
      }
    );
  });

  it("should allow for borrowing from  0vix", async () => {
    await this.vault.borrow([
      process.env["0VIX_MATIC"],
      process.env.WMATIC,
      ethers.utils.parseEther("1"),
      process.env["0VIX_CONTROLLER"],
    ]);
    const lent = await this.vault.borrowed([
      process.env["0VIX_MATIC"],
      process.env.WMATIC,
      constants.Zero,
      process.env["0VIX_CONTROLLER"],
    ]);
    expect(lent.eq(parseEther("1"))).to.be.true;
  });

  it("should repaying loans on  0vix", async () => {
    await this.vault.repay([
      process.env["0VIX_MATIC"],
      process.env.WMATIC,
      constants.Zero,
      process.env["0VIX_CONTROLLER"],
      {
        value: ethers.utils.parseEther("1.1"),
      },
    ]);
    const lent = await this.vault.borrowed([
      process.env["0VIX_MATIC"],
      process.env.WMATIC,
      constants.Zero,
      process.env["0VIX_CONTROLLER"],
    ]);
    expect(lent.eq(parseEther("0"))).to.be.true;
  });

  it("should allow for skim withdrawing assets from  0vix", async () => {
    // await this.WMATIC.approve(this.vault.address, ethers.utils.parseEther('10'))
    await this.vault.withdrawExcesses([
      [process.env["0VIX_MATIC"], process.env.WMATIC, constants.Zero],
    ]);
  });

  it("should allow for withdrawing assets from  0vix", async () => {
    await this.vault.withdraw([
      process.env["0VIX_MATIC"],
      process.env.WMATIC,
      ethers.utils.parseEther("1"),
      process.env["0VIX_CONTROLLER"],
    ]);
  });

  it("should allow for requesting swaps for assets", async () => {
    const tx = await this.vault.requestSwaps([process.env.WMATIC]);
    const receipt = await tx.wait();
    const event = receipt.events.find(
      (e) => e.address === process.env.SWAP_DATA_REQUESTER
    );
  });
});
