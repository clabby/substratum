// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { TestUtils } from "test/testutils/TestUtils.sol";
import { TestArithmetic } from "test/testutils/TestArithmetic.sol";
import { LibHashing } from "src/lib/LibHashing.sol";
import "src/types/Types.sol";

/// @title LibHashing_Test
/// @notice Tests for the `LibHashing` library.
contract LibHashing_Test is Test {
    ////////////////////////////////////////////////////////////////
    //                        Environment                         //
    ////////////////////////////////////////////////////////////////

    /// @notice Inherits LibHashing's `hash` function for WithdrawalTransaction.
    using LibHashing for WithdrawalTransaction;

    ////////////////////////////////////////////////////////////////
    //                      LibHashing Tests                      //
    ////////////////////////////////////////////////////////////////

    /// @dev Tests that `LibHashing`'s `hashDepositSource` function correctly computes the source
    ///      hash of a deposit transaction.
    function testDiff_hashDepositSource_solidityDiff_succeeds(Hash _hash, uint256 _logIndex) public {
        assertEq(
            Hash.unwrap(LibHashing.hashDepositSource(_hash, _logIndex)),
            keccak256(abi.encode(uint256(0), keccak256(abi.encode(_hash, _logIndex))))
        );
    }

    /// @dev Tests that `LibHashing`'s `hash` function correctly computes the hash of a withdrawal
    ///      transaction.
    function testDiff_hashWithdrawalTransaction_solidityDiff_succeeds(WithdrawalTransaction memory _tx) public {
        assertEq(
            Hash.unwrap(_tx.hash()),
            keccak256(abi.encode(_tx.nonce, _tx.sender, _tx.target, _tx.value, _tx.gasLimit, _tx.data))
        );
    }

    /// @dev Tests that `LibHashing`'s `hash` function is memory-safe.
    function testFuzz_hashWithdrawalTransaction_memorySafety_succeeds(WithdrawalTransaction memory _tx) public {
        // Grab the free memory pointer before the operation.
        uint256 ptr = TestUtils.getFreeMemoryPtr();

        // Hash the withdrawal transaction.
        _tx.hash();

        // Grab the free memory pointer after the operation.
        uint256 newPtr = TestUtils.getFreeMemoryPtr();

        // Check that the free memory pointer has been properly updated to account for the newly allocated memory.
        // The new pointer should be equal to the old pointer plus the size of the abi-encoded withdrawal transaction
        // in memory.
        assertEq(newPtr, ptr + 0xE0 + TestArithmetic.roundUpTo32(_tx.data.length));
    }
}
