// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "src/types/Types.sol";
import { LibMemory } from "src/lib/LibMemory.sol";
import { LibBytes } from "src/lib/LibBytes.sol";

/// @title RLPWriterLib
/// @notice @author RLPWriter is a library for encoding Solidity types to RLP bytes. Adapted from Bakaoh's
///         RLPEncode library (https://github.com/bakaoh/solidity-rlp-encode) with minor
///         modifications to improve legibility.
/// @custom:attribution https://github.com/bakaoh/solidity-rlp-encode
/// @custom:attribution https://github.com/Vectorized/solady
library RLPWriterLib {
    /// @notice RLP encodes a byte string.
    /// @param _in The byte string to encode.
    /// @return _rlp The RLP encoded byte string.
    function writeBytes(bytes memory _in) internal view returns (bytes memory _rlp) {
        if (_in.length == 1 && uint8(_in[0]) < 128) {
            _rlp = _in;
        } else {
            _rlp = _writeLengthAndAppend(_in.length, 128, _in);
        }
    }

    /// @notice RLP encodes a list of RLP encoded byte strings.
    /// @param _in The list of RLP encoded byte strings.
    /// @return _rlp The RLP encoded list.
    function writeList(bytes[] memory _in) internal view returns (bytes memory _rlp) {
        bytes memory flattened = LibBytes.flatten(_in);
        _rlp = _writeLengthAndAppend(flattened.length, 192, flattened);
    }

    /// @notice RLP encodes a string.
    /// @param _in The string to encode.
    /// @return _rlp The RLP encoded string.
    function writeString(string memory _in) internal view returns (bytes memory _rlp) {
        return writeBytes(bytes(_in));
    }

    /// @notice RLP encodes an address.
    /// @param _in The address to encode.
    /// @return _rlp The RLP encoded address.
    function writeAddress(address _in) internal pure returns (bytes memory _rlp) {
        _rlp = writeLength(20, 128);
        assembly ("memory-safe") {
            // Grab the length of the prefix
            let prefixLength := mload(_rlp)
            // Append the address
            mstore(add(add(_rlp, 0x20), prefixLength), shl(0x60, _in))
            // Update the length of the RLP encoded bytes
            mstore(_rlp, add(prefixLength, 0x14))
        }
    }

    /// @notice RLP encodes a uint.
    /// @param _in The uint to encode.
    /// @return _rlp The RLP encoded uint.
    function writeUint(uint256 _in) internal view returns (bytes memory _rlp) {
        (uint256 leadingZeroBytes, uint256 trimmed) = LibBytes.trimLeadingZeros(_in);
        assembly ("memory-safe") {
            // Grab some free memory
            _rlp := mload(0x40)

            // Write the trimmed uint to memory
            mstore(add(_rlp, 0x20), trimmed)

            // Store the length of the RLP encoded uint
            mstore(_rlp, sub(0x20, leadingZeroBytes))

            // Update the free memory pointer
            mstore(0x40, add(_rlp, 0x40))
        }
        _rlp = writeBytes(_rlp);
    }

    /// @notice RLP encodes a bool
    /// @param _in The bool to encode.
    /// @return _rlp The RLP encoded bool.
    function writeBool(bool _in) internal pure returns (bytes memory _rlp) {
        assembly ("memory-safe") {
            // Grab some free memory
            _rlp := mload(0x40)

            // Store the bool in the first byte of the RLP encoded bytes
            switch _in
            case true { mstore(add(_rlp, 0x01), 0x01) }
            case false { mstore(add(_rlp, 0x01), 0x80) }

            // Store the length of the RLP encoded bool
            mstore(_rlp, 0x01)

            // Update the free memory pointer
            mstore(0x40, add(_rlp, 0x40))
        }
    }

    /// @notice Encodes the first byte and then the `_length` in binary form if the `_length` is more than 55.
    /// @param _length The length of the payload.
    /// @param _offset 128 if the item is a string, 192 if it is a list.
    /// @return _rlp The RLP encoded prefix + length.
    function writeLength(uint256 _length, uint256 _offset) internal pure returns (bytes memory _rlp) {
        assembly ("memory-safe") {
            // Grab some free memory for the RLP encoded bytes
            _rlp := mload(0x40)

            // If the length is less than 56, then the first byte is the length + offset
            switch lt(_length, 0x38)
            case true {
                // Store the length of the prefix
                mstore(_rlp, 0x01)
                // Store the prefix: length + offset
                mstore8(add(_rlp, 0x20), add(_length, _offset))
            }
            case false {
                // Count leading zero bits in `_length`

                let x := _length // copy
                // Get the length of the length (in bits)
                let t := add(iszero(x), 255)

                let lastSetBit := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
                lastSetBit := or(lastSetBit, shl(6, lt(0xffffffffffffffff, shr(lastSetBit, x))))
                lastSetBit := or(lastSetBit, shl(5, lt(0xffffffff, shr(lastSetBit, x))))

                // For the remaining 32 bits, use a De Bruijn lookup.
                x := shr(lastSetBit, x)
                x := or(x, shr(1, x))
                x := or(x, shr(2, x))
                x := or(x, shr(4, x))
                x := or(x, shr(8, x))
                x := or(x, shr(16, x))

                // forgefmt: disable-next-item
                lastSetBit := sub(t, or(lastSetBit, byte(shr(251, mul(x, shl(224, 0x07c4acdd))),
                    0x0009010a0d15021d0b0e10121619031e080c141c0f111807131b17061a05041f)))

                // Calculate the length of the length by shifting the most significant bit to the right
                // by 3 (integer div by 8) and subtracting this value from 0x20 (32 bytes)
                let lengthOfLength := sub(0x20, shr(0x03, lastSetBit))

                // Store the length of the payload
                mstore(add(add(_rlp, 0x01), lengthOfLength), _length)

                // Store the prefix + length
                mstore(_rlp, add(lengthOfLength, 0x01))

                // Store the lengthOfLength + offset + 55
                mstore8(add(_rlp, 0x20), add(add(lengthOfLength, _offset), 0x37))
            }
        }
    }

    /// @notice Encode an RLP string.
    /// @param _length The length of the string.
    /// @param _offset The offset to use for the string.
    /// @param _in The string to encode.
    function _writeLengthAndAppend(uint256 _length, uint256 _offset, bytes memory _in)
        internal
        view
        returns (bytes memory _rlp)
    {
        // Write the length for the string
        _rlp = writeLength(_length, _offset);

        // Copy the string into the RLP encoded bytes array
        uint256 lengthOfLength;
        uint256 lengthOfString;
        MemoryPointer inPtr;
        MemoryPointer destPtr;
        assembly ("memory-safe") {
            lengthOfLength := mload(_rlp)
            lengthOfString := mload(_in)

            inPtr := add(_in, 0x20)
            destPtr := add(add(_rlp, 0x20), lengthOfLength)
        }
        LibMemory.mcopyDirect(inPtr, destPtr, lengthOfString);

        // Re-assign the length of the RLP encoded bytes array
        assembly ("memory-safe") {
            mstore(_rlp, add(lengthOfLength, lengthOfString))
        }
    }
}
