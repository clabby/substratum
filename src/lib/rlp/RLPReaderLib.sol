// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "src/types/Types.sol";
import { LibMemory } from "src/lib/LibMemory.sol";

/// @title RLPReaderLib
/// @notice RLPReaderLib is a library for parsing RLP-encoded byte arrays into Solidity types. Adapted
///         from Solidity-RLP (https://github.com/hamdiallam/Solidity-RLP) by Hamdi Allam with
///         various tweaks to improve gas efficiency and readability.
/// @custom:attribution https://github.com/hamdiallam/Solidity-RLP
library RLPReaderLib {
    ////////////////////////////////////////////////////////////////
    //                         CONSTANTS                          //
    ////////////////////////////////////////////////////////////////

    /// @notice Max list index that this library will accept.
    uint256 internal constant MAX_LIST_INDEX = 31;

    ////////////////////////////////////////////////////////////////
    //                    RLPItem Type Helpers                    //
    ////////////////////////////////////////////////////////////////

    /// @notice Wraps a memory pointer and length into an RLPItem type.
    /// @param _ptr The memory pointer.
    /// @param _len The length of the item.
    /// @return _item The RLPItem.
    function wrapRLPItem(MemoryPointer _ptr, uint232 _len) internal pure returns (RLPItem _item) {
        assembly ("memory-safe") {
            _item := or(shl(0xE8, _ptr), _len)
        }
    }

    /// @notice Unwraps an RLPItem into a memory pointer and length.
    /// @param _item The RLPItem.
    /// @return _ptr The memory pointer.
    /// @return _len The length of the item.
    function unwrapRLPItem(RLPItem _item) internal pure returns (MemoryPointer _ptr, uint232 _len) {
        assembly ("memory-safe") {
            // The pointer is the 24-bit value in the high-order 24 bits of the item.
            _ptr := shr(0xE8, _item)
            // Clean high-order 24 bits from the item to receive the 232 bit length
            _len := shr(0x18, shl(0x18, _item))
        }
    }

    /// @notice Converts bytes to a reference to memory position and length.
    /// @param _in Input bytes to convert.
    /// @return _rlpItem Output memory reference.
    function toRLPItem(bytes memory _in) internal pure returns (RLPItem _rlpItem) {
        MemoryPointer ptr;
        uint232 inLen;
        assembly ("memory-safe") {
            ptr := add(_in, 0x20)
            inLen := mload(_in)

            // Assertion: inLen != 0
            if iszero(inLen) {
                // Store "RLPItemEmpty()" selector in scratch space.
                mstore(0x00, 0xe2ad24d9)
                // Revert
                revert(0x1c, 0x04)
            }
        }
        return wrapRLPItem(ptr, inLen);
    }

    ////////////////////////////////////////////////////////////////
    //                  RLPReader Functionality                   //
    ////////////////////////////////////////////////////////////////

    /// @notice Reads an RLP list value into a list of RLP items.
    /// @param _in RLP list value.
    /// @return _list Decoded RLP list items.
    function readList(RLPItem _in) internal pure returns (RLPItem[] memory _list) {
        (uint256 listOffset, uint256 listLength, RLPItemType itemType) = _decodeLength(_in);
        (MemoryPointer inPtr, uint240 inLen) = unwrapRLPItem(_in);
        MemoryPointer listDataOffset;

        assembly ("memory-safe") {
            // Assertion: itemType == RLPItemType.LIST_ITEM
            if iszero(eq(itemType, 0x01)) {
                // Store the "RLPNotAList()" selector in scratch space.
                mstore(0x00, 0xf5ad531e)
                // Revert
                revert(0x1c, 0x04)
            }

            if iszero(eq(add(listOffset, listLength), inLen)) {
                // Store the "RLPInvalidDataRemainder()" selector in scratch space.
                mstore(0x00, 0xd552ec6e)
                // Revert
                revert(0x1c, 0x04)
            }

            // Assign the list to the free memory pointer.
            _list := mload(0x40)
            listDataOffset := add(_list, 0x20)
        }

        // Loop variables
        uint256 itemCount = 0;
        while (listOffset < inLen) {
            MemoryPointer itemPtr = MemoryPointer.wrap(uint24(MemoryPointer.unwrap(inPtr) + listOffset));
            (uint256 itemOffset, uint256 itemLength,) = _decodeLength(wrapRLPItem(itemPtr, uint232(inLen - listOffset)));
            RLPItem inner = wrapRLPItem(itemPtr, uint232(itemLength + itemOffset));

            assembly ("memory-safe") {
                // Assertion: itemCount <= MAX_LIST_INDEX
                if gt(itemCount, MAX_LIST_INDEX) {
                    // Store the "RLPListTooLong()" selector in scratch space.
                    mstore(0x00, 0x879dcbe3)
                    // Revert
                    revert(0x1c, 0x04)
                }

                // Store the RLPItem in the list
                mstore(add(listDataOffset, shl(0x05, itemCount)), inner)

                // Increment the item count
                itemCount := add(itemCount, 0x01)
                // Increment the offset by the full length of the RLP Item
                listOffset := add(listOffset, add(itemOffset, itemLength))
            }
        }

        assembly ("memory-safe") {
            // Set the length of the list
            mstore(_list, itemCount)
            // Update the free memory pointer
            mstore(0x40, add(listDataOffset, shl(0x05, itemCount)))
        }
    }

    /// @notice Reads an RLP list value into a list of RLP items.
    /// @param _in RLP list value.
    /// @return _list Decoded RLP list items.
    function readList(bytes memory _in) internal pure returns (RLPItem[] memory _list) {
        return readList(toRLPItem(_in));
    }

    /// @notice Reads an RLP bytes value into bytes.
    /// @param _in RLP bytes value.
    /// @return _out Decoded bytes.
    function readBytes(RLPItem _in) internal pure returns (bytes memory _out) {
        (uint256 itemOffset, uint256 itemLength, RLPItemType itemType) = _decodeLength(_in);
        (MemoryPointer inPtr, uint240 inLen) = unwrapRLPItem(_in);

        assembly ("memory-safe") {
            // Assertion: itemType == RLPItemType.DATA_ITEM
            if gt(itemType, 0x00) {
                // Store the "RLPNotABytes()" selector in scratch space.
                mstore(0x00, 0x2f6b05a2)
                // Revert
                revert(0x1c, 0x04)
            }

            if iszero(eq(inLen, add(itemOffset, itemLength))) {
                // Store the "RLPInvalidDataRemainder()" selector in scratch space.
                mstore(0x00, 0xd552ec6e)
                // Revert
                revert(0x1c, 0x04)
            }
        }

        // Copy the bytes within the RLP item
        return LibMemory.mcopy(inPtr, itemOffset, itemLength);
    }

    /// @notice Reads an RLP bytes value into bytes.
    /// @param _in RLP bytes value.
    /// @return _bytes Decoded bytes.
    function readBytes(bytes memory _in) internal pure returns (bytes memory _bytes) {
        return readBytes(toRLPItem(_in));
    }

    /// @notice Reads the raw bytes of an RLP item.
    /// @param _in RLP item to read.
    /// @return _out Raw RLP bytes.
    function readRawBytes(RLPItem _in) internal pure returns (bytes memory _out) {
        (MemoryPointer inPtr, uint240 inLen) = unwrapRLPItem(_in);

        // Copy the bytes within the RLP item
        return LibMemory.mcopy(inPtr, 0, inLen);
    }

    /// @notice Decodes the length of an RLP item.
    /// @param _in RLP item to decode.
    /// @return _offset Offset of the encoded data.
    /// @return _length Length of the encoded data.
    /// @return _type RLP item type (LIST_ITEM or DATA_ITEM).
    function _decodeLength(RLPItem _in) private pure returns (uint256 _offset, uint256 _length, RLPItemType _type) {
        (MemoryPointer inPtr, uint232 inLen) = unwrapRLPItem(_in);
        assembly ("memory-safe") {
            /// @dev Shorthand for reverting with a selector.
            function revertWithSelector(selector) {
                // Store selector in scratch space.
                mstore(0x00, selector)
                // Revert
                revert(0x1c, 0x04)
            }

            // Assertion: inLen > 0
            // Short-circuit if there's nothing to decode, note that we perform this check when
            // the user creates an RLP item via toRLPItem, but it's always possible for them to bypass
            // that function and create an RLP item directly. So we need to check this anyway.
            if iszero(inLen) {
                // Store "RLPItemEmpty()" selector in scratch space.
                mstore(0x00, 0xe2ad24d9)
                // Revert
                revert(0x1c, 0x04)
            }

            // Load the prefix byte of the RLP item.
            let prefix := byte(0x00, mload(inPtr))

            switch lt(prefix, 0x80)
            case true {
                // If the prefix is less than 0x7F, then it is a single byte
                _offset := 0x00
                _length := 0x01
                // RLPItemType.DATA_ITEM = 0x00
                _type := 0x00
            }
            default {
                switch lt(prefix, 0xB8)
                case true {
                    // If the prefix is less than 0xB7, then it is a short string
                    _offset := 0x01
                    _length := sub(prefix, 0x80)
                    // RLPItemType.DATA_ITEM = 0x00
                    _type := 0x00

                    // Assertion: inLen > _length
                    if iszero(gt(inLen, _length)) {
                        // Revert with the "RLPInvalidContentLength()" selector.
                        revertWithSelector(0x03cbee18)
                    }

                    // Assertion: _length != 0x01 || firstByte >= 0x80
                    if and(eq(0x01, _length), lt(byte(0x01, mload(inPtr)), 0x80)) {
                        // Revert with the "RLPInvalidPrefix()" selector.
                        revertWithSelector(0x7f0fdb83)
                    }
                }
                default {
                    switch lt(prefix, 0xC0)
                    case true {
                        // If the prefix is less than 0xBF, then it is a long string

                        // Grab length of the string length figure (in bytes).
                        let lengthOfLength := sub(prefix, 0xB7)

                        // Assertion: inLen > lengthOfLength
                        if iszero(gt(inLen, lengthOfLength)) {
                            // Revert with the "RLPInvalidContentLength()" selector.
                            revertWithSelector(0x03cbee18)
                        }

                        // Assertion: firstByte != 0
                        if iszero(byte(0x01, mload(inPtr))) {
                            // Revert with the "RLPNoLeadingZeros()" selector.
                            revertWithSelector(0xc0b6f8d9)
                        }

                        // Get the length of the long string
                        _length := shr(sub(0x100, shl(0x03, _length)), mload(add(inPtr, 0x01)))

                        // Assertion: _length > 55 && inLen > lengthOfLength + _length
                        if or(lt(_length, 0x38), iszero(gt(inLen, add(lengthOfLength, _length)))) {
                            // Revert with the "RLPInvalidContentLength()" selector.
                            revertWithSelector(0x03cbee18)
                        }

                        _offset := add(0x01, lengthOfLength)
                        // RLPItemType.DATA_ITEM = 0x00
                        _type := 0x00
                    }
                    default {
                        switch lt(prefix, 0xF8)
                        case true {
                            // If the prefix is <= 0xF7, then it is a short list
                            _length := sub(prefix, 0xC0)

                            // Assertion: inLen > _length
                            if iszero(gt(inLen, _length)) {
                                // Revert with the "RLPInvalidContentLength()" selector.
                                revertWithSelector(0x03cbee18)
                            }

                            _offset := 0x01
                            // RLPItemType.LIST_ITEM = 0x01
                            _type := 0x01
                        }
                        default {
                            // If the prefix is > 0xF7, then it is a long list
                            let lengthOfLength := sub(prefix, 0xF7)

                            // Assertion: inLen > lengthOfLength
                            if iszero(gt(inLen, lengthOfLength)) {
                                // Revert with the "RLPInvalidContentLength()" selector.
                                revertWithSelector(0x03cbee18)
                            }

                            // Assertion: firstByte != 0
                            if iszero(byte(0x01, mload(inPtr))) {
                                // Revert with the "RLPNoLeadingZeros()" selector.
                                revertWithSelector(0xc0b6f8d9)
                            }

                            // Get the length of the long list
                            _length := shr(sub(0x100, shl(0x03, lengthOfLength)), mload(add(inPtr, 0x01)))

                            // Assertion: _length > 55 && inLen > lengthOfLength + _length
                            if or(lt(_length, 0x38), iszero(gt(inLen, add(lengthOfLength, _length)))) {
                                // Revert with the "RLPInvalidContentLength()" selector.
                                revertWithSelector(0x03cbee18)
                            }

                            _offset := add(0x01, lengthOfLength)
                            // RLPItemType.LIST_ITEM = 0x01
                            _type := 0x01
                        }
                    }
                }
            }
        }
    }
}
