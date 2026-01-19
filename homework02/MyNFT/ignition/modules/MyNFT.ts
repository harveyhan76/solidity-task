import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("MyNFTModule", (m) => {
  // 部署MyNFT合约
  const myNFT = m.contract("MyNFT");

  // 部署后立即铸造一些示例NFT（为每个调用提供唯一ID）
  m.call(myNFT, "mint", ["ipfs://bafkreiglv6cwkualxym4yseqva277236fusxbtkdcxlrsut6iu4q7qdjxu"], {
    id: "mintToken1"
  });
  
  m.call(myNFT, "mint", ["ipfs://QmExampleToken2"], {
    id: "mintToken2"
  });
  
  // 批量铸造一些NFT（需要所有者权限）
  const uris = [
    "ipfs://QmBatchToken1",
    "ipfs://QmBatchToken2", 
    "ipfs://QmBatchToken3"
  ];
  m.call(myNFT, "batchMint", [m.getAccount(0), uris], {
    id: "batchMintTokens"
  });

  return { myNFT };
});