// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { TestUtils } from "test/testutils/TestUtils.sol";
import { TestArithmetic } from "test/testutils/TestArithmetic.sol";
import { LibMemory } from "src/lib/LibMemory.sol";
import "src/types/Types.sol";

// TODO: Remove this once `vm.expectSafeMemory` is implemented in `forge-std`.
interface Cheats {
    function expectSafeMemory(uint64 _start, uint64 _end) external;
}

/// @title LibMemory_Test
/// @notice Tests for the `LibMemory` library.
contract LibMemory_Test is Test {
    /// @dev Tests that `mcopy` correctly copies a given memory region.
    function test_mcopy_correctness_succeeds(bytes memory _in) public {
        MemoryPointer inPtr;
        assembly ("memory-safe") {
            inPtr := add(_in, 0x20)
        }
        bytes memory copied = LibMemory.mcopy(inPtr, 0, _in.length);

        assertEq(_in, copied);
        assertEq(_in.length, copied.length);
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

        Cheats(address(vm)).expectSafeMemory(MemoryPointer.unwrap(ptr), MemoryPointer.unwrap(expectedPtr));

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
