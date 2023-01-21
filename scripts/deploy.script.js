const {ethers} = require("hardhat");

async function deploy() {

  const SushiSwapRouterV2 = "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F";
  const MasterChefV1 = "0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd";
  const MasterChefV2 = "0xef0881ec094552b2e128cf945ef17a6752b4ec5d";

  const RatherWallet = await ethers.getContractFactory("RatherWallet");
  const ratherWallet = await RatherWallet.deploy(
    SushiSwapRouterV2,
    MasterChefV1,
    MasterChefV2
  );

  console.log("RatherWallet deployed to:", ratherWallet.address);
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
