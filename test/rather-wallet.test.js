const { expect } = require("chai");
const { ethers } = require("hardhat");
const Erc20Abi = require("./contract-json/erc20.json");

describe("Rather Wallet", function () {
  let ratherWallet, usdc, alchemix, sushi, weth, owner, fakeUser, deadWallet, usdcWallet, alchemixWallet;

  const SushiSwapRouterV2 = "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F";
  const MasterChefV1 = "0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd";
  const MasterChefV2 = "0xEF0881eC094552b2e128Cf945EF17a6752B4Ec5d";

  before(async () => {
    [owner, fakeUser, deadWallet] = await ethers.getSigners();

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x5ec9e81e8dd308e20ad92ff30d7b7b887de319ae"],
    });

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x28133497d0cb6dac7131adc2421c01b2fcd448e5"],
    });

    usdcWallet = await ethers.getSigner("0x5ec9e81e8dd308e20ad92ff30d7b7b887de319ae");
    alchemixWallet = await ethers.getSigner("0x28133497d0cb6dac7131adc2421c01b2fcd448e5");

    await network.provider.send("hardhat_setBalance", [
      usdcWallet.address,
      ethers.utils.formatBytes32String("5000000000000000000"),
    ]);

    await network.provider.send("hardhat_setBalance", [
      alchemixWallet.address,
      ethers.utils.formatBytes32String("5000000000000000000"),
    ]);

    usdc = await new ethers.Contract( "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48" , Erc20Abi );
    alchemix = await new ethers.Contract( "0xdBdb4d16EdA451D0503b854CF79D55697F90c8DF" , Erc20Abi );
    weth = await new ethers.Contract( "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2" , Erc20Abi );
    sushi = await new ethers.Contract( "0x6B3595068778DD592e39A122f4f5a5cF09C90fE2" , Erc20Abi );

    const RatherWallet = await ethers.getContractFactory("RatherWallet");
    ratherWallet = await RatherWallet.deploy(
      SushiSwapRouterV2,
      MasterChefV1,
      MasterChefV2
    );

    // Cleaning Owner Wallet
    await usdc.connect(owner).transfer(deadWallet.address, usdc.connect(owner).balanceOf(owner.address));
    await alchemix.connect(owner).transfer(deadWallet.address, alchemix.connect(owner).balanceOf(owner.address));

    // Balanced correctly owner wallet
    await usdc.connect(usdcWallet).transfer(owner.address, ethers.utils.parseUnits("1000", 6));
    await alchemix.connect(alchemixWallet).transfer(owner.address, ethers.utils.parseEther("1000"));
  });

  describe("Deposit and withdraw Functions",  function () {

    it("Owner should be able to deposit tokens", async () => {

      await usdc.connect(owner).approve(ratherWallet.address, ethers.utils.parseUnits("1000", 6));
      await alchemix.connect(owner).approve(ratherWallet.address, ethers.utils.parseEther("1000"));

      await ratherWallet.connect(owner).depositToken(usdc.address, ethers.utils.parseUnits("1000", 6));
      await ratherWallet.connect(owner).depositToken(alchemix.address, ethers.utils.parseEther("1000"));

      expect(await usdc.connect(owner).balanceOf(ratherWallet.address)).to.equal(ethers.utils.parseUnits("1000", 6));
      expect(await alchemix.connect(owner).balanceOf(ratherWallet.address)).to.equal(ethers.utils.parseEther("1000"));
    });

    it("revert - only owner should be able to deposit tokens", async () => {
      await expect(
        ratherWallet.connect(fakeUser).depositToken(usdc.address, ethers.utils.parseUnits("1000", 6))
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Owner should be able to deposit ETH", async () => {

      await ratherWallet.connect(owner).depositETH({ value: ethers.utils.parseEther("50") });

      expect(await weth.connect(owner).balanceOf(ratherWallet.address)).to.equal(ethers.utils.parseEther("50"));
    });

    it("revert - only owner should be able to deposit ETH", async () => {
      await expect(
        ratherWallet.connect(fakeUser).depositETH({ value: ethers.utils.parseEther("50") })
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Owner should be able to withdraw tokens", async () => {

      await ratherWallet.connect(owner).withdrawToken(usdc.address, ethers.utils.parseUnits("50", 6));
      expect(await usdc.connect(owner).balanceOf(owner.address)).to.equal(ethers.utils.parseUnits("50", 6));
    });

    it("revert - only owner should be able to withdraw tokens", async () => {
      await expect(
        ratherWallet.connect(fakeUser).withdrawToken(usdc.address, ethers.utils.parseUnits("50", 6))
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Owner should be able to withdraw ETH", async () => {

      await ratherWallet.connect(owner).withdrawETH(ethers.utils.parseEther("5"));

      expect(await ethers.provider.getBalance(ratherWallet.address)).to.equal(0);
      expect(await weth.connect(owner).balanceOf(ratherWallet.address)).to.equal(ethers.utils.parseEther("45"));
    });

    it("revert - only owner should be able to withdraw ETH", async () => {
      await expect(
        ratherWallet.connect(fakeUser).withdrawETH(ethers.utils.parseEther("5"))
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });

  describe("Joining the liquidity mining program", function () {

    describe("MasterChef V1", function () {

      it("Invest USDC-WETH", async () => {

        await ratherWallet.connect(owner).investInMiningProgram(weth.address, usdc.address, 0);

        const poolDepositData = await ratherWallet.connect(owner).poolDepositInMasterChefV1(
          "0x397FF1542f962076d0BFE58eA045FfA2d347ACa0"
        );

        expect(poolDepositData.deposit).to.equal("13746135598656");
        expect(await usdc.connect(owner).balanceOf(ratherWallet.address)).to.equal(0);
        expect(await weth.connect(owner).balanceOf(ratherWallet.address)).to.equal("44428461733044651720");
      });

      it("Withdraw USDC-WETH", async () => {

        await network.provider.send("evm_increaseTime", [604800]);
        await network.provider.send("evm_mine");

        expect(await sushi.connect(owner).balanceOf(ratherWallet.address)).to.equal(0);
        expect(await sushi.connect(owner).balanceOf(owner.address)).to.equal(0);

        await ratherWallet.connect(owner).withdrawInMiningProgram(weth.address, usdc.address, 0);

        const poolDepositData = await ratherWallet.connect(owner).poolDepositInMasterChefV1(
          "0x397FF1542f962076d0BFE58eA045FfA2d347ACa0"
        );

        expect(poolDepositData.deposit).to.equal(0);
        expect(await usdc.connect(owner).balanceOf(ratherWallet.address)).to.equal("949999999");
        expect(await sushi.connect(owner).balanceOf(ratherWallet.address)).to.equal("67050245247998");
        expect(await weth.connect(owner).balanceOf(ratherWallet.address)).to.equal("44999999999999975770");
      });
    });

    describe("MasterChef V2", function () {

      it("Invest ALCX-WETH", async () => {

        await ratherWallet.connect(owner).investInMiningProgram(weth.address, alchemix.address, 1);

        const poolDepositData = await ratherWallet.connect(owner).poolDepositInMasterChefV2(
          "0xC3f279090a47e80990Fe3a9c30d24Cb117EF91a8"
        );

        expect(poolDepositData.deposit).to.equal("89900399590052169293");
        expect(await alchemix.connect(owner).balanceOf(ratherWallet.address)).to.equal(0);
        expect(await weth.connect(owner).balanceOf(ratherWallet.address)).to.equal("34374160492239720653");
      });

      it("Withdraw ALCX-WETH", async () => {

        await network.provider.send("evm_increaseTime", [604800]);
        await network.provider.send("evm_mine");

        expect(await sushi.connect(owner).balanceOf(ratherWallet.address)).to.equal("67050245247998");
        expect(await sushi.connect(owner).balanceOf(owner.address)).to.equal(0);

        await ratherWallet.connect(owner).withdrawInMiningProgram(weth.address, alchemix.address, 1);

        const poolDepositData = await ratherWallet.connect(owner).poolDepositInMasterChefV2(
          "0xC3f279090a47e80990Fe3a9c30d24Cb117EF91a8"
        );

        expect(poolDepositData.deposit).to.equal(0);
        expect(await alchemix.connect(owner).balanceOf(ratherWallet.address)).to.equal("1000000358448805536191");
        expect(await weth.connect(owner).balanceOf(ratherWallet.address)).to.equal("44999999999999975769");
      });
    });
  });
});
