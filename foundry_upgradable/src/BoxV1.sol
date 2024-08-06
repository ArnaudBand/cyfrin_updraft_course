// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract BoxV1 is UUPSUpgradeable {
    uint256 private value;

    constructor() {
        _disableInitializers();
    }

    // Gets the current value
    function getNumber() external view returns (uint256) {
        return value;
    }

    // Reads the last stored value
    function version() public pure returns (uint256) {
        return 1;
    }

    function _authorizeUpgrade(address) internal override {
        // This function is empty, but it is required to be implemented
    }
}
