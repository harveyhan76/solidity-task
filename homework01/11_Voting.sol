// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    // 存储候选人的得票数
    mapping(string => uint256) private votes;
    
    // 记录所有候选人的列表
    string[] private candidateList;
    
    // 投票事件
    event Voted(address indexed voter, string candidate, uint256 newVoteCount);
    
    // 重置投票事件
    event VotesReset();
    
    // 构造函数，可以初始化候选人
    constructor(string[] memory candidates) {
        for (uint i = 0; i < candidates.length; i++) {
            candidateList.push(candidates[i]);
        }
    }
    
    // 投票函数
    function vote(string memory candidate) public {
        // 确保候选人存在（如果有候选人列表的话）
        require(isValidCandidate(candidate), "Candidate does not exist");
        
        // 增加候选人的票数
        votes[candidate] += 1;
        
        // 触发投票事件
        emit Voted(msg.sender, candidate, votes[candidate]);
    }
    
    // 获取候选人得票数
    function getVotes(string memory candidate) public view returns (uint256) {
        return votes[candidate];
    }
    
    // 重置所有候选人的得票数
    function resetVotes() public {
        for (uint i = 0; i < candidateList.length; i++) {
            votes[candidateList[i]] = 0;
        }
        
        // 触发重置事件
        emit VotesReset();
    }
    
    // 添加新候选人（可选功能）
    function addCandidate(string memory candidate) public {
        require(!isValidCandidate(candidate), "Candidate already exists");
        candidateList.push(candidate);
        votes[candidate] = 0; // 初始票数为0
    }
    
    // 检查候选人是否有效
    function isValidCandidate(string memory candidate) private view returns (bool) {
        for (uint i = 0; i < candidateList.length; i++) {
            if (keccak256(bytes(candidateList[i])) == keccak256(bytes(candidate))) {
                return true;
            }
        }
        return false;
    }
    
    // 获取所有候选人列表
    function getAllCandidates() public view returns (string[] memory) {
        return candidateList;
    }
    
    // 获取所有候选人的票数
    function getAllVotes() public view returns (string[] memory, uint256[] memory) {
        string[] memory candidates = new string[](candidateList.length);
        uint256[] memory voteCounts = new uint256[](candidateList.length);
        
        for (uint i = 0; i < candidateList.length; i++) {
            candidates[i] = candidateList[i];
            voteCounts[i] = votes[candidateList[i]];
        }
        
        return (candidates, voteCounts);
    }
}

// 简化版合约（如果你只需要最基本的功能）
contract SimpleVoting {
    mapping(string => uint256) public candidateVotes;
    
    // 投票函数
    function vote(string memory candidate) public {
        candidateVotes[candidate] += 1;
    }
    
    // 获取候选人得票数
    function getVotes(string memory candidate) public view returns (uint256) {
        return candidateVotes[candidate];
    }
    
    // 重置所有候选人的得票数
    function resetVotes(string[] memory candidates) public {
        for (uint i = 0; i < candidates.length; i++) {
            candidateVotes[candidates[i]] = 0;
        }
    }
}