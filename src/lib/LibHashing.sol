// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "src/types/Types.sol";

/// @title LibHashing
/// @notice Utility functions for various hashing operations.
library LibHashing {
    /// @notice Computes the deposit transaction's "source hash", a value that guarantees the hash of the L2
    ///         transaction that corresponds to a deposit is unique and is deterministically generated from L1
    ///         transaction data.
    /// @param _l1BlockHash Hash of the L1 block where the deposit was included.
    /// @param _logIndex    The index of the log that created the deposit transaction.
    /// @return _depositSourceHash The deposit transaction's "source hash".
    function hashDepositSource(Hash _l1BlockHash, uint256 _logIndex) internal pure returns (Hash _depositSourceHash) {
        assembly ("memory-safe") {
            // Store the L1 block hash and log index in scratch space and hash the memory to produce the deposit id.
            mstore(0x00, _l1BlockHash)
            mstore(0x20, _logIndex)
            _depositSourceHash := keccak256(0x00, 0x40)

            // Store the zero value and the deposit id in scratch space and hash the memory to produce the source hash.
            mstore(0x00, 0x00)
            mstore(0x20, _depositSourceHash)
            _depositSourceHash := keccak256(0x00, 0x40)
        }
    }

    /// @notice Hashes a withdrawal transaction type.
    /// @param _tx The WithdrawalTransaction to hash.
    /// @return _hash The hash of the WithdrawalTransaction.
    function hash(WithdrawalTransaction memory _tx) internal pure returns (Hash _hash) {
        assembly ("memory-safe") {
            // Grab some free memory
            let ptr := mload(0x40)

            // Store the abi-encoded withdrawal transaction in memory.
            // TODO: Using the identity precompile for long copies may be more efficient here.

            // Copy nonce
            mstore(ptr, mload(_tx))

            // Copy sender
            mstore(add(ptr, 0x20), mload(add(_tx, 0x20)))

            // Copy target
            mstore(add(ptr, 0x40), mload(add(_tx, 0x40)))

            // Copy value
            mstore(add(ptr, 0x60), mload(add(_tx, 0x60)))

            // Copy gasLimit
            mstore(add(ptr, 0x80), mload(add(_tx, 0x80)))

            // Write pointer to data
            mstore(add(ptr, 0xA0), 0xC0)

            // Copy data length
            let dataLen := mload(add(_tx, 0xC0))
            mstore(add(ptr, 0xC0), dataLen)

            // Copy data (wen mcopy)
            let dataLenRounded := and(not(0x1F), add(dataLen, 0xFF))
            let dataEnd := add(_tx, dataLenRounded)
            for { let offset := 0xE0 } lt(offset, dataLenRounded) { offset := add(offset, 0x20) } {
                mstore(add(ptr, offset), mload(add(_tx, offset)))
            }

            // Compute the hash
            _hash := keccak256(ptr, dataLenRounded)

            // Update the free memory pointer to reflect the newly allocated memory
            mstore(0x40, add(ptr, dataLenRounded))
        }
    }
}
