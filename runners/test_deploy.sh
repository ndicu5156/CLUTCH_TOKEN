set -ex

echo "Creating identities..."
dfx identity new alice --storage-mode=plaintext || true
dfx identity use alice
ALICE_PRINCIPAL=$(dfx identity get-principal)
echo "Alice Principal: $ALICE_PRINCIPAL"

dfx identity new bob --storage-mode=plaintext || true
dfx identity use bob
BOB_PRINCIPAL=$(dfx identity get-principal)
echo "Bob Principal: $BOB_PRINCIPAL"

dfx identity new charlie --storage-mode=plaintext || true
dfx identity use charlie
CHARLIE_PRINCIPAL=$(dfx identity get-principal)
echo "Charlie Principal: $CHARLIE_PRINCIPAL"

dfx identity new icrc_deployer --storage-mode=plaintext || true
dfx identity use icrc_deployer
ADMIN_PRINCIPAL=$(dfx identity get-principal)
echo "Admin Principal: $ADMIN_PRINCIPAL"

echo "Deploying canister..."
dfx deploy token --argument "(opt record {icrc1 = opt record {
  name = opt \"Tori Coin\";
  symbol = opt \"TCN\";
  logo = opt \"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMSIgaGVpZ2h0PSIxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbGw9InJlZCIvPjwvc3ZnPg==\";
  decimals = 8;
  fee = opt variant { Fixed = 10000};
  minting_account = opt record{
    owner = principal \"$ADMIN_PRINCIPAL\";
    subaccount = null;
  };
  max_supply = null;
  min_burn_amount = opt 10000;
  max_memo = opt 64;
  advanced_settings = null;
  metadata = null;
  fee_collector = null;
  transaction_window = null;
  permitted_drift = null;
  max_accounts = opt 100000000;
  settle_to_accounts = opt 99999000;
}; 
icrc2 = opt record{
  max_approvals_per_account = opt 10000;
  max_allowance = opt variant { TotalSupply = null};
  fee = opt variant { ICRC1 = null};
  advanced_settings = null;
  max_approvals = opt 10000000;
  settle_to_approvals = opt 9990000;
}; 
icrc3 = opt record {
  maxActiveRecords = 3000;
  settleToRecords = 2000;
  maxRecordsInArchiveInstance = 100000000;
  maxArchivePages = 62500;
  archiveIndexType = variant {Stable = null};
  maxRecordsToArchive = 8000;
  archiveCycles = 20_000_000_000_000;
  supportedBlocks = vec {};
  archiveControllers = null;
};
icrc4 = opt record {
  max_balances = opt 200;
  max_transfers = opt 200;
  fee = opt variant { ICRC1 = null};
};})" --mode reinstall

ICRC_CANISTER=$(dfx canister id token)
echo "ICRC Canister ID: $ICRC_CANISTER"

echo "Initializing canister..."
dfx canister call token admin_init

echo "Getting token details..."
dfx canister call token icrc1_name --query 
dfx canister call token icrc1_symbol --query 
dfx canister call token icrc1_decimals --query 
dfx canister call token icrc1_fee --query 
dfx canister call token icrc1_metadata --query 

echo "Minting tokens..."
dfx canister call token icrc1_transfer "(record { 
  memo = null; 
  created_at_time=null;
  from_subaccount = null;
  amount = 100000000000;
  to = record { 
    owner = principal \"$ALICE_PRINCIPAL\";
    subaccount = null;
  };
  fee = null
})"

echo "Getting token supply and balances..."
dfx canister call token icrc1_total_supply --query 
dfx canister call token icrc1_minting_account --query
dfx canister call token icrc1_supported_standards --query
dfx canister call token icrc1_balance_of "(record { 
  owner = principal \"$ALICE_PRINCIPAL\";
  subaccount = null;
})" --query

echo "Transferring tokens to Bob..."
dfx identity use alice
dfx canister call token icrc1_transfer "(record { 
  memo = null; 
  created_at_time=null;
  amount = 50000000000;
  from_subaccount = null;
  to = record { 
    owner = principal \"$BOB_PRINCIPAL\";
    subaccount = null;
  };
  fee = opt 10000;
})"

echo "Getting updated balances..."
dfx canister call token icrc1_balance_of "(record { 
  owner = principal \"$ALICE_PRINCIPAL\";
  subaccount = null;
})" --query
dfx canister call token icrc1_balance_of "(record { 
  owner = principal \"$BOB_PRINCIPAL\";
  subaccount = null;
})" --query

echo "Approving Alice to spend Bob's tokens..."
dfx identity use bob
dfx canister call token icrc2_approve "(record { 
  memo = null; 
  created_at_time=null;
  amount = 25000000000;
  from_subaccount = null;
  expected_allowance = null;
  expires_at = null;
  spender = record { 
    owner = principal \"$ALICE_PRINCIPAL\";
    subaccount = null;
  };
  fee = opt 10000;
})"

echo "Checking allowance..."
dfx canister call token icrc2_allowance "(record { 
  spender = record { 
    owner = principal \"$ALICE_PRINCIPAL\";
    subaccount = null;
  };
  account = record { 
    owner = principal \"$BOB_PRINCIPAL\";
    subaccount = null;
  };
  })" --query

echo "Alice spending Bob's tokens to Charlie..."
dfx identity use alice
dfx canister call token icrc2_transfer_from "(record { 
  memo = null; 
  created_at_time=null;
  amount = 12500000000;
  spender_subaccount = null;
  to = record { 
    owner = principal \"$CHARLIE_PRINCIPAL\";
    subaccount = null;
  };
  from = record { 
    owner = principal \"$BOB_PRINCIPAL\";
    subaccount = null;
  };
  fee = opt 10000;
})"

echo "Getting updated balances..."
dfx canister call token icrc1_balance_of "(record { 
  owner = principal \"$ALICE_PRINCIPAL\";
  subaccount = null;
})" --query
dfx canister call token icrc1_balance_of "(record { 
  owner = principal \"$BOB_PRINCIPAL\";
  subaccount = null;
})" --query
dfx canister call token icrc1_balance_of "(record { 
  owner = principal \"$CHARLIE_PRINCIPAL\";
  subaccount = null;
})" --query

echo "Bob burning tokens..."
dfx identity use bob
dfx canister call token icrc1_transfer "(record { 
  memo = null; 
  created_at_time=null;
  amount = 100000000;
  from_subaccount = null;
  to = record { 
    owner = principal \"$ADMIN_PRINCIPAL\";
    subaccount = null;
  };
  fee = opt 10000;
})"

echo "Revoking approval..."
dfx canister call token icrc2_approve "(record { 
  memo = null; 
  created_at_time=null;
  amount = 0;
  from_subaccount = null;
  expected_allowance = null;
  expires_at = null;
  spender = record { 
    owner = principal \"$ALICE_PRINCIPAL\";
    subaccount = null;
  };
  fee = opt 10000;
})"

echo "Checking if approval is removed..."
dfx canister call token icrc2_allowance "(record { 
  spender = record { 
    owner = principal \"$ALICE_PRINCIPAL\";
    subaccount = null;
  };
  account = record { 
    owner = principal \"$BOB_PRINCIPAL\";
    subaccount = null;
  };
  })" --query

echo "Getting ledger blocks..."
dfx canister call token icrc3_get_blocks "(vec {record { start = 0; length = 1000}})" --query

echo "Getting archive log..."
dfx canister call token icrc3_get_archives "(record {from = null})" --query

echo "Getting tip certificate..."
dfx canister call token icrc3_get_tip_certificate --query
