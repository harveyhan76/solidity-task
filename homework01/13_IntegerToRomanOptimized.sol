// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IntegerToRomanOptimized {
    // 使用固定数组提高效率
    uint256[] private values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    string[] private symbols = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"];
    
    /**
     * @dev 将整数转换为罗马数字
     * @param num 需要转换的整数（1-3999）
     * @return roman 罗马数字字符串
     */
    function toRoman(uint256 num) public view returns (string memory roman) {
        require(num >= 1 && num <= 3999, "Number must be between 1 and 3999");
        
        // 预估最大长度（3999 = "MMMCMXCIX" 共9个字符）
        bytes memory buffer = new bytes(15);
        uint256 bufferIndex = 0;
        
        for (uint256 i = 0; i < values.length; i++) {
            while (num >= values[i]) {
                // 获取符号的字节表示
                bytes memory symbolBytes = bytes(symbols[i]);
                
                // 将符号复制到缓冲区
                for (uint256 j = 0; j < symbolBytes.length; j++) {
                    buffer[bufferIndex++] = symbolBytes[j];
                }
                
                num -= values[i];
            }
        }
        
        // 创建正确大小的最终结果
        bytes memory result = new bytes(bufferIndex);
        for (uint256 i = 0; i < bufferIndex; i++) {
            result[i] = buffer[i];
        }
        
        return string(result);
    }
    
    /**
     * @dev 预计算并缓存常见数字的罗马数字
     */
    function getCommonRomans() public pure returns (string[10] memory) {
        return [
            "",        // 0 (无效)
            "I",       // 1
            "II",      // 2
            "III",     // 3
            "IV",      // 4
            "V",       // 5
            "VI",      // 6
            "VII",     // 7
            "VIII",    // 8
            "IX"       // 9
        ];
    }
}