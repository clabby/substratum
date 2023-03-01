// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { LibHashing } from "src/lib/LibHashing.sol";
import "src/types/Types.sol";

/// @title LibHashing_Test
/// @notice Tests for the `LibHashing` library.
contract LibHashing_Test is Test {
    ////////////////////////////////////////////////////////////////
    //                      LibHashing Tests                      //
    ////////////////////////////////////////////////////////////////

    /// @dev Tests that `LibHashing`'s `hashDepositSource` function correctly computes the source
    ///      hash of a deposit transaction.
    function testDiff_hashDepositSource_succeeds(Hash _hash, uint256 _logIndex) public {
        assertEq(
            Hash.unwrap(LibHashing.hashDepositSource(_hash, _logIndex)),
            keccak256(abi.encode(uint256(0), keccak256(abi.encode(_hash, _logIndex))))
        );
    }
}
