import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("MyNFT", function () {
  let myNFT: any;
  let owner: any;
  let user1: any;
  let user2: any;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    myNFT = await ethers.deployContract("MyNFT");
  });

  it("Should emit NFTMinted event when minting a new NFT", async function () {
    const tokenURI = "ipfs://QmTestTokenURI";
    
    await expect(myNFT.connect(user1).mint(tokenURI))
      .to.emit(myNFT, "NFTMinted")
      .withArgs(user1.address, 1n, tokenURI);
  });

  it("Should correctly mint NFT and assign ownership", async function () {
    const tokenURI = "ipfs://QmTestTokenURI";
    
    await myNFT.connect(user1).mint(tokenURI);
    
    expect(await myNFT.ownerOf(1)).to.equal(user1.address);
    expect(await myNFT.tokenURI(1)).to.equal(tokenURI);
    expect(await myNFT.totalSupply()).to.equal(1);
  });

  it("Should allow owner to batch mint NFTs", async function () {
    const uris = [
      "ipfs://QmToken1",
      "ipfs://QmToken2", 
      "ipfs://QmToken3"
    ];
    
    // 等待交易完成并获取返回值
    const tx = await myNFT.batchMint(user1.address, uris);
    const receipt = await tx.wait();
    
    // 检查总供应量是否正确
    expect(await myNFT.totalSupply()).to.equal(3);
    
    // 检查每个token的所有权和URI
    for (let i = 1; i <= 3; i++) {
      expect(await myNFT.ownerOf(i)).to.equal(user1.address);
      expect(await myNFT.tokenURI(i)).to.equal(uris[i-1]);
    }
    
    // 检查事件是否正确触发
    const events = await myNFT.queryFilter(
      myNFT.filters.NFTMinted(),
      receipt.blockNumber,
      receipt.blockNumber
    );
    
    expect(events.length).to.equal(3);
    
    // 验证每个事件的参数
    for (let i = 0; i < events.length; i++) {
      const event = events[i];
      expect(event.args.to).to.equal(user1.address);
      expect(event.args.tokenId).to.equal(BigInt(i + 1));
      expect(event.args.tokenURI).to.equal(uris[i]);
    }
  });

  it("Should emit TokenURIUpdated event when updating token URI", async function () {
    const originalURI = "ipfs://QmOriginal";
    const newURI = "ipfs://QmUpdated";
    
    await myNFT.connect(user1).mint(originalURI);
    
    await expect(myNFT.updateTokenURI(1, newURI))
      .to.emit(myNFT, "TokenURIUpdated")
      .withArgs(1n, newURI);
    
    expect(await myNFT.tokenURI(1)).to.equal(newURI);
  });

  it("Should correctly track total supply across multiple mints", async function () {
    const deploymentBlockNumber = await ethers.provider.getBlockNumber();
    
    // Mint multiple NFTs
    await myNFT.connect(user1).mint("ipfs://Qm1");
    await myNFT.connect(user2).mint("ipfs://Qm2");
    await myNFT.connect(user1).mint("ipfs://Qm3");
    
    // Check events
    const events = await myNFT.queryFilter(
      myNFT.filters.NFTMinted(),
      deploymentBlockNumber,
      "latest"
    );
    
    expect(events.length).to.equal(3);
    expect(await myNFT.totalSupply()).to.equal(3);
    
    // Verify token ownership
    expect(await myNFT.ownerOf(1)).to.equal(user1.address);
    expect(await myNFT.ownerOf(2)).to.equal(user2.address);
    expect(await myNFT.ownerOf(3)).to.equal(user1.address);
  });

  it("Should return correct contract information", async function () {
    const [name, symbol, totalSupply] = await myNFT.getContractInfo();
    
    expect(name).to.equal("MyNFT");
    expect(symbol).to.equal("MNFT");
    expect(totalSupply).to.equal(0n);
  });

  it("Should return correct token information", async function () {
    const tokenURI = "ipfs://QmTestToken";
    await myNFT.connect(user1).mint(tokenURI);
    
    const [owner, uri] = await myNFT.getTokenInfo(1);
    
    expect(owner).to.equal(user1.address);
    expect(uri).to.equal(tokenURI);
  });

  it("Should correctly check token existence", async function () {
    expect(await myNFT.tokenExists(1)).to.be.false;
    
    await myNFT.connect(user1).mint("ipfs://QmTest");
    
    expect(await myNFT.tokenExists(1)).to.be.true;
    expect(await myNFT.tokenExists(999)).to.be.false;
  });

  it("Should return correct next token ID", async function () {
    expect(await myNFT.getNextTokenId()).to.equal(1n);
    
    await myNFT.connect(user1).mint("ipfs://Qm1");
    
    expect(await myNFT.getNextTokenId()).to.equal(2n);
  });

  it("Should return tokens by owner", async function () {
    await myNFT.connect(user1).mint("ipfs://Qm1");
    await myNFT.connect(user2).mint("ipfs://Qm2");
    await myNFT.connect(user1).mint("ipfs://Qm3");
    
    const user1Tokens = await myNFT.getTokensByOwner(user1.address);
    const user2Tokens = await myNFT.getTokensByOwner(user2.address);
    
    expect(user1Tokens.length).to.equal(2);
    expect(user2Tokens.length).to.equal(1);
    expect(user1Tokens[0]).to.equal(1n);
    expect(user1Tokens[1]).to.equal(3n);
    expect(user2Tokens[0]).to.equal(2n);
  });

  it("Should prevent non-owner from updating token URI", async function () {
    await myNFT.connect(user1).mint("ipfs://QmOriginal");
    
    await expect(
      myNFT.connect(user2).updateTokenURI(1, "ipfs://QmUpdated")
    ).to.be.revertedWithCustomError(myNFT, "OwnableUnauthorizedAccount");
  });

  it("Should prevent batch minting with too many URIs", async function () {
    const uris = Array(11).fill("ipfs://QmTest");
    
    await expect(
      myNFT.batchMint(user1.address, uris)
    ).to.be.revertedWith("Too many URIs (max 10)");
  });

  it("Should prevent batch minting with empty URIs", async function () {
    await expect(
      myNFT.batchMint(user1.address, [])
    ).to.be.revertedWith("No URIs provided");
  });
});