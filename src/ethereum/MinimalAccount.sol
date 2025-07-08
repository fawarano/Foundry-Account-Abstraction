//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAccount is IAccount, Ownable {
    ///////////////////////////////// ERRORS /////////////////////////

    error MinimalAccount__NotFromEntryPoint();
    error MinimalAccount__NotFromEntryPointOrOwner();
    error MinimalAccount__CallFailed(bytes);

    /////////////////////////////////  STATE VARIABLES /////////////////////////

    IEntryPoint private immutable i_entryPoint;

    ///////////////////////////////// MODIFIERS /////////////////////////

    modifier requireFromEntryPoint() {
        if (msg.sender != address(i_entryPoint)) {
            revert MinimalAccount__NotFromEntryPoint();
        }
        _;
    }

    modifier requireFromEntryPointOrOwner() {
        if (msg.sender != address(i_entryPoint) && msg.sender != owner()) {
            revert MinimalAccount__NotFromEntryPointOrOwner();
        }
        _;
    }

    ///////////////////////////////// FUNCTIONS /////////////////////////

    constructor(address entryPoint) Ownable(msg.sender) {
        i_entryPoint = IEntryPoint(entryPoint);
    }

    receive() external payable {}

    ////////////////////////////// EXTERNAL FUNCTIONS /////////////////////////

    /**
     *
     * @param dest destination address to call
     * @param value its value in wei to send with the call
     * @param functionData its the data to call the destination address with
     * @notice This function allows the account to execute a call to a destination address with a specified
     * value and function data. It can only be called by the EntryPoint or the owner of the account.
     * @dev If the call fails, it reverts with a MinimalAccount__CallFailed error, passing the result of the call.
     * The function uses a low-level call to execute the function on the destination address.
     * The value is sent with the call, and the function data is passed as calldata.
     */
    function execute(address dest, uint256 value, bytes calldata functionData) external requireFromEntryPointOrOwner {
        (bool success, bytes memory result) = dest.call{value: value}(functionData);
        if (!success) {
            revert MinimalAccount__CallFailed(result);
        }
    }

    /**
     * @notice Validates the user operation and pays the prefund if necessary.
     * @param userOp The packed user operation to validate.
     * @param userOpHash The hash of the user operation.
     * @param missingAccountFunds The amount of funds that are missing from the account.
     * @return validationData The validation data, which is 0 if the signature is valid, or 1 if it is invalid.
     */
    /// @dev This function is called by the EntryPoint to validate the user operation.
    /// It checks the signature of the user operation and pays the prefund if necessary.
    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        requireFromEntryPoint
        returns (uint256 validationData)
    {
        validationData = _validateSignature(userOp, userOpHash);
        // _validateNonce();
        _payPrefund(missingAccountFunds);
    }

    ////////////////////////// INTERNAL FUNCTIONS /////////////////////////

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success,) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}("");
            (success); // silence unused variable warning
        }
    }

    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);

        if (signer != owner()) {
            return SIG_VALIDATION_FAILED; //1
        }
        return SIG_VALIDATION_SUCCESS; // 0
    }

    /////////////////////////   GETTERS  /////////////////////////

    function getEntryPoint() external view returns (address) {
        return address(i_entryPoint);
    }
}
