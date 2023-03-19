// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Test } from "forge-std/Test.sol";
import { TestUtils } from "test/testutils/TestUtils.sol";
import { TestArithmetic } from "test/testutils/TestArithmetic.sol";
import { RLPWriterLib } from "src/lib/rlp/RLPWriterLib.sol";
import "src/types/Types.sol";
import "src/types/Errors.sol";

// TODO: Remove this once `vm.expectSafeMemory` is implemented in `forge-std`.
interface Cheats {
    function expectSafeMemory(uint64 _start, uint64 _end) external;
}

/// @notice Tests for the RLPReaderLib.library's RLPItem type helpers
contract RLPWriterLib_Test is Test {
    function _writeLength(uint256 _len, uint256 _offset) private pure returns (bytes memory) {
        bytes memory encoded;

        if (_len < 56) {
            encoded = new bytes(1);
            encoded[0] = bytes1(uint8(_len) + uint8(_offset));
        } else {
            uint256 lenLen;
            uint256 i = 1;
            while (_len / i != 0) {
                lenLen++;
                i *= 256;
            }

            encoded = new bytes(lenLen + 1);
            encoded[0] = bytes1(uint8(lenLen) + uint8(_offset) + 55);
            for (i = 1; i <= lenLen; i++) {
                encoded[i] = bytes1(uint8((_len / (256 ** (lenLen - i))) % 256));
            }
        }

        return encoded;
    }

    function testFuzzEquiv(uint8 _len, uint8 _offset) public {
        vm.assume(_len <= 127);
        vm.assume(_offset <= 127);
        vm.assume(_len + _offset < (256 - 60));
        assertEq(_writeLength(_len, _offset), RLPWriterLib._writeLength(_len, _offset));
    }
}
