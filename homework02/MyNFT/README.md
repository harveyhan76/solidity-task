# MyNFT - ERC721 NFT 智能合约项目

一个基于 Solidity 和 Hardhat 的完整 NFT 智能合约项目，实现了 ERC721 标准的 NFT 铸造、管理和查询功能。

## 📋 项目概述

MyNFT 是一个功能完整的 NFT 智能合约，支持：
- ✅ 单个 NFT 铸造
- ✅ 批量 NFT 铸造
- ✅ NFT 元数据管理
- ✅ 所有权验证
- ✅ 完整的测试覆盖

## 🚀 快速开始

### 环境要求

- Node.js (推荐 v22+)
- npm 或 yarn
- Git

### 安装依赖

```bash
npm install
```

### 编译合约

```bash
npx hardhat compile
```

### 运行测试

```bash
npx hardhat test
```

## 📁 项目结构

```
MyNFT/
├── contracts/ # Solidity 智能合约
│ ├── MyNFT.sol # 主合约文件
│ └── Counter.sol # 示例计数器合约
├── test/ # 测试文件
│ └── MyNFT.ts # 主合约测试
├── ignition/ # 部署配置
│ └── modules/
│ └── MyNFT.ts # 部署模块
├── artifacts/ # 编译输出
├── cache/ # 缓存文件
└── hardhat.config.ts # Hardhat 配置
```

## 🎯 合约功能

### 主要功能

1. **单个 NFT 铸造**
   - 任何人都可以铸造 NFT
   - 自动分配递增的 token ID
   - 设置 IPFS 元数据 URI

2. **批量 NFT 铸造**
   - 仅合约所有者可以执行
   - 一次最多铸造 10 个 NFT
   - 批量设置元数据 URI

3. **NFT 管理**
   - 更新 NFT 元数据（仅所有者）
   - 查询 NFT 信息
   - 检查 NFT 存在性

4. **查询功能**
   - 获取合约信息（名称、符号、总供应量）
   - 查询特定 NFT 信息
   - 获取用户拥有的 NFT 列表

### 合约地址（Sepolia测试网）

**合约地址：** `0x3c9eD512Ef686E98c580ac49a06A68EaFdba1610`

**Etherscan 链接：** [查看合约](https://sepolia.etherscan.io/address/0x3c9eD512Ef686E98c580ac49a06A68EaFdba1610)

## 🔧 部署指南

### 1. 配置环境变量

创建 `.env` 文件并配置：

```env
# Sepolia 测试网配置
SEPOLIA_RPC_URL=https://your-rpc-provider.com
SEPOLIA_PRIVATE_KEY=0xYourPrivateKey

# Etherscan API Key（用于合约验证）
ETHERSCAN_API_KEY=YourEtherscanAPIKey
```

### 2. 部署到 Sepolia 测试网

```bash
npx hardhat ignition deploy ignition/modules/MyNFT.ts --network sepolia
```

### 3. 验证合约

```bash
npx hardhat verify --network sepolia 0x3c9eD512Ef686E98c580ac49a06A68EaFdba1610
```

## 📖 使用示例

### 在 Etherscan 上交互

1. **查看合约信息**
   - 访问合约页面查看部署状态
   - 使用 "Read Contract" 功能查询信息

2. **铸造 NFT**
   - 使用 "Write Contract" 功能
   - 连接钱包后调用 `mint` 函数
   - 提供有效的 IPFS URI

### 通过代码交互

```javascript
// 连接到合约
const myNFT = await ethers.getContractAt("MyNFT", contractAddress);

// 铸造 NFT
const tx = await myNFT.mint("ipfs://QmExampleTokenURI");
await tx.wait();

// 查询信息
const totalSupply = await myNFT.totalSupply();
const tokenOwner = await myNFT.ownerOf(1);
```

## 🧪 测试

项目包含完整的测试套件：

```bash
# 运行所有测试
npx hardhat test

# 运行特定测试文件
npx hardhat test test/MyNFT.ts
```

### 测试覆盖的功能

- ✅ 单个 NFT 铸造
- ✅ 批量 NFT 铸造
- ✅ 事件触发验证
- ✅ 权限控制测试
- ✅ 错误处理测试
- ✅ 查询功能测试

## 🔒 安全特性

- 使用 OpenZeppelin 的安全合约库
- 实现了完整的权限控制
- 输入验证和错误处理
- 防止重入攻击

## 🌐 网络配置

项目支持以下网络：

- **localhost** - 本地开发网络
- **sepolia** - Ethereum Sepolia 测试网
- **hardhat** - Hardhat 内置网络

## 📝 开发指南

### 添加新功能

1. 在 `contracts/MyNFT.sol` 中添加函数
2. 在 `test/MyNFT.ts` 中添加测试用例
3. 更新部署脚本（如需要）
4. 运行测试确保功能正常

### 代码规范

- 使用 Solidity 0.8.28 版本
- 遵循 Solidity 样式指南
- 添加详细的注释
- 编写完整的测试用例

## 🐛 故障排除

### 常见问题

1. **部署失败**
   - 检查网络连接
   - 确认 RPC URL 和私钥配置正确
   - 确保账户有足够的测试币

2. **验证失败**
   - 确认合约代码与部署的完全一致
   - 检查编译器版本设置
   - 验证网络和合约地址正确

3. **测试失败**
   - 检查 Hardhat 版本兼容性
   - 确认所有依赖已正确安装
   - 查看具体的错误信息
