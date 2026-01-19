import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("BeggingContract", function () {
  let beggingContract: any;
  let owner: any;
  let donor1: any;
  let donor2: any;
  let donor3: any;

  beforeEach(async function () {
    [owner, donor1, donor2, donor3] = await ethers.getSigners();
    beggingContract = await ethers.deployContract("BeggingContract");
  });

  it("Should set the correct owner on deployment", async function () {
    expect(await beggingContract.owner()).to.equal(owner.address);
  });

  it("Should emit DonationReceived event when donating", async function () {
    const donationAmount = ethers.parseEther("1");
    
    await expect(beggingContract.connect(donor1).donate({ value: donationAmount }))
      .to.emit(beggingContract, "DonationReceived")
      .withArgs(donor1.address, donationAmount);
  });

  it("Should update donation records correctly", async function () {
    const donationAmount1 = ethers.parseEther("0.5");
    const donationAmount2 = ethers.parseEther("1");

    // 第一次捐赠
    await beggingContract.connect(donor1).donate({ value: donationAmount1 });

    expect(await beggingContract.donations(donor1.address)).to.equal(donationAmount1);
    expect(await beggingContract.totalDonations()).to.equal(donationAmount1);

    // 第二次捐赠
    await beggingContract.connect(donor1).donate({ value: donationAmount2 });

    expect(await beggingContract.donations(donor1.address)).to.equal(donationAmount1 + donationAmount2);
    expect(await beggingContract.totalDonations()).to.equal(donationAmount1 + donationAmount2);
  });

  it("Should reject zero value donations", async function () {
    await expect(beggingContract.connect(donor1).donate({ value: 0 }))
      .to.be.revertedWith("Donation amount must be greater than 0");
  });

  it("Should allow owner to withdraw funds", async function () {
     const donationAmount = ethers.parseEther("2");
    
    // 捐赠资金
    await beggingContract.connect(donor1).donate({ value: donationAmount });

    const initialOwnerBalance = await ethers.provider.getBalance(owner.address);
    
    // 提现
    const tx = await beggingContract.withdraw();
    const receipt = await tx.wait();
    
    // 确保使用BigInt类型进行计算
    const gasUsed = BigInt(receipt.gasUsed) * BigInt(receipt.gasPrice);

    const finalOwnerBalance = await ethers.provider.getBalance(owner.address);
    
    // 验证提现金额是否正确（考虑gas费用）
    expect(finalOwnerBalance + gasUsed).to.be.closeTo(
      initialOwnerBalance + donationAmount,
      ethers.parseEther("0.01")
    );
  });

  it("Should emit Withdrawal event when owner withdraws", async function () {
    const donationAmount = ethers.parseEther("1");
    
    await beggingContract.connect(donor1).donate({ value: donationAmount });

    await expect(beggingContract.withdraw())
      .to.emit(beggingContract, "Withdrawal")
      .withArgs(owner.address, donationAmount);
  });

  it("Should prevent non-owner from withdrawing", async function () {
    const donationAmount = ethers.parseEther("1");
    
    await beggingContract.connect(donor1).donate({ value: donationAmount });

    await expect(beggingContract.connect(donor1).withdraw())
      .to.be.revertedWith("Only owner can call this function");
  });

  it("Should correctly track donor count", async function () {
    expect(await beggingContract.getDonorCount()).to.equal(0);

    // 第一个捐赠者
    await beggingContract.connect(donor1).donate({ value: ethers.parseEther("1") });
    expect(await beggingContract.getDonorCount()).to.equal(1);

    // 第二个捐赠者
    await beggingContract.connect(donor2).donate({ value: ethers.parseEther("2") });
    expect(await beggingContract.getDonorCount()).to.equal(2);

    // 第一个捐赠者再次捐赠（不应增加捐赠者数量）
    await beggingContract.connect(donor1).donate({ value: ethers.parseEther("0.5") });
    expect(await beggingContract.getDonorCount()).to.equal(2);
  });

  it("Should return correct contract balance", async function () {
    const donationAmount = ethers.parseEther("1.5");
    
    await beggingContract.connect(donor1).donate({ value: donationAmount });

    expect(await beggingContract.getContractBalance()).to.equal(donationAmount);
  });

  it("Should return correct donation amount for specific donor", async function () {
    const donationAmount = ethers.parseEther("2.5");
    
    await beggingContract.connect(donor1).donate({ value: donationAmount });

    expect(await beggingContract.getDonation(donor1.address)).to.equal(donationAmount);
    expect(await beggingContract.getDonation(donor2.address)).to.equal(0);
  });
});