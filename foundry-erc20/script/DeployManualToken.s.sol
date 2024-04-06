// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {ManualToken} from "../src/ManualToken.sol";

// Address of the Token: 0x31bCbbf289a3461eb822CCacA529C0971f00fAE7

contract DeployManualToken is Script {
    function run() external {
        vm.startBroadcast();
        new ManualToken();
        vm.stopBroadcast();
    }
}
