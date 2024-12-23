#!/bin/bash

# Ensure dfx is running
dfx start --background

# Create test identities
dfx identity new author_identity
dfx identity new buyer1_identity
dfx identity new buyer2_identity

# Deploy the canister
dfx deploy

# Switch to author identity and create a book
echo "Creating a book as author..."
dfx canister call book_nft createBook "(1, \"Web3 Basics\", \"John Doe\", principal \"$(dfx identity get-principal --identity author_identity)\", 100, 10, 10, 5)"

# Switch to buyer1 identity and buy an NFT
echo "Buying an NFT as buyer1..."
dfx identity use buyer1_identity
dfx canister call book_nft buyNFT "(1)"

# Set resale price
echo "Setting resale price as buyer1..."
dfx canister call book_nft setResalePrice "(1, 15)"

# Switch to buyer2 identity and buy the resale NFT
echo "Buying resale NFT as buyer2..."
dfx identity use buyer2_identity
BUYER1_PRINCIPAL=$(dfx identity get-principal --identity buyer1_identity)
dfx canister call book_nft buyResaleNFT "(1, principal \"$BUYER1_PRINCIPAL\")"

# Check book and NFT details
echo "Checking book details..."
dfx canister call book_nft getBook "(1)"

echo "Checking NFT purchase info..."
dfx canister call book_nft getNFTPurchaseInfo "(1)"

echo "Checking unique owners..."
dfx canister call book_nft getUniqueOwners "(1)"

# Stop dfx
dfx stop