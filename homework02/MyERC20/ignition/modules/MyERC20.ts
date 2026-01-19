import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("MyERC20Module", (m) => {
  // 代币参数配置
  const tokenName = "MyERC20 Token";
  const tokenSymbol = "MET";
  const tokenDecimals = 18;
  const initialSupply = 1000000; // 100万代币
  
  // 部署 MyERC20 合约
  const myERC20 = m.contract("MyERC20", [
    tokenName,
    tokenSymbol,
    tokenDecimals,
    initialSupply
  ]);

  return { myERC20 };
});
//npx hardhat verify --network sepolia 0x8123727d81D93087F8d777d807e95Bc833459Fc5 "MyERC20 Token" "MET" 18 100000