// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Burn
/// @notice Utilities for burning stuff.
library LibBurn {
    /// @notice Burns a given amount of ETH.
    /// @param _amount Amount of ETH to burn.
    function eth(uint256 _amount) internal {
        new Burner{value: _amount}();
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

/// @title Burner
/// @notice Burner self-destructs on creation and sends all ETH to itself, removing all ETH given to
///         the contract from the circulating supply. Self-destructing is the only way to remove ETH
///         from the circulating supply.
contract Burner {
    constructor() payable {
        selfdestruct(payable(address(this)));
    }
}