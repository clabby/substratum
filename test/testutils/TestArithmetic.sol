// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title TestArithmetic
/// @notice Various arithmetic functions used frequently in tests.
library TestArithmetic {
    /// @notice Rounds a number up to the next multiple of 32.
    function roundUpTo32(uint256 _n) internal pure returns (uint256) {
        return (_n + 31) & ~uint256(31);
    }

    /// @notice Performs a saturating subtraction on two unsigned integers.
    /// @param _left The number to subtract `_right` from.
    /// @param _right The number to subtract from `_left`.
    /// @return The result of the subtraction or 0 if the result would underflow.
    function saturatingSub(uint256 _left, uint256 _right) internal pure returns (uint256) {
        return _left < _right ? 0 : _left - _right;
    }
}
