// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MerkleAirdrop {
  // Some list of addresses
  // Allow some in the list to claim airdrop

  address[] claimers;
  bytes32 private immutable i_merkleRoot;
  IERC20 private immutable i_airdropToken;

  constructor(bytes32 merkleProofs, IERC20 token) {
    i_merkleRoot = merkleProofs;
    i_airdropToken = token;
  }
}