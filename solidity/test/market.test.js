const { solidity } = require("ethereum-waffle");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const { expect, use } = require("chai");

use(solidity);

describe("Market", () => {
  let Market, tokenA, tokenB;
  let deployer, user, market;

  async function deployContract(name, ...rest) {
    const Contract = await ethers.getContractFactory(name);
    const instance = await Contract.deploy(...rest);

    return [Contract, instance];
  }

  beforeEach(async () => {
    [deployer, user] = await ethers.getSigners();

    [tokenA, tokenA] = await deployContract(
      "Erc20TokenWithFaucet",
      ...["Silver", "SLV"]
    );
    await tokenA.connect(user).faucet(); // drips 100

    [tokenB, tokenB] = await deployContract(
      "Erc20TokenWithFaucet",
      ...["Gold", "GLD"]
    );
    await tokenB.connect(user).faucet(); // drips 100

    [Market, market] = await deployContract(
      "Market",
      tokenA.address,
      tokenB.address
    );
  });

  describe("provideLiquidity", () => {
    context("user has tokens", async () => {
      beforeEach(async () => {
        await tokenA.connect(user).approve(market.address, 100);
        await tokenB.connect(user).approve(market.address, 50);
        await market.connect(user).provideLiquidity(100, 50);
      });

      it("adds liquidity to the market", async () => {
        const totalReserve = await market.totalReserve();

        expect(totalReserve[0]).to.equal(BigNumber.from(100));
        expect(totalReserve[1]).to.equal(BigNumber.from(50));
      });

      it("removes the tokens from the sender", async () => {
        const startingBalanceA = await tokenA.balanceOf(user.address);
        const startingBalanceB = await tokenB.balanceOf(user.address);

        const endingBalanceA = await tokenA.balanceOf(user.address);
        const endingBalanceB = await tokenB.balanceOf(user.address);

        expect(parseInt(startingBalanceA.toString()) - 100).to.equal(
          parseInt(endingBalanceA.toString())
        );

        expect(parseInt(startingBalanceB.toString()) - 50).to.equal(
          parseInt(endingBalanceB.toString())
        );
      });
    });
  });

  describe("totalReserve", () => {
    beforeEach(async () => {
      await tokenA.connect(user).approve(market.address, 100);
      await tokenB.connect(user).approve(market.address, 50);
      await market.connect(user).provideLiquidity(100, 50);
    });

    it("returns an array of the reserve amounts", async () => {
      const reserves = await market.connect(user).totalReserve();

      expect(reserves[0].toString()).to.equal("100");
      expect(reserves[1].toString()).to.equal("50");
    });
  });

  describe("balanceOf", () => {
    beforeEach(async () => {
      await tokenA.connect(user).approve(market.address, 100);
      await tokenB.connect(user).approve(market.address, 50);
      await market.connect(user).provideLiquidity(100, 50);
    });

    it("returns an array of the reserve amounts", async () => {
      const balances = await market.connect(user).balanceOf(user.address);

      expect(balances[0].toString()).to.equal("100");
      expect(balances[1].toString()).to.equal("50");
    });
  });

  describe("reserveOf", () => {
    beforeEach(async () => {
      await tokenA.connect(user).approve(market.address, 100);
      await tokenB.connect(user).approve(market.address, 50);
      await market.connect(user).provideLiquidity(100, 50);
    });

    it("returns an array of the reserve amounts", async () => {
      const reserveTokenA = await market
        .connect(user)
        .reserveOf(tokenA.address);

      expect(reserveTokenA.toString()).to.equal("100");
    });
  });
});
