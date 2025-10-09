#!/usr/bin/env bash

set -e

HERE=$(dirname "$(realpath "$0")")

TARGET_DIR="$HERE/target"
CIRCUIT_NAME=hangman

nargo test

rm -r $TARGET_DIR

nargo build
bb write_vk -b $TARGET_DIR/$CIRCUIT_NAME.json -o $TARGET_DIR
bb write_solidity_verifier -k $TARGET_DIR/vk -o $HERE/../contracts/src/Verifier.sol

mkdir -p $HERE/../webapp/src/circuits/
cp $TARGET_DIR/$CIRCUIT_NAME.json $HERE/../webapp/src/circuits/$CIRCUIT_NAME.json
