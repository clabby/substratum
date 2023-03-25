// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { TestUtils } from "test/testutils/TestUtils.sol";
import { TestArithmetic } from "test/testutils/TestArithmetic.sol";
import { LibMemory } from "src/lib/LibMemory.sol";
import { LibBytes } from "src/lib/LibBytes.sol";
import "src/types/Types.sol";

/// @title LibMemory_Test
/// @notice Tests for the `LibMemory` library.
contract LibMemory_Test is Test {
    ////////////////////////////////////////////////////////////////
    //                       `mcopy` Tests                        //
    ////////////////////////////////////////////////////////////////

    /// @dev Tests that `mcopy` correctly copies a given memory region.
    function test_mcopy_correctnessNoOffset_succeeds(bytes calldata _in, uint256 _length) public {
        // Ensure that the length is within the bounds of the input.
        _length = bound(_length, 0, _in.length);

        bytes memory _inMem = _in;
        MemoryPointer inPtr;
        assembly ("memory-safe") {
            inPtr := add(_inMem, 0x20)
        }
        bytes memory copied = LibMemory.mcopy(inPtr, 0, _length);

        assertEq(_in[:_length], copied);
        assertTrue(LibBytes.equal(_in[:_length], copied));
        assertEq(_length, copied.length);
    }

    /// @dev Tests that `mcopy` correctly copies a given memory region.
    function test_mcopy_correctnessWithOffset_succeeds(bytes calldata _in, uint256 _offset, uint256 _length) public {
        // Ensure that the offset is within the bounds of the input.
        _offset = bound(_offset, 0, TestArithmetic.saturatingSub(_in.length, 1));
        // Ensure that the length is within the bounds of the input.
        _length = bound(_length, 0, TestArithmetic.saturatingSub(_in.length, _offset));

        bytes memory _inMem = _in;
        MemoryPointer inPtr;
        assembly ("memory-safe") {
            inPtr := add(_inMem, 0x20)
        }
        bytes memory copied = LibMemory.mcopy(inPtr, _offset, _length);

        assertEq(_in[_offset:(_offset + _length)], copied);
        assertTrue(LibBytes.equal(_in[_offset:(_offset + _length)], copied));
        assertEq(_length, copied.length);
    }

    /// @dev Tests that `mcopy` is memory safe.
    function test_mcopy_memorySafety_succeeds(bytes memory _in) public {
        MemoryPointer ptr = TestUtils.getFreeMemoryPtr();

        MemoryPointer expectedPtr =
            MemoryPointer.wrap(uint24(MemoryPointer.unwrap(ptr) + 0x20 + TestArithmetic.roundUpTo32(_in.length)));

        MemoryPointer inPtr;
        assembly ("memory-safe") {
            inPtr := add(_in, 0x20)
        }

        vm.expectSafeMemory(MemoryPointer.unwrap(ptr), MemoryPointer.unwrap(expectedPtr));

        LibMemory.mcopy(inPtr, 0, _in.length);

        MemoryPointer actualPtr = TestUtils.getFreeMemoryPtr();

        // New memory should be allocated if the input length is non-zero.
        if (_in.length > 0) {
            assertEq(MemoryPointer.unwrap(actualPtr), MemoryPointer.unwrap(expectedPtr));
        } else {
            assertEq(MemoryPointer.unwrap(actualPtr), MemoryPointer.unwrap(ptr));
        }
    }
}
