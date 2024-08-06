// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

contract BoxV2 {
    uint256 private value;

    // Emitted when the stored value changes
    event ValueChanged(uint256 newValue);

    // Stores a new value in the contract
    function store(uint256 newValue) external {
        value = newValue;
        emit ValueChanged(newValue);
    }

    // Reads the last stored value
    function getNumber() external view returns (uint256) {
        return value;
    }

    // Set the version to 2
    function version() public pure returns (uint256) {
        return 2;
    }
}
