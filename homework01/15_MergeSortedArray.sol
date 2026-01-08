// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MergeSortedArray {

    /**
     * @dev 创建并返回一个新的合并后的数组（不修改原始数组）
     * @param nums1 第一个数组
     * @param m 第一个数组的有效元素数量
     * @param nums2 第二个数组
     * @param n 第二个数组的有效元素数量
     * @return 合并后的新数组
     */
    function mergeAndReturn(
        uint256[] memory nums1,
        uint256 m,
        uint256[] memory nums2,
        uint256 n
    ) public pure returns (uint256[] memory) {
        require(nums1.length >= m, "m exceeds nums1 length");
        require(nums2.length >= n, "n exceeds nums2 length");
        
        uint256[] memory result = new uint256[](m + n);
        uint256 i = 0;  // nums1指针
        uint256 j = 0;  // nums2指针
        uint256 k = 0;  // result指针
        
        // 合并两个数组
        while (i < m && j < n) {
            if (nums1[i] <= nums2[j]) {
                result[k] = nums1[i];
                i++;
            } else {
                result[k] = nums2[j];
                j++;
            }
            k++;
        }
        
        // 复制nums1的剩余元素
        while (i < m) {
            result[k] = nums1[i];
            i++;
            k++;
        }
        
        // 复制nums2的剩余元素
        while (j < n) {
            result[k] = nums2[j];
            j++;
            k++;
        }
        
        return result;
    }
    
 
}