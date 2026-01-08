// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BinarySearch {
    /**
     * @dev 在有序数组中执行二分查找
     * @param arr 有序数组（升序）
     * @param target 要查找的目标值
     * @return 如果找到目标值返回其索引，否则返回 -1
     */
    function search(int256[] memory arr, int256 target) public pure returns (int256) {
        uint256 left = 0;
        uint256 right = arr.length;
        
        // 处理空数组情况
        if (right == 0) {
            return -1;
        }
        
        // 使用 while 循环进行二分查找
        while (left < right) {
            uint256 mid = left + (right - left) / 2;
            
            if (arr[mid] == target) {
                return int256(mid); // 找到目标值
            } else if (arr[mid] < target) {
                left = mid + 1; // 目标值在右侧
            } else {
                right = mid; // 目标值在左侧
            }
        }
        
        
        return -1; // 未找到
    }
}