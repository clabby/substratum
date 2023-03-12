// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title LibSafeCall
/// @notice Perform low level safe calls
library LibSafeCall {
    /// @notice Perform a low level call without copying any returndata
    /// @param _target   Address to call
    /// @param _gas      Amount of gas to pass to the call
    /// @param _value    Amount of value to pass to the call
    /// @param _calldata Calldata to pass to the call
    /// @return _success Whether the call succeeded
    function call(address _target, uint256 _gas, uint256 _value, bytes memory _calldata)
        internal
        returns (bool _success)
    {
        assembly ("memory-safe") {
            _success :=
                call(
                    _gas, // gas
                    _target, // recipient
                    _value, // ether value
                    add(_calldata, 0x20), // input data location
                    mload(_calldata), // input length (bytes)
                    0x00, // returndata location
                    0x00 // returndata size
                )
        }
    }

    // TODO: `callWithMinGas`
}
