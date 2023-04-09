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
    function testClamp() public {
        // Test when _value is greater than _max
        int256 result1 = LibArithmetic.clamp(10, -5, 5);
        assertEq(result1, 5);

        // Test when _value is less than _min
        int256 result2 = LibArithmetic.clamp(-10, -5, 5);
        assertEq(result2, -5);

        // Test when _value is between _min and _max
        int256 result3 = LibArithmetic.clamp(3, -5, 5);
        assertEq(result3, 3);

        // Test when _value is equal to _min
        int256 result4 = LibArithmetic.clamp(-5, -5, 5);
        assertEq(result4, -5);

        // Test when _value is equal to _max
        int256 result5 = LibArithmetic.clamp(5, -5, 5);
        assertEq(result5, 5);

        // Test when _min is greater than _max
        int256 result6 = LibArithmetic.clamp(3, 10, 5);
        assertEq(result6, 5);

        // Test when _min and _max are equal
        int256 result7 = LibArithmetic.clamp(3, 5, 5);
        assertEq(result7, 5);
    }

    function test_cdexp() public {
        // Test when the denominator is 0
        vm.expectRevert();
        int256 result1 = LibArithmetic.cdexp(100, 0, 5);
        assertEq(result1, 100);

        // Test when the coefficient is 0
        int256 result2 = LibArithmetic.cdexp(0, 100, 5);
        assertEq(result2, 0);

        // Test when the exponent is 0
        int256 result3 = LibArithmetic.cdexp(100, 10, 0);
        assertEq(result3, 100);

        // Test when the exponent is 1
        int256 result4 = LibArithmetic.cdexp(100, 10, 1);
        assertEq(result4, 90);

        // Test when the coefficient and denominator are equal
        int256 result5 = LibArithmetic.cdexp(10, 10, 5);
        assertEq(result5, 10);

        // Test when the denominator is greater than the coefficient
        int256 result6 = LibArithmetic.cdexp(10, 100, 5);
        assertEq(result6, 10);

        // Test when the coefficient is negative
        int256 result7 = LibArithmetic.cdexp(-100, 10, 5);
        assertEq(result7, -55443);

        // Test when the exponent is negative
        int256 result8 = LibArithmetic.cdexp(100, 10, -5);
        assertEq(result8, 100000000000000000000);

        // Test when all inputs are max values
        int256 result9 = LibArithmetic.cdexp(type(int256).max, LibArithmetic.WAD - 1, type(int256).max);
        assertEq(result9, type(int256).max);

        // Test when all inputs are min values
        int256 result10 = LibArithmetic.cdexp(type(int256).min, 1, type(int256).min);
        assertEq(result10, 0);
    }
}
