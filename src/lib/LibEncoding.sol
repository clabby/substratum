// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { RLPWriterLib } from "src/lib/rlp/RLPWriterLib.sol";
import { LibHashing } from "src/lib/LibHashing.sol";
import "src/types/Types.sol";

/// @title LibEncoding
/// @notice LibEncoding handles Optimism's various different encoding schemes.
library LibEncoding {
    /// @notice RLP encodes the L2 transaction that would be generated when a given deposit is sent
    ///         to the L2 system. Useful for searching for a deposit in the L2 system. The
    ///         transaction is prefixed with 0x7e to identify its EIP-2718 type.
    /// @param _tx User deposit transaction to encode.
    /// @return RLP encoded L2 deposit transaction.
    /// @dev TODO: Optimize.
    function encodeDepositTransaction(UserDepositTransaction memory _tx) internal view returns (bytes memory) {
        Hash source = LibHashing.hashDepositSource(_tx.l1BlockHash, _tx.logIndex);
        bytes[] memory raw = new bytes[](8);
        raw[0] = RLPWriterLib.writeBytes(abi.encodePacked(source));
        raw[1] = RLPWriterLib.writeAddress(_tx.from);
        raw[2] = _tx.isCreation ? RLPWriterLib.writeBytes("") : RLPWriterLib.writeAddress(_tx.to);
        raw[3] = RLPWriterLib.writeUint(_tx.mint);
        raw[4] = RLPWriterLib.writeUint(_tx.value);
        raw[5] = RLPWriterLib.writeUint(uint256(Gas.unwrap(_tx.gasLimit)));
        raw[6] = RLPWriterLib.writeBool(false);
        raw[7] = RLPWriterLib.writeBytes(_tx.data);
        return abi.encodePacked(uint8(0x7e), RLPWriterLib.writeList(raw));
    }

    // cbd4ece9
    // 0000000000000000000000000000000000000000000000000000000000000001
    // 0000000000000000000000000000000000000000000000000000000000000002
    // 0000000000000000000000000000000000000000000000000000000000000080
    // 001e4a6b5e4175544b59b9cf4432c9ab2517b2e20d2e02fae38279cd3cfa4b73
    // 0000000000000000000000000000000000000000000000000000000000000003
    // c0ffee0000000000000000000000000000000000000000000000000000000000
    // 00000000000000000000000000000000000000000000000000000000
    function encodeCrossDomainMessageV0(address _target, address _sender, bytes memory _data, uint256 _nonce)
        internal
        pure
        returns (bytes memory _xdm)
    {
        assembly {
            // Grab some free memory for the encoded message
            _xdm := mload(0x40)

            // Store the "relayMessage(address,address,bytes,uint256)" function signature.
            mstore(add(_xdm, 0x20), shl(0xE0, 0xCBD4ECE9))

            // Store the target address
            mstore(add(_xdm, 0x24), _target)

            // Store the sender address
            mstore(add(_xdm, 0x44), _sender)

            // Store the pointer to the data's length
            mstore(add(_xdm, 0x64), 0x80)

            // Store the nonce
            mstore(add(_xdm, 0x84), _nonce)

            // Store the data's length
            let dataLen := mload(_data)
            mstore(add(_xdm, 0xA4), dataLen)

            // Copy data (wen mcopy)
            let dataLenRounded := and(not(0x1F), add(dataLen, 0x1F))
            for { let offset := 0xC4 } lt(offset, add(0xC4, dataLenRounded)) { offset := add(offset, 0x20) } {
                mstore(add(_xdm, offset), mload(add(_data, sub(offset, 0xA4))))
            }

            // Store the length of the encoded message
            mstore(_xdm, add(dataLen, 0xC4))

            // Update the free memory pointer
            mstore(0x40, add(_xdm, add(0xC4, dataLenRounded)))
        }
    }

    /// @notice Encodes a nonce and version into a single `VersionedNonce` type.
    /// @param _nonce The nonce to encode.
    /// @param _version The version to encode.
    /// @return _versionedNonce The encoded `VersionedNonce`.
    function encodeVersionedNonce(uint240 _nonce, uint16 _version)
        internal
        pure
        returns (VersionedNonce _versionedNonce)
    {
        assembly {
            _versionedNonce := or(shl(0xF0, _version), _nonce)
        }
    }

    /// @notice Decodes a nonce and version from a single `VersionedNonce` type.
    /// @param _versionedNonce The nonce to decode.
    /// @return _nonce The decoded nonce.
    /// @return _version The decoded version.
    function decodeVersionedNonce(VersionedNonce _versionedNonce)
        internal
        pure
        returns (uint240 _nonce, uint16 _version)
    {
        assembly {
            // Clean 16 most significant bits of the versioned nonce to get the nonce.
            _nonce := shr(0x10, shl(0x10, _versionedNonce))
            // Move the version to the least significant 16 bits of the 256 bit word.
            _version := shr(0xF0, _versionedNonce)
        }
    }
}
