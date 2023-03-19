// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { TestUtils } from "test/testutils/TestUtils.sol";
import { TestArithmetic } from "test/testutils/TestArithmetic.sol";
import { LibBytes } from "src/lib/LibBytes.sol";
import "src/types/Types.sol";
import "src/types/Errors.sol";

// TODO: Remove this once `vm.expectSafeMemory` is implemented in `forge-std`.
interface Cheats {
    function expectSafeMemory(uint64 _start, uint64 _end) external;
}

/// @title LibBytes_Test
/// @notice Tests for the `LibBytes` library.
contract LibBytes_Test is Test {
    ////////////////////////////////////////////////////////////////
    //                       `slice` Tests                        //
    ////////////////////////////////////////////////////////////////

    /// @dev Tests that the `slice` function correctly slices a given bytes array.
    function test_slice_staticSingleWord_success() public {
        bytes memory testCase = hex"abcdef0123456789";
        bytes memory slice = LibBytes.slice(testCase, 3, 5);

        assertEq(slice.length, 5);
        assertEq(slice, hex"0123456789");
    }

    /// @dev Tests that the `slice` function correctly slices a given bytes array.
    function test_slice_staticMultiWord_success() public {
        bytes memory testCase =
            hex"aabbccddeeffaabbccddeeffaabbccddeeffaabbccddeeffaabbccddeeffaabbccddeeffaabbccddeeffaabbccddeeffaabbccddeeffaabbccddeeffaabbccddeeffaabbccddeeffaabbccddeeffaabbccddeeffaabbccddeeffaabbccdd";
        bytes memory slice = LibBytes.slice(testCase, 29, 6);

        assertEq(slice.length, 6);
        assertEq(slice, hex"ffaabbccddee");
    }

    /// @dev Tests that the `slice` function correctly returns a zero-length slice when
    ///      the requested slice length is zero.
    function testFuzz_slice_zeroLength_success(bytes memory _bytes, uint256 _start) public {
        // Ensure that the start index is within bounds.
        _start = bound(_start, 0, TestArithmetic.saturatingSub(_bytes.length, 1));

        bytes memory slice = LibBytes.slice(_bytes, _start, 0);
        assertEq(slice.length, 0);
        assertEq(slice, hex"");
    }

    /// @dev Tests that the `slice` function is memory-safe.
    function testFuzz_slice_memorySafety_succeeds(bytes memory _bytes, uint256 _start, uint256 _length) public {
        // Bound the start and length variables to ensure that the slice is in-bounds of the `_bytes` array.
        _start = bound(_start, 0, TestArithmetic.saturatingSub(_bytes.length, 1));
        _length = bound(_length, 0, TestArithmetic.saturatingSub(_bytes.length, _start));

        // Grab the free memory pointer prior to slicing
        MemoryPointer ptr = TestUtils.getFreeMemoryPtr();
        // Calculate the expected free memory pointer after the slice
        MemoryPointer expectedPtr = MemoryPointer.wrap(uint24(MemoryPointer.unwrap(ptr) + 0x20 + TestArithmetic.roundUpTo32(_length)));

        Cheats(address(vm)).expectSafeMemory(MemoryPointer.unwrap(ptr), MemoryPointer.unwrap(expectedPtr));

        // Perform a slice
        LibBytes.slice(_bytes, _start, _length);

        // Grab the free memory pointer after the slice
        MemoryPointer actualPtr = TestUtils.getFreeMemoryPtr();

        // Check that the free memory pointer has been properly updated to account for the newly allocated memory.
        // Note that new memory is only allocated if the slice length is non-zero.
        if (_length > 0) {
            assertEq(MemoryPointer.unwrap(ptr), MemoryPointer.unwrap(expectedPtr));
        } else {
            assertEq(MemoryPointer.unwrap(ptr), MemoryPointer.unwrap(actualPtr));
        }
    }

    /// @dev Tests that the `slice` function correctly reverts with `SliceOutOfBounds` when the requested slice is out of
    /// bounds of the input bytes array.
    function testFuzz_slice_sliceOverflow_reverts(bytes memory _bytes, uint256 _start, uint256 _length) public {
        _start = bound(_start, 0, TestArithmetic.saturatingSub(_bytes.length, 1));
        _length = bound(_length, type(uint256).max - 30, type(uint256).max);

        vm.expectRevert(SliceOverflow.selector);
        LibBytes.slice(_bytes, _start, _length);
    }

    /// @dev Tests that the `slice` function correctly reverts with `SliceOutOfBounds` when the requested slice is out of
    /// bounds of the input bytes array.
    function testFuzz_slice_sliceOutOfBounds_reverts(bytes memory _bytes, uint256 _start, uint256 _length) public {
        _start = bound(_start, 0, TestArithmetic.saturatingSub(_bytes.length, 1));
        _length = bound(_length, TestArithmetic.saturatingSub(_bytes.length, _start) + 1, type(uint32).max);

        vm.expectRevert(SliceOutOfBounds.selector);
        LibBytes.slice(_bytes, _start, _length);
    }

    ////////////////////////////////////////////////////////////////
    //                     `toNibbles` Tests                      //
    ////////////////////////////////////////////////////////////////

    /// @dev Tests the `toNibbles` function with a static input.
    function test_toNibbles_staticSingleWord_succeeds() public {
        bytes memory input = hex"1234567890abcdef";
        bytes memory expected = hex"010203040506070809000a0b0c0d0e0f";
        bytes memory actual = LibBytes.toNibbles(input);
        assertEq(expected, actual);
    }

    /// @dev Tests the `toNibbles` function with a static input.
    function test_toNibbles_staticMultiWord_succeeds() public {
        bytes memory input =
            hex"7910d1562d214002211805e5873f17121234a7d4d27ec28ba9e34f9bf2af61915ac88bf312a9808d4cd3d82e0a7b9168227e5faa1ef69430b2f86746fae24489e4da76baf9f8a01b65afa6bde83f7eb66abcb33886f7fae315e293aa7771ec66";
        bytes memory expected =
            hex"070901000d010506020d0201040000020201010800050e050807030f01070102010203040a070d040d02070e0c02080b0a090e03040f090b0f020a0f06010901050a0c08080b0f0301020a090800080d040c0d030d08020e000a070b090106080202070e050f0a0a010e0f06090403000b020f08060704060f0a0e02040408090e040d0a07060b0a0f090f080a00010b06050a0f0a060b0d0e08030f070e0b06060a0b0c0b03030808060f070f0a0e0301050e0209030a0a070707010e0c0606";
        bytes memory actual = LibBytes.toNibbles(input);
        assertEq(expected, actual);
    }

    /// @dev Tests that the `toNibbles` function behaves identically to a solidity implementation.
    function testDiff_toNibbles_solidityDiff_succeeds(bytes memory _in) public {
        bytes memory ref = new bytes(_in.length * 2);
        for (uint256 i = 0; i < _in.length; i++) {
            ref[i * 2] = bytes1(uint8(_in[i]) >> 4);
            ref[i * 2 + 1] = bytes1(uint8(_in[i]) & 0x0F);
        }
        bytes memory expected = LibBytes.toNibbles(_in);

        assertEq(ref, expected);
        assertEq(ref.length, expected.length);

        // Hash the two arrays in memory (including the length word) and compare the hashes.
        bool _eq;
        assembly {
            _eq := eq(keccak256(ref, add(mload(ref), 0x20)), keccak256(expected, add(mload(expected), 0x20)))
        }
        assertTrue(_eq);
    }

    /// @dev Tests that the `toNibbles` function:
    ///      1. Properly updates the free memory pointer.
    ///      2. Properly assigns the length of the nibbles array.
    ///      3. Does not modify any other memory outside of the expected allocation.
    function testFuzz_toNibbles_memorySafety_succeeds(bytes memory _in) public {
        // Grab the free memory pointer prior to slicing
        MemoryPointer ptr = TestUtils.getFreeMemoryPtr();
        // Compute the expected free memory pointer after the operation
        // ptr + length_word + roundUpTo32(length * 2)
        MemoryPointer expectedPtr = MemoryPointer.wrap(uint24(MemoryPointer.unwrap(ptr) + 0x20 + TestArithmetic.roundUpTo32(_in.length * 2)));

        // Assert that the only memory that is touched is between the current free memory pointer
        // and the expected free memory pointer.
        // TODO: Replace with `vm.expectSafeMemory` once it is implemented in `forge-std`.
        Cheats(address(vm)).expectSafeMemory(MemoryPointer.unwrap(ptr), MemoryPointer.unwrap(expectedPtr));
        // address(vm).call(abi.encodeWithSignature("expectSafeMemory(uint256,uint256)", ptr, expectedPtr));

        // Perform the `toNibbles` operation
        assertEq(LibBytes.toNibbles(_in).length, _in.length * 2);

        // Grab the free memory pointer after the slice
        MemoryPointer actualPtr = TestUtils.getFreeMemoryPtr();

        // Check that the free memory pointer has been properly updated to account for the newly allocated memory.
        assertEq(MemoryPointer.unwrap(actualPtr), MemoryPointer.unwrap(expectedPtr));
    }

    ////////////////////////////////////////////////////////////////
    //                       `equal` tests                        //
    ////////////////////////////////////////////////////////////////

    /// @dev Tests that the `equal` function correctly returns `true` when the input byte arrays are equal.
    function test_equal_staticShort_succeeds() public {
        bytes memory a = hex"8232a437549ca0876893c528a1957ff9";
        bytes memory b = hex"8232a437549ca0876893c528a1957ff9";
        assertTrue(LibBytes.equal(a, b));
    }

    /// @dev Tests that the `equal` function correctly returns `true` when the input byte arrays are equal.
    function test_equal_staticLong_succeeds() public {
        bytes memory a =
            hex"082F196D88E817B51D5CFA5D23244F3462ABAE2BE6D5E7A8944BC3035DC28B0639DA5025FB835591070804035C0E0647D7D7BA115686EFD20423B1694FFA6F4FF81DA7717309BD2396E9A74924B427546697966D9068E10CDC2318DBF68C7D61CEF0908043DC";
        bytes memory b =
            hex"082F196D88E817B51D5CFA5D23244F3462ABAE2BE6D5E7A8944BC3035DC28B0639DA5025FB835591070804035C0E0647D7D7BA115686EFD20423B1694FFA6F4FF81DA7717309BD2396E9A74924B427546697966D9068E10CDC2318DBF68C7D61CEF0908043DC";
        assertTrue(LibBytes.equal(a, b));
    }

    /// @dev Tests that the `equal` function correctly returns `false` when the input byte arrays are not equal.
    function testFuzz_equal_notEqual_fails(bytes memory _a, bytes memory _b) public {
        vm.assume(_a.length != _b.length || keccak256(_a) != keccak256(_b));
        assertFalse(LibBytes.equal(_a, _b));
    }
}
