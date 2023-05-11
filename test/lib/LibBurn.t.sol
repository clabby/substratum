// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { LibBurn } from "src/lib/LibBurn.sol";

/// @title LibBurn_Test
/// @notice Tests for the `LibBurn` library.
contract LibBurn_Test is Test {
    ////////////////////////////////////////////////////////////////
    //                       `eth` Tests                          //
    ////////////////////////////////////////////////////////////////

    /// @dev Tests that `eth` correctly burns a given amount of ETH.
    function test_eth_correctness_succeeds() public {
        uint256 initialBalance = address(this).balance;
        uint256 amount = 1 ether;

        LibBurn.eth(amount);

        assertEq(initialBalance - amount, address(this).balance);
    }

    ////////////////////////////////////////////////////////////////
    //                       `gas` Tests                          //
    ////////////////////////////////////////////////////////////////

    /// @dev Tests that `gas` correctly burns a given amount of gas.
    function test_gas_correctness_succeeds() public {
        uint256 initialGas = gasleft();
        uint256 amount = 1000000;

        LibBurn.gas(amount);

        assertGt(initialGas - amount, gasleft());
    }
}
