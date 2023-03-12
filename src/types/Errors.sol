// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

////////////////////////////////////////////////////////////////
//                          LibBytes                          //
////////////////////////////////////////////////////////////////

/// @dev Thrown if the requested slice is out of bounds of the input bytes array.
error SliceOverflow();

/// @dev Thrown if the requested slice is out of bounds of the input bytes array.
error SliceOutOfBounds();

////////////////////////////////////////////////////////////////
//                         RLP Errors                         //
////////////////////////////////////////////////////////////////

/// @dev Thrown when attempting to call `toRLPItem` on an empty bytes array.
error RLPItemEmpty();

/// @dev Thrown when the length of an RLP item is too long to be represented
///      by the content itself.
error RLPInvalidContentLength();

/// @dev Thrown when an invalid prefix for an RLPItem is encountered.
error RLPInvalidPrefix();

/// @dev Thrown when an RLP item has unexpected leading zeros.
error RLPNoLeadingZeros();

/// @dev Thrown when attempting to read an RLP item that is not a list.
error RLPNotAList();

/// @dev Thrown when attempting to read an RLP item that is not a data item.
error RLPNotADataItem();

/// @dev Thrown when an RLP item with an invalid data remainder is encountered.
error RLPInvalidDataRemainder();

/// @dev Thrown when an RLP list is too long to be represented by the content itself.
error RLPListTooLong();
