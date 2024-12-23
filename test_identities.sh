#!/bin/bash

# Create test identities
dfx identity new author_identity
dfx identity new buyer1_identity
dfx identity new buyer2_identity

# Print out their principals
echo "Author Identity Principal:"
dfx identity get-principal --identity author_identity

echo "Buyer 1 Identity Principal:"
dfx identity get-principal --identity buyer1_identity

echo "Buyer 2 Identity Principal:"
dfx identity get-principal --identity buyer2_identity