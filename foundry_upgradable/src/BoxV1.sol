// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract BoxV1 {
    uint256 private value;

    // Gets the current value
    function getNumber() external view returns (uint256) {
        return value;
    }

    // Reads the last stored value
    function version() public pure returns (uint256) {
        return 1;
    }
}
