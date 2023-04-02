// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { TestUtils } from "test/testutils/TestUtils.sol";
import { LibBurn } from "src/lib/LibBurn.sol";
import "src/types/Types.sol";

/// @title LibBurn_Test
/// @notice Tests for the `LibBurn` library.
contract LibBurn_Test is Test {

    /// @dev Tests gas is correctly burned within 5 gas of the expected amount
    function testBurnGas() public {
        uint256 currentGas = gasleft();

        LibBurn.gas(5000000);

        uint256 newGas = gasleft();

        // Minor amount of inevitable overhead
        assertTrue(currentGas - newGas == 5000152); 
    }

    /// @dev Tests Ether is correctly removed from the circulating supply
    function testBurnEther() public {
        vm.deal(address(this), 10 ether);

        assertTrue(address(this).balance == 10 ether);

        LibBurn.eth(10 ether);

        uint256 newBalance = address(this).balance;

        // Ensure Ether is removed from the circulating supply
        assertTrue(newBalance == 0);
    }
}