import { ethers } from "ethers";
import dotenv from "dotenv";

// 加载环境变量
dotenv.config();

async function main() {
    console.log("开始向合约捐赠ETH...");

    // 配置Sepolia测试网
    const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
    
    // 创建钱包实例
    const wallet = new ethers.Wallet(process.env.SEPOLIA_PRIVATE_KEY, provider);
    
    console.log("钱包地址:", wallet.address);
    
    // 合约地址
    const contractAddress = "0x079DAAdF31280Fc690e8CFe99c1A3212103bfadE";
    
    // 合约ABI（只包含donate函数）
    const contractABI = [
        "function donate() external payable",
        "function getContractBalance() external view returns (uint256)"
    ];
    
    // 创建合约实例
    const contract = new ethers.Contract(contractAddress, contractABI, wallet);
    
    try {
        // 检查钱包余额
        const walletBalance = await provider.getBalance(wallet.address);
        console.log("钱包余额:", ethers.formatEther(walletBalance), "ETH");
        
        if (walletBalance < ethers.parseEther("0.002")) {
            console.log("钱包余额不足，请先获取Sepolia测试网ETH");
            console.log("可以从以下水龙头获取:");
            console.log("- https://sepoliafaucet.com/");
            console.log("- https://faucet.quicknode.com/ethereum/sepolia");
            return;
        }
        
        // 捐赠金额
        const donationAmount = ethers.parseEther("0.001");
        console.log(`\n准备捐赠 ${ethers.formatEther(donationAmount)} ETH 到合约`);
        
        // 检查当前合约余额
        const currentContractBalance = await contract.getContractBalance();
        console.log("当前合约余额:", ethers.formatEther(currentContractBalance), "ETH");
        
        // 执行捐赠操作
        console.log("\n执行捐赠交易...");
        const tx = await contract.donate({
            value: donationAmount
        });
        
        console.log("交易哈希:", tx.hash);
        console.log("等待交易确认...");
        
        // 等待交易确认
        const receipt = await tx.wait();
        console.log("交易确认!");
        console.log("区块高度:", receipt.blockNumber);
        console.log("Gas 使用量:", receipt.gasUsed.toString());
        
        // 获取捐赠后的余额
        const newContractBalance = await contract.getContractBalance();
        const newWalletBalance = await provider.getBalance(wallet.address);
        
        console.log("捐赠后合约余额:", ethers.formatEther(newContractBalance), "ETH");
        console.log("捐赠后钱包余额:", ethers.formatEther(newWalletBalance), "ETH");
        
        console.log("捐赠成功!");
        
    } catch (error) {
        console.error("捐赠失败:", error);
        
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