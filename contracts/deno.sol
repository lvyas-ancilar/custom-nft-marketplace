// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

/**
 * @title OversizedContractDemo
 * @dev A demo contract designed to exceed the 24576 bytes limit when compiled 
 * without optimization, due to its large number of state variables and comments.
 */
contract OversizedContractDemo {
    // A large number of state variables to increase contract size
    uint256 public var1;
    uint256 public var2;
    uint256 public var3;
    // ... (imagine 100+ more variables here) ... 
    uint256 public var100;
    uint256 public var101;
    // ...
    uint256 public var200;

    // A large number of empty functions to add to the bytecode size
    function func1() public pure {}
    function func2() public pure {}
    // ... (imagine 50+ more functions here) ...
    function func50() public pure {}

    // A constructor
    constructor() {
        var1 = 1;
        // ... set other variables ...
    }

    // A function that is intentionally verbose with comments to bloat size
    function bloatedFunction() public pure returns (string memory) {
        // This function does nothing useful.
        // It merely contains a lot of text.
        // This is a comment line.
        // Another comment line.
        // Repeat this many times.
        // ... (many more comment lines) ...
        return "This contract is too big!";
    }
}
