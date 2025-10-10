#!/usr/bin/env bash

set -e

cast send $1 -r http://localhost:8545 --value=0.1ether --private-key=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
