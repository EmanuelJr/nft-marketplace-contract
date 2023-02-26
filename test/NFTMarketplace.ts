import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("NFTMarketplace", function () {
  async function deployContract() {
    const [owner, otherAccount] = await ethers.getSigners();

    const storageFee = ethers.utils.parseEther("0.0035");
    const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
    const nftMarketplace = await NFTMarketplace.deploy(storageFee);

    return { nftMarketplace, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { nftMarketplace, owner } = await loadFixture(deployContract);

      expect(await nftMarketplace.owner()).to.equal(owner.address);
    });
  });
});
