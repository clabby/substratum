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
    // TODO: The identity precompile may be more efficient here for large lengths.
    function mcopy(MemoryPointer _src, uint256 _offset, uint256 _length) internal pure returns (bytes memory _out) {
        assembly {
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
}
