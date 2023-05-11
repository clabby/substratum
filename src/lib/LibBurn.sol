// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Burn
/// @notice Utilities for burning stuff.
library LibBurn {
    /// @notice Burns a given amount of ETH.
    /// @param _amount Amount of ETH to burn.
    function eth(uint256 _amount) internal {
        assembly ("memory-safe") {
            // Store initcode - ADDRESS SELFDESTRUCT
            mstore(0x00, 0x30ff)
            // Deploy initcode - immediately self-destructing and sending all ETH to itself
            pop(create(_amount, 0x00, 0x02))
        }
    }

    /// @notice Burns a given amount of gas.
    /// @param _amount Amount of gas to burn.
    function gas(uint256 _amount) internal view {
        assembly ("memory-safe") {
            let i
            let initialGas := gas()
            for { } lt(sub(initialGas, gas()), _amount) { i := add(i, 0x01) } {}
        }
    }
}