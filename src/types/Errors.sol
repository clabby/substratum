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

/// @notice Thrown when attempting to call `toRLPItem` on an empty bytes array.
error RLPItemEmpty();

/// @notice Thrown when the length of an RLP item is too long to be represented
///         by the content itself.
error RLPInvalidContentLength();

/// @notice Thrown when an invalid prefix for an RLPItem is encountered.
error RLPInvalidPrefix();

/// @notice Thrown when an RLP item has unexpected leading zeros.
error RLPNoLeadingZeros();

error RLPNotAList();

error RLPInvalidDataRemainder();

error RLPListTooLong();
