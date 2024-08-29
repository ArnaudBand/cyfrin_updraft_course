// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IAccount} from "foundry-era-contracts/contracts/interfaces/IAccount.sol";
import {Transaction} from "foundry-era-contracts/contracts/libraries/MemoryTransactionHelper.sol";
import {SystemContractsCaller} from "foundry-era-contracts/contracts/libraries/SystemContractsCaller.sol";
import {NONCE_HOLDER_SYSTEM_CONTRACT} from "foundry-era-contracts/contracts/Constants.sol";
import {INonceHolder} from "foundry-era-contracts/contracts/interfaces/INonceHolder.sol";

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

contract ZksyncMinimalAccount is IAccount {

    // EXTERNAL FUNCTIONS

    /**
     * @dev Validates a transaction
     * @notice must increase the nonce
     * @notice must validate the transation (Check the owner signed the transaction)
     * @notice must validate the transaction (Check the transaction is valid)
     * @notice Check it the owner have enough balance to pay for the transaction
     */

    function validateTransaction(bytes32 /*_txHash*/, bytes32 /*_suggestedSignedHash*/, Transaction memory _transaction)
        external
        payable
        returns (bytes4 magic)
    {
        // Call NonceHolder
        // Increase the nonce
        // Cal(z,x,v) -> call system contract
        SystemContractsCaller.systemCallWithPropagatedRevert(
            uint32(gasleft()),
            address(NONCE_HOLDER_SYSTEM_CONTRACT),
            0,
            abi.encodeCall(
                INonceHolder.incrementMinNonceIfEquals,
                _transaction.nonce
            )
        );
    }
    

    function executeTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
        external
        payable
    {}

    function executeTransactionFromOutside(Transaction memory _transaction) external payable {}

    function payForTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
        external
        payable
    {}

    function prepareForPaymaster(bytes32 _txHash, bytes32 _possibleSignedHash, Transaction memory _transaction)
        external
        payable
    {}
}
