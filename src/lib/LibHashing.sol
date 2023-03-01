// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "src/types/Types.sol";

/// @title LibHashing
/// @notice Utility functions for various hashing operations.
library LibHashing {
    /// @notice Computes the deposit transaction's "source hash", a value that guarantees the hash
    ///         of the L2 transaction that corresponds to a deposit is unique and is deterministically
    ///         generated from L1 transaction data.
    /// @param _l1BlockHash Hash of the L1 block where the deposit was included.
    /// @param _logIndex    The index of the log that created the deposit transaction.
    /// @return _depositSourceHash The deposit transaction's "source hash".
    function hashDepositSource(Hash _l1BlockHash, uint256 _logIndex) internal pure returns (Hash _depositSourceHash) {
        assembly ("memory-safe") {
            mstore(0x00, _l1BlockHash)
            mstore(0x20, _logIndex)
            _depositSourceHash := keccak256(0x00, 0x40)

            mstore(0x00, 0x00)
            mstore(0x20, _depositSourceHash)
            _depositSourceHash := keccak256(0x00, 0x40)
        }
    }
}
