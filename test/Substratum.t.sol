// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { Substratum } from "src/Substratum.sol";

/// @title Substratum_Test
/// @notice Tests for the `Substratum` contract.
contract Substratum_Test is Test {
    ////////////////////////////////////////////////////////////////
    //                        Environment                         //
    ////////////////////////////////////////////////////////////////

    Substratum internal substratum;

    ////////////////////////////////////////////////////////////////
    //                           Set Up                           //
    ////////////////////////////////////////////////////////////////

    function setUp() public {
        substratum = new Substratum();
    }

    ////////////////////////////////////////////////////////////////
    //                           Tests                            //
    ////////////////////////////////////////////////////////////////

    function test_name_succeeds() public {
        assertEq(substratum.name(), "Substratum");
    }
}
