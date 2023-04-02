// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { TestUtils } from "test/testutils/TestUtils.sol";
import { TestArithmetic } from "test/testutils/TestArithmetic.sol";
import { LibArithmetic } from "src/lib/LibArithmetic.sol";
import "src/types/Types.sol";

/// @title LibArithmeti_Test
/// @notice Tests for the `LibBurn` library.
contract LibArithmetic_Test is Test {
    function test_clamp() public {
        assertTrue(LibArithmetic.clamp(0, 0, 10) == 0);
        assertTrue(LibArithmetic.clamp(5, 0, 10) == 5);
        assertTrue(LibArithmetic.clamp(10, 0, 10) == 10);
        assertTrue(LibArithmetic.clamp(11, 0, 10) == 10);
        assertTrue(LibArithmetic.clamp(20, 0, 10) == 10);
    }

    function test_cdexp() public {
        LibArithmetic.cdexp(1, 1, 1);
    }
}