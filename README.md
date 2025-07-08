# Foundry Account Abstraction Project

A comprehensive implementation of Account Abstraction (ERC-4337) for both Ethereum and zkSync networks, featuring minimal smart contract wallets with signature validation and transaction execution capabilities.

## 📄 Author : Fawarano

## 📋 Table of Contents

-   [Overview](#overview)
-   [Project Structure](#project-structure)
-   [Features](#features)
-   [Smart Contracts](#smart-contracts)
-   [Scripts](#scripts)
-   [Testing](#testing)
-   [Installation & Setup](#installation--setup)
-   [Usage](#usage)
-   [Networks Supported](#networks-supported)
-   [Security Considerations](#security-considerations)

## 🔍 Overview

This project implements two different Account Abstraction solutions:

1. **Ethereum Account Abstraction** - Compatible with ERC-4337 standard using EntryPoint contracts
2. **zkSync Account Abstraction** - Native account abstraction using zkSync's system contracts

Both implementations provide minimal smart contract wallets that can execute transactions on behalf of users while maintaining security through signature validation.

## 📁 Project Structure

```
foundry-account-abstraction/
├── src/
│   ├── ethereum/
│   │   └── MinimalAccount.sol          # ERC-4337 compatible account
│   └── zksync/
│       └── ZkMinimalAccount.sol        # zkSync native account
├── script/
│   ├── DeployMinimal.s.sol            # Deployment script
│   ├── HelperConfig.s.sol             # Network configurations
│   └── SendPackedUserOp.s.sol         # UserOperation generation
└── test/
    ├── ethereum/
    │   └── MinimalAccountTest.t.sol    # Ethereum account tests
    └── zksync/
        └── ZkSyncMinimalAccountTest.sol # zkSync account tests
```

## ✨ Features

### Ethereum Implementation

-   **ERC-4337 Compliance**: Full compatibility with Account Abstraction standard
-   **Signature Validation**: ECDSA signature verification using OpenZeppelin
-   **Gas Sponsorship**: Support for missing account funds payment
-   **Secure Execution**: Protected transaction execution with proper access controls
-   **EntryPoint Integration**: Works with standard EntryPoint contracts

### zkSync Implementation

-   **Native AA Support**: Leverages zkSync's built-in account abstraction
-   **System Contract Integration**: Uses zkSync system contracts for validation
-   **Transaction Lifecycle**: Complete support for zkSync transaction phases
-   **Paymaster Support**: Built-in paymaster functionality preparation
-   **Bootloader Compatibility**: Proper integration with zkSync bootloader

## 🔧 Smart Contracts

### MinimalAccount.sol (Ethereum)

The main Ethereum account abstraction contract implementing `IAccount` interface.

**Key Functions:**

-   `validateUserOp()`: Validates user operations and handles prefunding
-   `execute()`: Executes transactions with proper authorization
-   `_validateSignature()`: Internal signature validation using ECDSA
-   `_payPrefund()`: Handles missing account funds payment

**Access Controls:**

-   `requireFromEntryPoint`: Only EntryPoint can call validation functions
-   `requireFromEntryPointOrOwner`: EntryPoint or owner can execute transactions

### ZkMinimalAccount.sol (zkSync)

The zkSync account abstraction contract implementing `IAccount` interface.

**Key Functions:**

-   `validateTransaction()`: Validates transactions and updates nonces
-   `executeTransaction()`: Executes validated transactions
-   `executeTransactionFromOutside()`: External transaction execution
-   `payForTransaction()`: Handles transaction fee payments

**Transaction Lifecycle:**

1. **Validation Phase**: Transaction validation and nonce updates
2. **Payment Phase**: Fee payment to bootloader
3. **Execution Phase**: Transaction execution

## 📜 Scripts

### DeployMinimal.s.sol

Deployment script for the MinimalAccount contract.

**Features:**

-   Automatic network detection
-   EntryPoint configuration
-   Ownership transfer to configured account

### HelperConfig.s.sol

Network configuration management for different chains.

**Supported Networks:**

-   **Ethereum Sepolia** (Chain ID: 11155111)
-   **zkSync** (Chain ID: 300)
-   **Local Anvil** (Chain ID: 31337)

**Configuration Structure:**

```solidity
struct NetworkConfig {
    address entryPoint;  // EntryPoint contract address
    address account;     // Account owner/signer address
}
```

### SendPackedUserOp.s.sol

UserOperation generation and signing utilities.

**Key Functions:**

-   `generateSignedUserOperation()`: Creates and signs UserOperations
-   `_generateUnsignedUserOperation()`: Generates unsigned UserOperation structure

**Signature Process:**

1. Generate unsigned UserOperation
2. Get UserOperation hash from EntryPoint
3. Apply Ethereum signed message hash format
4. Sign with appropriate private key
5. Encode signature in correct format (r, s, v)

## 🧪 Testing

### MinimalAccountTest.t.sol

Comprehensive test suite for Ethereum implementation.

**Test Cases:**

-   `testOwnerCanExecuteCommands()`: Owner transaction execution
-   `testNonOwnerCannotExecuteCommands()`: Access control validation
-   `testRecoverSignedOp()`: Signature recovery verification
-   `testValidationOfUserOp()`: UserOperation validation
-   `testEntryPointCanExecuteCommands()`: EntryPoint transaction execution

### ZkSyncMinimalAccountTest.sol

Test suite for zkSync implementation.

**Test Cases:**

-   `testZkOwnerCanExecuteCommands()`: Owner transaction execution
-   `testZkValidateTransaction()`: Transaction validation on zkSync

**Helper Functions:**

-   `_createUnsignedTransaction()`: Creates unsigned zkSync transactions
-   `_signTransaction()`: Signs transactions for zkSync

## 🚀 Installation & Setup

### Prerequisites

-   [Foundry](https://getfoundry.sh/)
-   [Git](https://git-scm.com/)

### Installation

```bash
git clone <repository-url>
cd foundry-account-abstraction
forge install
forge build
```

### Environment Setup

Create a `.env` file:

```bash
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
PRIVATE_KEY=your_private_key_here
ETHERSCAN_API_KEY=your_etherscan_api_key
```

## 📖 Usage

### Deploy MinimalAccount

```bash
# Deploy to local network
forge script script/DeployMinimal.s.sol:DeployMinimal --fork-url http://localhost:8545 --broadcast

# Deploy to Sepolia
forge script script/DeployMinimal.s.sol:DeployMinimal --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

### Run Tests

```bash
# Run all tests
forge test

# Run Ethereum tests only
forge test --match-contract MinimalAccountTest

# Run zkSync tests only
forge test --match-contract ZkSyncMinimalAccountTest
```

### Generate UserOperations

```solidity
// Example usage in script
SendPackedUserOp sendPackedUserOp = new SendPackedUserOp();
HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

bytes memory callData = abi.encodeWithSelector(
    MinimalAccount.execute.selector,
    target,
    value,
    functionData
);

PackedUserOperation memory userOp = sendPackedUserOp.generateSignedUserOperation(
    callData,
    config,
    address(minimalAccount)
);
```

## 🌐 Networks Supported

| Network          | Chain ID | EntryPoint                                 | Status       |
| ---------------- | -------- | ------------------------------------------ | ------------ |
| Ethereum Sepolia | 11155111 | 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789 | ✅ Supported |
| zkSync Era       | 300      | Native AA                                  | ✅ Supported |
| Local Anvil      | 31337    | Deployed locally                           | ✅ Supported |

## 🔒 Security Considerations

### Access Controls

-   **EntryPoint Only**: Critical functions restricted to EntryPoint calls
-   **Owner Authorization**: Owner can execute transactions directly
-   **Signature Validation**: All operations require valid ECDSA signatures

### Gas Management

-   **Prefunding**: Automatic handling of missing account funds
-   **Gas Limits**: Configurable gas limits for different operations
-   **Reentrancy**: Protected against reentrancy attacks

### Signature Security

-   **EIP-191 Format**: Uses Ethereum signed message hash format
-   **ECDSA Recovery**: Secure signature recovery and validation
-   **Nonce Management**: Prevents replay attacks through nonce tracking

## 🛠 Configuration Details

### Gas Configuration

```solidity
uint128 verificationGasLimit = 16777216;
uint128 callGasLimit = 16777216;
uint128 maxPriorityFeePerGas = 256;
uint128 maxFeePerGas = 256;
```

### Default Accounts

-   **Anvil Default**: `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`
-   **Burner Wallet**: `0x1D6ecDBE476212961a768aF7c28DA264070ed5f1`

## 📝 Notes

-   The project uses OpenZeppelin libraries for cryptographic operations
-   Both implementations support ERC-20 token interactions
-   zkSync implementation includes paymaster preparation for future enhancements
-   All contracts are thoroughly tested with comprehensive test suites
-   The project follows Foundry best practices for smart contract development

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.
# Foundry-Account-Abstraction

