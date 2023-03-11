// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { TestUtils } from "test/testutils/TestUtils.sol";
import { TestArithmetic } from "test/testutils/TestArithmetic.sol";
import { LibBytes } from "src/lib/LibBytes.sol";
import "src/types/Types.sol";
import "src/types/Errors.sol";

/// @title LibBytes_Test
/// @notice Tests for the `LibBytes` library.
contract LibBytes_Test is Test {
    ////////////////////////////////////////////////////////////////
    //                       `slice` Tests                        //
    ////////////////////////////////////////////////////////////////

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
        uint256 ptr = TestUtils.getFreeMemoryPtr();

        // Perform a slice
        LibBytes.slice(_bytes, _start, _length);

        // Grab the free memory pointer after the slice
        uint256 newPtr = TestUtils.getFreeMemoryPtr();

        // Check that the free memory pointer has been properly updated to account for the newly allocated memory.
        // Note that new memory is only allocated if the slice length is non-zero.
        if (_length > 0) {
            assertEq(newPtr, ptr + 0x20 + TestArithmetic.roundUpTo32(_length));
        } else {
            assertEq(newPtr, ptr);
        }
    }

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
}
