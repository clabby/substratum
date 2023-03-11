// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title LibBytes
/// @notice A library for manipulating dynamic bytes types in memory
library LibBytes {
    /// @custom:attribution https://github.com/GNSPS/solidity-bytes-utils
    /// @notice Slices a byte array with a given starting index and length. Returns a new byte array
    ///         as opposed to a pointer to the original array. Will throw if trying to slice more
    ///         bytes than exist in the array.
    /// @param _bytes Byte array to slice.
    /// @param _start Starting index of the slice.
    /// @param _length Length of the slice.
    /// @return _slice Slice of the input byte array.
    function slice(bytes memory _bytes, uint256 _start, uint256 _length) internal view returns (bytes memory _slice) {
        assembly {
            // Assertions:
            // - _length + 31 >= _length
            // - _start + _length >= _start
            if or(lt(add(_length, 0x1F), _length), lt(add(_start, _length), _start)) {
                // Store the error signature for "SliceOverflow()"
                mstore(0x00, 0x47aaf07a)
                // Revert
                revert(0x1c, 0x04)
            }
            // Assertion: _bytes.length >= _start + _length
            if lt(mload(_bytes), add(_start, _length)) {
                // Store the error signature for "SliceOutOfBounds()"
                mstore(0x00, 0x3b99b53d)
                // Revert
                revert(0x1c, 0x04)
            }

            switch _length
            case 0 { _slice := 0x60 }
            default {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                _slice := mload(0x40)

                // Store the length of the slice
                mstore(_slice, _length)

                // Slice the `_bytes` array using the identity precompile
                pop(staticcall(gas(), 0x04, add(add(_bytes, 0x20), _start), _length, add(_slice, 0x20), _length))

                // Update the free memory pointer
                mstore(0x40, add(_slice, and(add(_length, 0x3F), not(0x1F))))
            }
        }
    }

    /// @notice Slices a byte array with a given starting index up to the end of the original byte
    ///         array. Returns a new array rathern than a pointer to the original.
    /// @param _bytes Byte array to slice.
    /// @param _start Starting index of the slice.
    /// @return Slice of the input byte array.
    function slice(bytes memory _bytes, uint256 _start) internal view returns (bytes memory) {
        if (_start >= _bytes.length) {
            return bytes("");
        }
        return slice(_bytes, _start, _bytes.length - _start);
    }

    /// @notice Converts a byte array into a nibble array by splitting each byte into two nibbles.
    ///         Resulting nibble array will be exactly twice as long as the input byte array.
    /// @param _bytes Input byte array to convert.
    /// @return _nibbles Resulting nibble array.
    function toNibbles(bytes memory _bytes) internal pure returns (bytes memory _nibbles) {
        assembly ("memory-safe") {
            // Grab a free memory offset for the new array
            _nibbles := mload(0x40)

            // Load the length of the passed bytes array from memory
            let bytesLength := mload(_bytes)

            // Calculate the length of the new nibble array
            // This is the length of the input array times 2
            let nibblesLength := shl(0x01, bytesLength)

            // Update the free memory pointer to allocate memory for the new array.
            // To do this, we add the length of the new array + 32 bytes for the array length
            // rounded up to the nearest 32 byte boundary to the current free memory pointer.
            mstore(0x40, add(_nibbles, and(not(0x1F), add(nibblesLength, 0x3F))))

            // Store the length of the new array in memory
            mstore(_nibbles, nibblesLength)

            // Store the memory offset of the _bytes array's contents on the stack
            let bytesStart := add(_bytes, 0x20)

            // Store the memory offset of the nibbles array's contents on the stack
            let nibblesStart := add(_nibbles, 0x20)

            // Loop through each byte in the input array
            for { let i := 0x00 } lt(i, bytesLength) { i := add(i, 0x01) } {
                // Get the starting offset of the next 2 bytes in the nibbles array
                let offset := add(nibblesStart, shl(0x01, i))

                // Load the byte at the current index within the `_bytes` array
                let b := byte(0x00, mload(add(bytesStart, i)))

                // Pull out the first nibble and store it in the new array
                mstore8(offset, shr(0x04, b))
                // Pull out the second nibble and store it in the new array
                mstore8(add(offset, 0x01), and(b, 0x0F))
            }
        }
    }

    /// @notice Compares two byte arrays by comparing their keccak256 hashes.
    /// @param _a First byte array to compare.
    /// @param _b Second byte array to compare.
    /// @return _eq True if the two byte arrays are equal, false otherwise.
    function equal(bytes memory _a, bytes memory _b) internal pure returns (bool _eq) {
        assembly ("memory-safe") {
            _eq := eq(keccak256(_a, add(mload(_a), 0x20)), keccak256(_b, add(mload(_b), 0x20)))
        }
    }
}
