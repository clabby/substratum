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
