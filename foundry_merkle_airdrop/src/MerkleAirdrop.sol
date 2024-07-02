// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    // Some list of addresses
    // Allow some in the list to claim airdrop

    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    mapping(address claimer => bool claimed) private s_hasClaimed;

    event Claim(address indexed account, uint256 amount);

    constructor(bytes32 merkleProofs, IERC20 token) {
        i_merkleRoot = merkleProofs;
        i_airdropToken = token;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        // Check if the account has already claimed
        if (s_hasClaimed[account]) revert MerkleAirdrop__AlreadyClaimed(); // If the account has already claimed, revert

        // Calculate using the account and the amount, the hash -> leaf node
        bytes32 node = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        // Verify the proof
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, node)) revert MerkleAirdrop__InvalidProof(); // If the proof is invalid, revert

        // Mark the account as claimed
        s_hasClaimed[account] = true;
        // Emit the claim event
        emit Claim(account, amount);
        // Transfer the amount to the account
        i_airdropToken.safeTransfer(account, amount);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
