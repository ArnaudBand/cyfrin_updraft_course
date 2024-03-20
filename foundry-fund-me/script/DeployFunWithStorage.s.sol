// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {FunWithStorage} from "../src/exampleStorage/FunWithStorage.sol";

contract DeployFunWithStorage is Script {
    FunWithStorage public funWithStorage;
    function run() external returns(FunWithStorage) {
        vm.startBroadcast();
        funWithStorage  = new FunWithStorage();
        vm.stopBroadcast();
        printStorageData(address(funWithStorage));
        printFirstArrayElement(address(funWithStorage));
        return (funWithStorage);
    }

    function printStorageData(address contractAddress) public view {
        for (uint256 i = 0; i < 10; i++) {
            bytes32 value = vm.load(contractAddress, bytes32(i));
            console.log("Value at location", i, ":");
            console.logBytes32(value);
        }
    }

    function printFirstArrayElement(address _address) public view {
        bytes32 arrayStorageSlotLength = bytes32(uint256(2));
        bytes32 firstElementStorageSlot = keccak256(abi.encode(arrayStorageSlotLength));
        bytes32 value = vm.load(_address, firstElementStorageSlot);
        console.log("First Element in the array:");
        console.logBytes32(value);
    }
}
