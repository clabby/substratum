// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title LibConstants
/// @notice LibConstants is a library for storing constants.
/// @dev Constants that only apply to a single contract should be defined in that contract instead.
library LibConstants {
    /// @notice Special address to be used as the tx origin for gas estimation calls in the OptimismPortal and
    ///         CrossDomainMessenger calls. You only need to use this address if the minimum gas limit specified by
    ///         the user is not enough to execute the given message and you're attempting to estimate the necessary
    ///         gas limit. We use the ecrecover precompile address due to the fact that it is guaranteed to not have
    ///         any code on any EVM chain.
    address internal constant ESTIMATION_ADDRESS = address(0x01);

    /// @notice Value for the L2 sender storage slot in both the OptimismPortal and the CrossDomainMessenger contracts
    ///         before an actual sender is set. This value is non-zero to reduce the gas cost of message passing
    ///         transactions.
    address internal constant DEFAULT_L2_SENDER = address(0xdead);
}
