// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title LibBurn
/// @notice Utilities for burning Gas and Ether
library LibBurn {
    /// Burns a given amount of ETH.
    /// @param _amount Amount of ETH to burn.
    function eth(uint256 _amount) internal {
        new Burner{ value: _amount }();
    }

    /// Burns a given amount of gas.
    /// @param _amount Amount of gas to burn.
    function gas(uint256 _amount) internal view {
        uint256 initialGas = gasleft();
        uint256 i = 0;
        while (initialGas - gasleft() < _amount) {
            assembly ("memory-safe") {
                i := add(i, 1) // Uses gas perfectly in a multiple of 5
            }
        }
    }
}

/// @title Burner
/// @notice Burner sends all ETH to itself, and contains no-code, effectively removing ETH from the supply
///      previously implementations have used SELFDESTRUCT, but this is no longer reccomended due to its impending deprecation
contract Burner {
    constructor() payable {
        assembly {
            pop(call(gas(), address(), callvalue(), 0x0, 0x0, 0x0, 0x0))
        }
    }
}
