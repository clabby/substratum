// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title TestUtils
/// @notice Various utility functions for testing.
library TestUtils {
    /// @notice Gets the free memory pointer
    /// @return _ptr The free memory pointer
    function getFreeMemoryPtr() internal pure returns (uint256 _ptr) {
        assembly {
            _ptr := mload(0x40)
        }
    }
}