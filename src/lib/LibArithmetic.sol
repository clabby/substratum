// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";


/// @title LibArithmetic
/// @notice General Math
library LibArithmetic {
    function clamp(
        int256 _value,
        int256 _min,
        int256 _max
    ) internal pure returns (int256) {
        int256 clampedMax = _value > _min ? _value : _min;
        int256 clampedMin =  clampedMax < _max ? clampedMax : _max;

        return clampedMin;
    }


    /// @notice (c)oefficient (d)enominator (exp)onentiation function.
    ///         Returns the result of: c * (1 - 1/d)^exp.
    ///
    /// @param _coefficient Coefficient of the function.
    /// @param _denominator Fractional denominator.
    /// @param _exponent    Power function exponent.
    ///
    /// @return Result of c * (1 - 1/d)^exp.
    function cdexp(
        int256 _coefficient,
        int256 _denominator,
        int256 _exponent
    ) internal pure returns (int256) {
        return
            (_coefficient *
                (FixedPointMathLib.powWad(1e18 - (1e18 / _denominator), _exponent * 1e18))) / 1e18;
    }
}
