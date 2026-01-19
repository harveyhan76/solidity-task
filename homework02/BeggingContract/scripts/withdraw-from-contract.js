import { ethers } from "ethers";
import dotenv from "dotenv";

// 加载环境变量
dotenv.config();

async function main() {
    console.log("开始从合约提取ETH...");

    // 配置Sepolia测试网
    const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
    
    // 创建钱包实例
    const wallet = new ethers.Wallet(process.env.SEPOLIA_PRIVATE_KEY, provider);
    
    console.log("钱包地址:", wallet.address);
    
    // 合约地址（使用已部署的合约地址）
    const contractAddress = "0x079DAAdF31280Fc690e8CFe99c1A3212103bfadE";
    
    // 合约ABI（只包含必要的函数）
    const contractABI = [
        "function withdraw() external",
        "function getContractBalance() external view returns (uint256)",
        "function owner() external view returns (address)"
    ];
    
    // 创建合约实例
    const contract = new ethers.Contract(contractAddress, contractABI, wallet);
    
    try {
        // 检查合约所有者
        const contractOwner = await contract.owner();
        console.log("合约所有者:", contractOwner);
        
        if (contractOwner.toLowerCase() !== wallet.address.toLowerCase()) {
            console.error("错误: 当前钱包不是合约所有者，无法提取ETH");
            return;
        }
        
        // 检查合约余额
        const contractBalance = await contract.getContractBalance();
        console.log("合约余额:", ethers.formatEther(contractBalance), "ETH");
        
        if (contractBalance === 0n) {
            console.log("合约余额为0，无需提取");
            return;
        }
        
        // 检查钱包余额（用于支付gas费）
        const walletBalance = await provider.getBalance(wallet.address);
        console.log("钱包余额:", ethers.formatEther(walletBalance), "ETH");
        
        if (walletBalance < ethers.parseEther("0.001")) {
            console.log("钱包余额不足支付gas费，请先获取Sepolia测试网ETH");
            console.log("可以从以下水龙头获取:");
            console.log("- https://sepoliafaucet.com/");
            console.log("- https://faucet.quicknode.com/ethereum/sepolia");
            return;
        }
        
        console.log(`\n准备从合约提取 ${ethers.formatEther(contractBalance)} ETH`);
        console.log("提取到钱包:", wallet.address);
        
        // 执行提取操作
        console.log("\n执行提取交易...");
        const tx = await contract.withdraw();
        
        console.log("交易哈希:", tx.hash);
        console.log("等待交易确认...");
        
        // 等待交易确认
        const receipt = await tx.wait();
        console.log("交易确认!");
        console.log("区块高度:", receipt.blockNumber);
        console.log("Gas 使用量:", receipt.gasUsed.toString());
        
        // 获取提取后的余额
        const newContractBalance = await contract.getContractBalance();
        const newWalletBalance = await provider.getBalance(wallet.address);
        
        console.log("提取后合约余额:", ethers.formatEther(newContractBalance), "ETH");
        console.log("提取后钱包余额:", ethers.formatEther(newWalletBalance), "ETH");
        
        console.log("ETH提取成功!");
        
    } catch (error) {
        console.error("提取失败:", error);
        
        if (error.reason) {
            console.error("错误原因:", error.reason);
        }
    }
}

// 执行函数
main().catch((error) => {
    console.error("执行错误:", error);
    process.exit(1);
});