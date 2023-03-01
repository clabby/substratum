// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title TestArithmetic
/// @notice Various arithmetic functions used frequently in tests.
library TestArithmetic {
    /// @notice Rounds a number up to the next multiple of 32.
    function roundUpTo32(uint256 _n) internal pure returns (uint256) {
        return ((_n + 0x1F) >> 5) << 5;
    }
}
