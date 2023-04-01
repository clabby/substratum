// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { TestUtils } from "test/testutils/TestUtils.sol";
import { TestArithmetic } from "test/testutils/TestArithmetic.sol";
import { LibBurn } from "src/lib/LibBurn.sol";
import "src/types/Types.sol";

/// @title LibBurn_Test
/// @notice Tests for the `LibBurn` library.
contract LibBurn_Test is Test {

    /// @dev Tests gas is correctly burned within 5 gas of the expected amount
    function testFuzzBurnGas(uint256 gasAmount) public {
        uint256 currentGas = gasleft();

        LibBurn.gas(gasAmount);

        uint256 newGas = gasleft();

        // Ensure gas used within 5 gas of the expected amount.
        assertTrue(currentGas + newGas <= gasAmount + 5 && currentGas + newGas >= gasAmount - 5);
    }

    /// @dev Tests Ether is correctly removed from the circulating supply
    function testBurnEther() public {
        uint256 currentBalance = address(this).balance;

        LibBurn.eth(1);

        uint256 newBalance = address(this).balance;

        // Ensure Ether is removed from the circulating supply
        assertTrue(currentBalance - newBalance == 1);
    }
}