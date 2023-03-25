// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Test } from "forge-std/Test.sol";
import { TestUtils } from "test/testutils/TestUtils.sol";
import { TestArithmetic } from "test/testutils/TestArithmetic.sol";
import { RLPReaderLib } from "src/lib/rlp/RLPReaderLib.sol";
import "src/types/Types.sol";
import "src/types/Errors.sol";

/// @notice Tests for the RLPReaderLib.library's RLPItem type helpers
/// @dev Legacy tests from `contracts-bedrock`
contract RLPReaderLib_RLPItemType_Test is Test {
    /// @dev Tests that the `wrapRLPItem` and `unwrapRLPItem` functions work as expected.
    function testFuzz_wrapUnwrapRLPItem_succeeds(MemoryPointer _ptr, uint232 _len) external {
        RLPItem item = RLPReaderLib.wrapRLPItem(_ptr, _len);
        (MemoryPointer _unwrappedPtr, uint232 _unwrappedLen) = RLPReaderLib.unwrapRLPItem(item);
        assertEq(MemoryPointer.unwrap(_unwrappedPtr), MemoryPointer.unwrap(_ptr));
        assertEq(_unwrappedLen, _len);
    }

    /// @dev Tests that the `toRLPItem` function works as expected.
    function testFuzz_toRLPItem_succeeds(bytes memory _in) external {
        // If the input is empty, expect a revert.
        if (_in.length == 0) {
            vm.expectRevert(RLPItemEmpty.selector);
        }

        // Convert the `_in` bytes to an RLPItem type.
        RLPItem item = RLPReaderLib.toRLPItem(_in);

        // Grab the pointer and length of the `_in` bytes.
        MemoryPointer ptr;
        assembly {
            ptr := add(_in, 0x20)
        }
        uint232 len = uint232(_in.length);

        // Check that the pointer and length of the RLPItem match the pointer and length of the input.
        (MemoryPointer _unwrappedPtr, uint232 _unwrappedLen) = RLPReaderLib.unwrapRLPItem(item);
        assertEq(MemoryPointer.unwrap(_unwrappedPtr), MemoryPointer.unwrap(ptr));
        assertEq(_unwrappedLen, len);
    }
}

/// @notice Tests for the RLPReaderLib.library's `readBytes` function.
/// @dev Legacy tests from `contracts-bedrock`
contract RLPReaderLib_readBytes_Test is Test {
    /// @dev Tests that the `readBytes` function returns the correct value for
    ///      a "00" byte string.
    function test_readBytes_bytestring00_succeeds() external {
        assertEq(RLPReaderLib.readBytes(hex"00"), hex"00");
    }

    /// @dev Tests that the `readBytes` function returns the correct value for
    ///      a "01" byte string.
    function test_readBytes_bytestring01_succeeds() external {
        assertEq(RLPReaderLib.readBytes(hex"01"), hex"01");
    }

    /// @dev Tests that the `readBytes` function returns the correct value for
    ///      a "7f" byte string.
    function test_readBytes_bytestring7f_succeeds() external {
        assertEq(RLPReaderLib.readBytes(hex"7f"), hex"7f");
    }

    /// @dev Tests that the `readBytes` function reverts if it is passed an
    ///      RLPItem that is not a data item.
    function test_readBytes_revertListItem_reverts() external {
        vm.expectRevert(RLPNotADataItem.selector);
        RLPReaderLib.readBytes(hex"c7c0c1c0c3c0c1c0");
    }

    /// @dev Tests that the `readBytes` function reverts if it is passed an
    ///      RLPItem that has an invalid string length.
    function test_readBytes_invalidStringLength_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readBytes(hex"b9");
    }

    /// @dev Tests that the `readBytes` function reverts if it is passed an
    ///      RLPItem that has an invalid list length.
    function test_readBytes_invalidListLength_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readBytes(hex"ff");
    }

    /// @dev Tests that the `readBytes` function reverts if it is passed an
    ///      RLPItem that has an invalid data remainder.
    function test_readBytes_invalidRemainder_reverts() external {
        vm.expectRevert(RLPInvalidDataRemainder.selector);
        RLPReaderLib.readBytes(hex"800a");
    }

    /// @dev Tests that the `readBytes` function reverts if it is passed an
    ///      RLPItem that has an invalid prefix.
    function test_readBytes_invalidPrefix_reverts() external {
        vm.expectRevert(RLPInvalidPrefix.selector);
        RLPReaderLib.readBytes(hex"810a");
    }
}

/// @notice Tests for the RLPReaderLib.library's `readList` function.
/// @dev Legacy tests from `contracts-bedrock`
contract RLPReaderLib_readList_Test is Test {
    /// @dev Tests that the `readList` function returns the correct value for
    ///      an empty list.
    function test_readList_empty_succeeds() external {
        RLPItem[] memory list = RLPReaderLib.readList(hex"c0");
        assertEq(list.length, 0);
    }

    /// @dev Tests that the `readList` function returns the correct value for
    ///      a list with multiple items.
    function test_readList_multiList_succeeds() external {
        RLPItem[] memory list = RLPReaderLib.readList(hex"c6827a77c10401");
        assertEq(list.length, 3);

        assertEq(RLPReaderLib.readRawBytes(list[0]), hex"827a77");
        assertEq(RLPReaderLib.readRawBytes(list[1]), hex"c104");
        assertEq(RLPReaderLib.readRawBytes(list[2]), hex"01");
    }

    /// @dev Tests that the `readList` function returns the correct value for
    ///      a short list with 11 items.
    function test_readList_shortListMax1_succeeds() external {
        RLPItem[] memory list = RLPReaderLib.readList(
            hex"f784617364668471776572847a78637684617364668471776572847a78637684617364668471776572847a78637684617364668471776572"
        );

        assertEq(list.length, 11);
        assertEq(RLPReaderLib.readRawBytes(list[0]), hex"8461736466");
        assertEq(RLPReaderLib.readRawBytes(list[1]), hex"8471776572");
        assertEq(RLPReaderLib.readRawBytes(list[2]), hex"847a786376");
        assertEq(RLPReaderLib.readRawBytes(list[3]), hex"8461736466");
        assertEq(RLPReaderLib.readRawBytes(list[4]), hex"8471776572");
        assertEq(RLPReaderLib.readRawBytes(list[5]), hex"847a786376");
        assertEq(RLPReaderLib.readRawBytes(list[6]), hex"8461736466");
        assertEq(RLPReaderLib.readRawBytes(list[7]), hex"8471776572");
        assertEq(RLPReaderLib.readRawBytes(list[8]), hex"847a786376");
        assertEq(RLPReaderLib.readRawBytes(list[9]), hex"8461736466");
        assertEq(RLPReaderLib.readRawBytes(list[10]), hex"8471776572");
    }

    /// @dev Tests that the `readList` function returns the correct value for
    ///      a long list with 4 items.
    function test_readList_longList1_succeeds() external {
        RLPItem[] memory list = RLPReaderLib.readList(
            hex"f840cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376"
        );

        assertEq(list.length, 4);
        assertEq(RLPReaderLib.readRawBytes(list[0]), hex"cf84617364668471776572847a786376");
        assertEq(RLPReaderLib.readRawBytes(list[1]), hex"cf84617364668471776572847a786376");
        assertEq(RLPReaderLib.readRawBytes(list[2]), hex"cf84617364668471776572847a786376");
        assertEq(RLPReaderLib.readRawBytes(list[3]), hex"cf84617364668471776572847a786376");
    }

    /// @dev Tests that the `readList` function returns the correct value for
    ///      a long list with 32 items.
    function test_readList_longList2_succeeds() external {
        RLPItem[] memory list = RLPReaderLib.readList(
            hex"f90200cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376"
        );
        assertEq(list.length, 32);

        for (uint256 i = 0; i < 32; i++) {
            assertEq(RLPReaderLib.readRawBytes(list[i]), hex"cf84617364668471776572847a786376");
        }
    }

    /// @dev Tests that the `readList` function reverts when the list is longer
    ///      than 32 items.
    function test_readList_listLongerThan32Elements_reverts() external {
        vm.expectRevert(RLPListTooLong.selector);
        RLPReaderLib.readList(hex"e1454545454545454545454545454545454545454545454545454545454545454545");
    }

    /// @dev Tests that the `readList` function returns the correct value when
    ///      passed a list of lists.
    function test_readList_listOfLists_succeeds() external {
        RLPItem[] memory list = RLPReaderLib.readList(hex"c4c2c0c0c0");
        assertEq(list.length, 2);
        assertEq(RLPReaderLib.readRawBytes(list[0]), hex"c2c0c0");
        assertEq(RLPReaderLib.readRawBytes(list[1]), hex"c0");
    }

    /// @dev Tests that the `readList` function returns the correct value when
    ///      passed a list of lists.
    function test_readList_listOfLists2_succeeds() external {
        RLPItem[] memory list = RLPReaderLib.readList(hex"c7c0c1c0c3c0c1c0");
        assertEq(list.length, 3);

        assertEq(RLPReaderLib.readRawBytes(list[0]), hex"c0");
        assertEq(RLPReaderLib.readRawBytes(list[1]), hex"c1c0");
        assertEq(RLPReaderLib.readRawBytes(list[2]), hex"c3c0c1c0");
    }

    /// @dev Tests that the `readList` function returns the correct value when
    ///      passed a dictionary (array of key/value pairs)
    function test_readList_dictTest1_succeeds() external {
        RLPItem[] memory list = RLPReaderLib.readList(
            hex"ecca846b6579318476616c31ca846b6579328476616c32ca846b6579338476616c33ca846b6579348476616c34"
        );
        assertEq(list.length, 4);

        assertEq(RLPReaderLib.readRawBytes(list[0]), hex"ca846b6579318476616c31");
        assertEq(RLPReaderLib.readRawBytes(list[1]), hex"ca846b6579328476616c32");
        assertEq(RLPReaderLib.readRawBytes(list[2]), hex"ca846b6579338476616c33");
        assertEq(RLPReaderLib.readRawBytes(list[3]), hex"ca846b6579348476616c34");
    }

    /// @dev Tests that the `readList` function reverts when passed a short list
    ///      with an invalid content length.
    function test_readList_invalidShortList_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"efdebd");
    }

    /// @dev Tests that the `readList` function reverts when passed a long string
    ///      with an invalid content length.
    function test_readList_longStringLength_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"efb83600");
    }

    /// @dev Tests that the `readList` function reverts when passed a list that is
    ///      not long enough.
    function test_readList_notLongEnough_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"efdebdaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    }

    function test_readList_int32Overflow_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"bf0f000000000000021111");
    }

    function test_readList_int32Overflow2_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"ff0f000000000000021111");
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      begins with a leading zero.
    function test_readList_incorrectLengthInArray_reverts() external {
        vm.expectRevert(RLPNoLeadingZeros.selector);
        RLPReaderLib.readList(hex"b9002100dc2b275d0f74e8a53e6f4ec61b27f24278820be3f82ea2110e582081b0565df0");
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      begins with a leading zero.
    function test_readList_leadingZerosInLongLengthArray1_reverts() external {
        vm.expectRevert(RLPNoLeadingZeros.selector);
        RLPReaderLib.readList(
            hex"b90040000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f"
        );
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      begins with a leading zero.
    function test_readList_leadingZerosInLongLengthArray2_reverts() external {
        vm.expectRevert(RLPNoLeadingZeros.selector);
        RLPReaderLib.readList(hex"b800");
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      begins with a leading zero.
    function test_readList_leadingZerosInLongLengthList1_reverts() external {
        vm.expectRevert(RLPNoLeadingZeros.selector);
        RLPReaderLib.readList(
            hex"fb00000040000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f"
        );
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      has an invalid length.
    function test_readList_nonOptimalLongLengthArray1_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"b81000112233445566778899aabbccddeeff");
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      has an invalid length.
    function test_readList_nonOptimalLongLengthArray2_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"b801ff");
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      has an invalid length.
    function test_readList_invalidValue_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"91");
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      has an invalid data remainder.
    function test_readList_invalidRemainder_reverts() external {
        vm.expectRevert(RLPInvalidDataRemainder.selector);
        RLPReaderLib.readList(hex"c000");
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      has an invalid content length.
    function test_readList_notEnoughContentForString1_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"ba010000aabbccddeeff");
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      has an invalid content length.
    function test_readList_notEnoughContentForString2_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"b840ffeeddccbbaa99887766554433221100");
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      has an invalid content length.
    function test_readList_notEnoughContentForList1_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"f90180");
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      has an invalid content length.
    function test_readList_notEnoughContentForList2_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"ffffffffffffffffff0001020304050607");
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      has an invalid content length.
    function test_readList_longStringLessThan56Bytes_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"b80100");
    }

    /// @dev Tests that the `readList` function reverts when passed a list that
    ///      has an invalid content length.
    function test_readList_longListLessThan56Bytes_reverts() external {
        vm.expectRevert(RLPInvalidContentLength.selector);
        RLPReaderLib.readList(hex"f80100");
    }

    /// @dev Tests that the `readList` function is memory safe.
    /// TODO: Strengthen this test
    function test_readList_memorySafety_succeeds() external {
        bytes memory listBytes =
            hex"f840cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376";

        // Get the free memory pointer before calling `readList`
        MemoryPointer ptr = TestUtils.getFreeMemoryPtr();
        // Compute the expected free memory pointer after calling `readList`
        MemoryPointer expectedPtr = MemoryPointer.wrap(MemoryPointer.unwrap(ptr) + 0x20 + 0x80); // ptr + 0x20 (length) + 0x80 (data)

        // Expect the memory between the current free memory pointer and the expected free memory pointer to be touched
        vm.expectSafeMemory(MemoryPointer.unwrap(ptr), MemoryPointer.unwrap(expectedPtr));

        RLPReaderLib.readList(listBytes);

        MemoryPointer newPtr = TestUtils.getFreeMemoryPtr();

        // Check that the free memory pointer was properly updated
        assertEq(MemoryPointer.unwrap(newPtr), MemoryPointer.unwrap(expectedPtr));
    }
}
