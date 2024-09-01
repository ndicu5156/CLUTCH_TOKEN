# ICRC-1, ICRC-2, and ICRC-3 Fungible Token


## Overview

This project is a token implemented on the Internet Computer (IC) blockchain. It adheres to the ICRC1, ICRC2, ICRC3, and ICRC4 standards, offering functionalities like minting, burning, transfers, allowances, and transaction records.

## Contents
- `dfx.json`: Configuration file for project settings and canister definitions.
- `mops.toml`: Dependency management file listing various Motoko libraries and tools.
- `runners/test_deploy.sh`: Script for testing or deploying the token system.
- `runners/prod_deploy.sh`: Script for deploying to production token system.
- `src/Token.mo`: Source code for the token system written in Motoko.

## Key Features

- **Minting & Burning**: Create or destroy tokens.
- **Transfers**: Move tokens between accounts.
- **Allowances**: Approve and manage spending allowances.
- **Transaction Records**: Maintain a ledger of all transactions.

## Certification

Certified data management ensures trust and verification for token data across the IC network.

## Customization

The token's parameters, such as name, symbol, fees, and supply limits, can be customized during initialization.

