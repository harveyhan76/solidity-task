// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract BeggingContract {
    address public owner;
    mapping(address => uint256) public donations;
    uint256 public totalDonations;
    address[] private donors;
    
    event DonationReceived(address indexed donor, uint256 amount);
    event Withdrawal(address indexed owner, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function donate() external payable {
        require(msg.value > 0, "Donation amount must be greater than 0");
        
        // 如果是新捐赠者，添加到捐赠者列表
        if (donations[msg.sender] == 0) {
            donors.push(msg.sender);
        }
        
        donations[msg.sender] += msg.value;
        totalDonations += msg.value;
        
        emit DonationReceived(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        payable(owner).transfer(balance);
        
        emit Withdrawal(owner, balance);
    }
    
    function getDonation(address donor) external view returns (uint256) {
        return donations[donor];
    }
    
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    // 获取捐赠者总数
    function getDonorCount() external view returns (uint256) {
        return donors.length;
    }
}