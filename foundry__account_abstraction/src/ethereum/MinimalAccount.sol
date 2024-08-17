// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {IAccount} from "account-abstraction/interfaces/IAccount.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "account-abstraction/core/Helpers.sol";

contract MinimalAccount is IAccount, Ownable {

  error MinimalAccount__FailedToPayPreFund();
    constructor() Ownable(msg.sender) {}

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        returns (uint256 validationData)
    {
       validationData = _validateSignature(userOp, userOpHash);
       _payPreFund(missingAccountFunds);
    }

    // EIP191 version of the signed message hash
    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash) internal view returns (uint256 validatiionData) {
      bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
      address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);
      if (signer != owner()) {
        return SIG_VALIDATION_FAILED;
      }
      return SIG_VALIDATION_SUCCESS;
    }

    function _payPreFund(uint256 missingAccountFunds) internal {
      if (missingAccountFunds > 0) {
        (bool success, ) = msg.sender.call{value: missingAccountFunds, gas: type(uint256).max}("");
        if (!success) {
          revert MinimalAccount__FailedToPayPreFund();
        }
      }
    }
}
