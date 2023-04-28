// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { TestUtils } from "test/testutils/TestUtils.sol";
import { TestArithmetic } from "test/testutils/TestArithmetic.sol";
import { LibBurn } from "src/lib/LibBurn.sol";
import { LibArithmetic } from "src/lib/LibArithmetic.sol";
import "src/types/Types.sol";

/// @title LibBurn_Test
/// @notice Tests for the `LibBurn` library.
contract LibBurn_Test is Test {
    /// @dev Tests gas is correctly burned within 5 gas of the expected amount
    function testFuzzBurnGas(uint16 gas_to_burn) public {
        vm.assume(gas_to_burn > 500); // Otherwise overhead will break accuracy
        uint256 startGas = gasleft();

        LibBurn.gas(gas_to_burn);

        uint256 newGas = gasleft();

        // Minor amount of inevitable overhead
        assertTrue(startGas - newGas < uint256(gas_to_burn) + 500 && startGas - newGas > uint256(gas_to_burn) - 500);
    }

    /// @dev Tests Ether is correctly removed from the circulating supply
    function testBurnEther(uint256 amount) public {
        vm.deal(address(this), amount);

        assertTrue(address(this).balance == amount);

        LibBurn.eth(amount);

        uint256 newBalance = address(this).balance;

        // Ensure Ether is removed from the circulating supply
        assertTrue(newBalance == 0);
    }

    /// @dev Tests Ether is correctly removed from the circulating supply
    function testBurnEtherContract(uint256 amount) public {
        vm.deal(address(this), amount);

        assertTrue(address(this).balance == amount);

        address payable burnContract = payable(LibBurn.test_eth(amount));

        uint256 newBalance = address(this).balance;

        // Ensure Ether is removed from the circulating supply
        assertTrue(newBalance == 0);

        // Ensure contract contains eth
        assertTrue(burnContract.balance == amount);

        vm.expectRevert();
        // Will fail because contract begins with an INVALID Opcode
        burnContract.transfer(0);
    }
}
