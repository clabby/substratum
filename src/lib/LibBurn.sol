// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title LibBurn
/// @notice Utilities for burning Gas and Ether
library LibBurn {
    /// Burns a given amount of ETH.
    /// @param _amount Amount of ETH to burn.
    function eth(uint256 _amount) internal {
        assembly ("memory-safe") {
            // Store creation code of no-op contract
            // PUSH1 0xFE (Invalid opcode)
            // PUSH1 0x00  \
            // MSTORE       > Replace with PUSH0 / CHAINID for mainnet.
            // PUSH1 0x01  /
            // PUSH1 0x1F
            // RETURN
            mstore(0x00, 0x60fe6000526001601ff3)
            let success := create(_amount, 0x16, 0x0a)

            if iszero(success) {
                // "BurnFailed()" error
                mstore(0x00, 0x6f16aafc)
                revert(0x1c, 0x04)
            }
        }
    }

    /// @notice Tests the eth function, but returns address as a helper for testing.
    /// @notice Implementation should not different from eth function.
    /// @param _amount Amount of ETH to burn.
    function test_eth(uint256 _amount) internal returns (address contract_addr) {
    assembly ("memory-safe") {
        // Store creation code of no-op contract
        // PUSH1 0xFE (Invalid opcode)
        // PUSH1 0x00  \
        // MSTORE       > Replace with PUSH0 / CHAINID for mainnet.
        // PUSH1 0x01  /
        // PUSH1 0x1F
        // RETURN
        mstore(0x00, 0x60fe6000526001601ff3)
        contract_addr := create(_amount, 0x16, 0x0a)

        if iszero(contract_addr) {
            // "BurnFailed()" error
            mstore(0x00, 0x6f16aafc)
            revert(0x1c, 0x04)
        }
    }
}

    /// Burns a given amount of gas.
    /// @param _amount Amount of gas to burn.
    function gas(uint256 _amount) internal view {
        uint256 i = 0;
        uint256 initialGas = gasleft();
        while (initialGas - gasleft() < _amount) {
            ++i;
        }
    }
}
