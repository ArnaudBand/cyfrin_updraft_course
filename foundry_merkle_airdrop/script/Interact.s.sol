// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {

  address public CLAAIM_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
  uint256 public CLAIM_AMOUNT = 25 * 1e18;
  bytes32 PROOF_ONE = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
  bytes32 PROOF_TWO = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
  bytes32[] public proof = [PROOF_ONE, PROOF_TWO];

  function claimAirdrop(address _merkleAirdrop) public {
    vm.startBroadcast();
    MerkleAirdrop(_merkleAirdrop).claim(CLAAIM_ADDRESS, CLAIM_AMOUNT, proof, v, r, s);
  }

  function run() external {
    address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("MerkeAirdrop", block.chainid);
    claimAirdrop(mostRecentDeployed);
  }
}