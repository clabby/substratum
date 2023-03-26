// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { TestUtils } from "test/testutils/TestUtils.sol";
import { TestArithmetic } from "test/testutils/TestArithmetic.sol";
import { LibEncoding } from "src/lib/LibEncoding.sol";
import { Encoding } from "ctb/libraries/Encoding.sol";
import "src/types/Types.sol";
import { Types } from "ctb/libraries/Types.sol";

/// @title LibEncoding_Test
/// @notice Tests for the `LibEncoding` library.
contract LibEncoding_Test is Test {
    /// @dev Asserts that `LibEncoding.encodeCrossDomainMessageV0` and `Encoding.encodeCrossDomainMessageV0` are equivalent.
    function testDiff_encodeCrossDomainMessageV0_succeeds(
        address _target,
        address _sender,
        bytes memory _data,
        uint256 _nonce
    ) public {
        vm.assume(_data.length > 0);
        bytes memory actual = LibEncoding.encodeCrossDomainMessageV0(_target, _sender, _data, _nonce);
        bytes memory ref = Encoding.encodeCrossDomainMessageV0(_target, _sender, _data, _nonce);
        assertEq(actual, ref);
    }

    /// @dev Asserts that `LibEncoding.encodeCrossDomainMessageV1` and `Encoding.encodeCrossDomainMessageV1` are equivalent.
    function testDiff_encodeDepositTransaction(UserDepositTransaction memory _tx) public {
        bytes memory actual = LibEncoding.encodeDepositTransaction(_tx);
        bytes memory ref = Encoding.encodeDepositTransaction(Types.UserDepositTransaction({
            from: _tx.from,
            to: _tx.to,
            isCreation: _tx.isCreation,
            value: _tx.value,
            mint: _tx.mint,
            gasLimit: Gas.unwrap(_tx.gasLimit),
            data: _tx.data,
            l1BlockHash: Hash.unwrap(_tx.l1BlockHash),
            logIndex: _tx.logIndex
        }));
        assertEq(actual, ref);
    }

    /// @dev Asserts that `LibEncoding.encodeVersionedNonce` and `Encoding.encodeVersionedNonce` are equivalent.
    function testDiff_encodeVersionedNonce_succeeds(uint240 _nonce, uint16 _version) public {
        VersionedNonce actual = LibEncoding.encodeVersionedNonce(_nonce, _version);
        uint256 ref = Encoding.encodeVersionedNonce(_nonce, _version);
        assertEq(VersionedNonce.unwrap(actual), ref);
    }

    /// @dev Asserts that `LibEncoding.decodeVersionedNonce` and `Encoding.decodeVersionedNonce` are equivalent.
    function testDiff_decodeVersionedNonce_succeeds(VersionedNonce _versionedNonce) public {
        (uint240 _nonce, uint16 _version) = LibEncoding.decodeVersionedNonce(_versionedNonce);
        (uint240 _refNonce, uint16 _refVersion) = Encoding.decodeVersionedNonce(VersionedNonce.unwrap(_versionedNonce));
        assertEq(_nonce, _refNonce);
        assertEq(_version, _refVersion);
    }
}
