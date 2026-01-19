import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("BeggingContractModule", (m) => {
  const beggingContract = m.contract("BeggingContract");

  // 可以添加一些初始调用，比如捐赠一些测试以太币
  m.call(beggingContract, "donate", [], {
    value: 1000000000000000n // 0.001 ETH
  });

  return { beggingContract };
});