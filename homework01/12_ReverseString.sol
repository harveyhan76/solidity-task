// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReverseString {
   /**
     * @dev 原地反转字符串（更省 gas）
     * @param str 输入的字符串
     * @return 反转后的字符串
     */
    function reverseString(string memory str) public pure returns (string memory) {
         // 处理空字符串
        if (bytes(str).length == 0) {
            return "";
        }

        bytes memory strBytes = bytes(str);
        uint256 len = strBytes.length;
        
        // 原地交换字符，无需额外内存分配
        for (uint256 i = 0; i < len / 2; i++) {
            // 交换对称位置的字符
            bytes1 temp = strBytes[i];
            strBytes[i] = strBytes[len - 1 - i];
            strBytes[len - 1 - i] = temp;
        }
        
        return string(strBytes);
    }
    
    /**
     * @dev 测试函数：验证反转逻辑
     * @param str 测试字符串
     * @return 反转后的字符串
     */
    function testReverse(string memory str) public pure returns (string memory) {
        return reverseString(str);
    }
}