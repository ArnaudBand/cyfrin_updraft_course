// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IAccount, ACCOUNT_VALIDATION_SUCCESS_MAGIC} from "foundry-era-contracts/contracts/interfaces/IAccount.sol";
import {
    Transaction, MemoryTransactionHelper
} from "foundry-era-contracts/contracts/libraries/MemoryTransactionHelper.sol";
import {SystemContractsCaller} from "foundry-era-contracts/contracts/libraries/SystemContractsCaller.sol";
import {
    NONCE_HOLDER_SYSTEM_CONTRACT,
    BOOTLOADER_FORMAL_ADDRESS,
    DEPLOYER_SYSTEM_CONTRACT
} from "foundry-era-contracts/contracts/Constants.sol";
import {INonceHolder} from "foundry-era-contracts/contracts/interfaces/INonceHolder.sol";
import {Utils} from "foundry-era-contracts/contracts/libraries/Utils.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * Lifecycle of a type 113 (0x71) transaction
 * msg.sender is the bootloader system contract
 *
 * Phase 1 Validation
 * 1. The user sends the transaction to the "zkSync API client" (sort of a "light node")
 * 2. The zkSync API client checks to see the the nonce is unique by querying the NonceHolder system contract
 * 3. The zkSync API client calls validateTransaction, which MUST update the nonce
 * 4. The zkSync API client checks the nonce is updated
 * 5. The zkSync API client calls payForTransaction, or prepareForPaymaster & validateAndPayForPaymasterTransaction
 * 6. The zkSync API client verifies that the bootloader gets paid
 *
 * Phase 2 Execution
 * 7. The zkSync API client passes the validated transaction to the main node / sequencer (as of today, they are the same)
 * 8. The main node calls executeTransaction
 * 9. If a paymaster was used, the postTransaction is called
 */
contract ZksyncMinimalAccount is IAccount, Ownable {
    using MemoryTransactionHelper for Transaction;

    // ERRORS
    error ZksyncMinimalAccount__NotEnoughBalanceToPayForTransaction();
    error ZksyncMinimalAccount__NotFromBootLoader();
    error ZksyncMinimalAccount__NotFromBootLoaderOrOwner();
    error ZkMinimalAccount__ExecutionFailed();
    error ZkMinimalAccount__TransactionFailed();

    // MODIFIERS
    modifier requireFromBootLoader() {
        if (msg.sender != BOOTLOADER_FORMAL_ADDRESS) {
            revert ZksyncMinimalAccount__NotFromBootLoader();
        }
        _;
    }

    modifier requireFromBootLoaderOrOwner() {
        if (msg.sender != BOOTLOADER_FORMAL_ADDRESS && msg.sender != owner()) {
            revert ZksyncMinimalAccount__NotFromBootLoaderOrOwner();
        }
        _;
    }

    // CONSTRUCTOR
    constructor() Ownable(msg.sender) {}

    // FALLBACK
    receive() external payable {}

    // EXTERNAL FUNCTIONS

    /**
     * @dev Validates a transaction
     * @notice must increase the nonce
     * @notice must validate the transation (Check the owner signed the transaction)
     * @notice must validate the transaction (Check the transaction is valid)
     * @notice Check it the owner have enough balance to pay for the transaction
     */
    function validateTransaction(bytes32, /*_txHash*/ bytes32, /*_suggestedSignedHash*/ Transaction memory _transaction)
        external
        payable
        requireFromBootLoader
        returns (bytes4 magic)
    {
        return _validateTransaction(_transaction);
    }

    function executeTransaction(bytes32, /*_txHash*/ bytes32, /*_suggestedSignedHash*/ Transaction memory _transaction)
        external
        payable
        requireFromBootLoaderOrOwner
    {
        _executeTransaction(_transaction);
    }

    function executeTransactionFromOutside(Transaction memory _transaction) external payable {
        bytes4 magic = _validateTransaction(_transaction);
        if (magic != ACCOUNT_VALIDATION_SUCCESS_MAGIC) {
            revert ZkMinimalAccount__TransactionFailed();
        }
        _executeTransaction(_transaction);
    }

    function payForTransaction(bytes32, /*_txHash*/ bytes32, /*_suggestedSignedHash*/ Transaction memory _transaction)
        external
        payable
    {
        bool success = _transaction.payToTheBootloader();
        if (!success) {
            revert ZkMinimalAccount__TransactionFailed();
        }
    }

    function prepareForPaymaster(bytes32 _txHash, bytes32 _possibleSignedHash, Transaction memory _transaction)
        external
        payable
    {}

    // INTERNAL FUNCTIONS

    function _validateTransaction(Transaction memory _transaction) internal returns (bytes4 magic) {
        // Call NonceHolder
        // Increase the nonce
        // Cal(z,x,v) -> call system contract
        SystemContractsCaller.systemCallWithPropagatedRevert(
            uint32(gasleft()),
            address(NONCE_HOLDER_SYSTEM_CONTRACT),
            0,
            abi.encodeCall(INonceHolder.incrementMinNonceIfEquals, _transaction.nonce)
        );

        // Check for fee to pay
        uint256 totalRequiredBalance = _transaction.totalRequiredBalance();
        if (totalRequiredBalance > address(this).balance) {
            revert ZksyncMinimalAccount__NotEnoughBalanceToPayForTransaction();
        }
        // Check for signature
        bytes32 txHash = _transaction.encodeHash();
        address signer = ECDSA.recover(txHash, _transaction.signature);
        bool isSigned = signer == owner();
        // return magic
        isSigned ? magic = ACCOUNT_VALIDATION_SUCCESS_MAGIC : magic = bytes4(0);
        return magic;
    }

    function _executeTransaction(Transaction memory _transaction) internal {
        address to = address(uint160(_transaction.to));
        uint128 value = Utils.safeCastToU128(_transaction.value);
        bytes memory data = _transaction.data;
        if (to == address(DEPLOYER_SYSTEM_CONTRACT)) {
            uint32 gas = Utils.safeCastToU32(gasleft());
            SystemContractsCaller.systemCallWithPropagatedRevert(gas, to, value, data);
        } else {
            bool success;
            assembly {
                success := call(gas(), to, value, add(data, 0x20), mload(data), 0, 0)
            }

            if (!success) {
                revert ZkMinimalAccount__ExecutionFailed();
            }
        }
    }
}
