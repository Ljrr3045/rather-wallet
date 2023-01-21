const { expect } = require("chai");
const { ethers } = require("hardhat");
const Erc20Abi = require("./contract-json/erc20.json");

describe("Rather Wallet", function () {
  let ratherWallet, usdc, dai, sushi, weth, owner, usdcWallet, daiWallet;

  const SushiSwapRouterV2 = "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F";
  const MasterChefV1 = "0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd";
  const MasterChefV2 = "0xef0881ec094552b2e128cf945ef17a6752b4ec5d";

  before(async () => {
    [owner] = await ethers.getSigners();

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x5ec9e81e8dd308e20ad92ff30d7b7b887de319ae"],
    });

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x07ede94cf6316f4809f2b725f5d79ad303fb4dc8"],
    });

    usdcWallet = await ethers.getSigner("0x5ec9e81e8dd308e20ad92ff30d7b7b887de319ae");
    daiWallet = await ethers.getSigner("0x07ede94cf6316f4809f2b725f5d79ad303fb4dc8");

    await network.provider.send("hardhat_setBalance", [
      usdcWallet.address,
      ethers.utils.formatBytes32String("5000000000000000000"),
    ]);

    await network.provider.send("hardhat_setBalance", [
      daiWallet.address,
      ethers.utils.formatBytes32String("5000000000000000000"),
    ]);

    usdc = await new ethers.Contract( "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48" , Erc20Abi );
    dai = await new ethers.Contract( "0x6B175474E89094C44Da98b954EedeAC495271d0F" , Erc20Abi );
    weth = await new ethers.Contract( "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2" , Erc20Abi );
    sushi = await new ethers.Contract( "0x6B3595068778DD592e39A122f4f5a5cF09C90fE2" , Erc20Abi );

    const RatherWallet = await ethers.getContractFactory("RatherWallet");
    ratherWallet = await RatherWallet.deploy(
      SushiSwapRouterV2,
      MasterChefV1,
      MasterChefV2
    );

    await usdc.connect(usdcWallet).transfer(owner.address, ethers.utils.parseUnits("1000", 6));
    await dai.connect(daiWallet).transfer(owner.address, ethers.utils.parseEther("1000"));
  });

  describe("Deposit and withdraw Functions",  function () {

    it("User should be able to deposit tokens", async () => {

    });
  });
});
