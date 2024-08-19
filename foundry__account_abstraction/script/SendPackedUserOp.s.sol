// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";

contract SendPackedUserOp is Script {
  function run() public {}

  function generateSignedPackedUserOp(bytes memory callData, address sender) public returns (PackedUserOperation memory) {
    uint256 nonce = vm.getNonce(sender);
    PackedUserOperation memory packedUserOp = _generateUnsignedPackedUserOp(callData, sender, nonce);
  }

  function _generateUnsignedPackedUserOp(bytes memory callData, address sender, uint256 nonce) internal pure returns (PackedUserOperation memory) {
    uint128 verificationGasLimit = 16777216;
    uint128 callGasLimit = verificationGasLimit;
    uint128 maxPriorityFeePerGas = 256;
    uint128 maxFeePerGas = maxPriorityFeePerGas;
    return PackedUserOperation({
      sender: sender,
      nonce: nonce,
      initCode: hex"",
      callData: callData,
      accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | uint256(callGasLimit)),
      preVerificationGas: verificationGasLimit,
      gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | uint256(maxFeePerGas)),
      paymasterAndData: hex"",
      signature: hex""
    });
  }
}