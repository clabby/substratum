// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "src/types/Types.sol";

/// @title LibMemory
/// @notice This library contains utility functions for manipulating and interacting
///         with memory directly.
library LibMemory {
    /// @notice Copies the bytes from a memory location. (wen mcopy?)
    /// @param _src    Pointer to the location to read from.
    /// @param _offset Offset to start reading from.
    /// @param _length Number of bytes to read.
    /// @return _out Copied bytes.
    /// @dev This function can potentially cause memory safety issues if it is important that the final word of the copied
    ///      bytes is not partially dirty. This is because the final word is not cleaned after copying. For hashing operations,
    ///      this is not an issue because the only bytes that are included in the preimage are within the bounds of the length
    ///      of the dynamic type.
    function mcopy(MemoryPointer _src, uint256 _offset, uint256 _length) internal pure returns (bytes memory _out) {
        assembly ("memory-safe") {
            switch _length
            case 0x00 {
                // Assign `_out` to the zero offset
                _out := 0x60
            }
            default {
                // Assign `_out` to the free memory pointer.
                _out := mload(0x40)

                // Compute the starting offset of the source bytes
                let src := add(_src, _offset)
                // Compute the destination offset of the copied bytes
                let dest := add(_out, 0x20)

                // Copy the bytes
                let offset := 0x00
                for { } lt(offset, _length) { offset := add(offset, 0x20) } {
                    mstore(add(dest, offset), mload(add(src, offset)))
                }

                // Assign the length of the copied bytes
                mstore(_out, _length)
                // Update the free memory pointer
                mstore(0x40, and(add(_out, add(offset, 0x3F)), not(0x1F)))
            }
        }
    }

    /// @notice Copies the bytes from a memory location to another memory location directly.
    /// @param _src    Pointer to the location to read from.
    /// @param _dest   Pointer to the location to write to.
    /// @param _length Number of bytes to copy starting from the `_src` pointer.
    function mcopyDirect(MemoryPointer _src, MemoryPointer _dest, uint256 _length) internal view {
        assembly ("memory-safe") {
            // Copy the bytes using the identity precompile.
            pop(staticcall(gas(), 0x04, _src, _length, _dest, _length))
        }
    }
}
