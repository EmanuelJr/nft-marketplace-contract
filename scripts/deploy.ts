import { ethers } from "hardhat";

async function main() {
  const storageFee = ethers.utils.parseEther("0.0035");

  const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
  const nftMarketplace = await NFTMarketplace.deploy(storageFee);

  await nftMarketplace.deployed();

  console.log(`NFTMarketplace deployed to ${nftMarketplace.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
