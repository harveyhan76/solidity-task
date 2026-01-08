// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RomanNumeralConverter {
    // 映射罗马字符到对应的数值
    mapping(bytes1 => uint256) private romanValues;
    
    constructor() {
        // 初始化罗马数字映射
        romanValues['I'] = 1;
        romanValues['V'] = 5;
        romanValues['X'] = 10;
        romanValues['L'] = 50;
        romanValues['C'] = 100;
        romanValues['D'] = 500;
        romanValues['M'] = 1000;
    }
    
    /**
     * @dev 将罗马数字转换为整数
     * @param roman 罗马数字字符串（只支持大写字母）
     * @return 对应的整数值
     */
    function romanToInt(string memory roman) public view returns (uint256) {
        bytes memory romanBytes = bytes(roman);
        uint256 length = romanBytes.length;
        
        // 处理空字符串
        require(length > 0, "Roman numeral cannot be empty");
        
        uint256 result = 0;
        
        for (uint256 i = 0; i < length; i++) {
            // 验证字符是否有效
            require(isValidRomanChar(romanBytes[i]), "Invalid Roman character");
            
            uint256 currentValue = romanValues[romanBytes[i]];
            
            // 如果当前字符不是最后一个，检查下一个字符
            if (i < length - 1) {
                uint256 nextValue = romanValues[romanBytes[i + 1]];
                
                // 如果当前值小于下一个值，表示减法规则（如 IV = 4）
                if (currentValue < nextValue) {
                    // 验证减法组合是否有效
                    require(isValidSubtraction(romanBytes[i], romanBytes[i + 1]), 
                        "Invalid subtraction combination");
                    
                    result += (nextValue - currentValue);
                    i++; // 跳过下一个字符，因为已经处理了
                } else {
                    result += currentValue;
                }
            } else {
                result += currentValue;
            }
        }
        
        return result;
    }
    
    /**
     * @dev 验证是否为有效的罗马数字字符
     * @param c 要验证的字符
     * @return 是否为有效字符
     */
    function isValidRomanChar(bytes1 c) public pure returns (bool) {
        return c == 'I' || c == 'V' || c == 'X' || c == 'L' || 
               c == 'C' || c == 'D' || c == 'M';
    }
    
    /**
     * @dev 验证减法组合是否有效
     * 有效的减法规则：
     * - I 只能在 V 或 X 之前
     * - X 只能在 L 或 C 之前
     * - C 只能在 D 或 M 之前
     */
    function isValidSubtraction(bytes1 left, bytes1 right) public pure returns (bool) {
        if (left == 'I' && (right == 'V' || right == 'X')) {
            return true;
        }
        if (left == 'X' && (right == 'L' || right == 'C')) {
            return true;
        }
        if (left == 'C' && (right == 'D' || right == 'M')) {
            return true;
        }
        return false;
    }
    
    /**
     * @dev 验证罗马数字字符串是否有效（包括重复次数限制）
     * @param roman 罗马数字字符串
     * @return 是否有效
     */
    function isValidRomanNumeral(string memory roman) public view returns (bool) {
        bytes memory romanBytes = bytes(roman);
        uint256 length = romanBytes.length;
        
        if (length == 0) {
            return false;
        }
        
        // 检查所有字符是否有效
        for (uint256 i = 0; i < length; i++) {
            if (!isValidRomanChar(romanBytes[i])) {
                return false;
            }
        }
        
        // 检查重复规则
        uint256 repeatCount = 1;
        bytes1 lastChar = romanBytes[0];
        
        for (uint256 i = 1; i < length; i++) {
            if (romanBytes[i] == lastChar) {
                repeatCount++;
                
                // 检查重复次数限制
                if (romanBytes[i] == 'V' || romanBytes[i] == 'L' || romanBytes[i] == 'D') {
                    // V, L, D 不能重复
                    if (repeatCount > 1) {
                        return false;
                    }
                } else if (romanBytes[i] == 'I' || romanBytes[i] == 'X' || 
                          romanBytes[i] == 'C' || romanBytes[i] == 'M') {
                    // I, X, C, M 最多重复3次
                    if (repeatCount > 3) {
                        return false;
                    }
                }
            } else {
                repeatCount = 1;
                lastChar = romanBytes[i];
            }
            
            // 检查无效的减法组合
            if (i < length - 1) {
                uint256 currentValue = romanValues[romanBytes[i]];
                uint256 nextValue = romanValues[romanBytes[i + 1]];
                
                if (currentValue < nextValue) {
                    if (!isValidSubtraction(romanBytes[i], romanBytes[i + 1])) {
                        return false;
                    }
                }
            }
        }
        
        return true;
    }
    
    /**
     * @dev 批量转换罗马数字
     * @param romans 罗马数字字符串数组
     * @return 对应的整数值数组
     */
    function batchConvert(string[] memory romans) public view returns (uint256[] memory) {
        uint256[] memory results = new uint256[](romans.length);
        
        for (uint256 i = 0; i < romans.length; i++) {
            results[i] = romanToInt(romans[i]);
        }
        
        return results;
    }
    
    /**
     * @dev 获取支持的罗马字符
     */
    function getSupportedCharacters() public pure returns (string memory) {
        return "I, V, X, L, C, D, M";
    }
    
    /**
     * @dev 获取字符对应的数值
     * @param romanChar 罗马字符
     * @return 对应的数值
     */
    function getCharValue(bytes1 romanChar) public view returns (uint256) {
        require(isValidRomanChar(romanChar), "Invalid Roman character");
        return romanValues[romanChar];
    }
}

