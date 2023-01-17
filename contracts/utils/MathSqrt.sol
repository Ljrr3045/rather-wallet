//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
    @title MathSqrt Contract
    @author ljrr3045
    @notice Help contract, with multiple square root mathematical functions for solidity.
*/

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MathSqrt {

    using SafeMath for uint;

//Utility Functions

    /**
        @notice Function that calculates the most optimal amount to swap a pair of tokens.
        @dev It receives as a parameter the reserve amount of both tokens in the pool and returns the most
        optimal amount that should be swapped for tokenA.
    */
    function _getSwapAmount(uint r, uint a) internal pure returns (uint) {
        return (_sqrt(r.mul(r.mul(3988009) + a.mul(3988000))).sub(r.mul(1997))) / 1994;
    }

//Private Functions

    ///@notice Function to get the square root of a number.
    function _sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        }else if (y != 0) {
            z = 1;
        }
    }
}