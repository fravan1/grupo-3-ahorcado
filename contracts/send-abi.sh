#!/usr/bin/env bash

set -e

if ! type jq >/dev/null 2>&1
then
  exit 0
fi

HERE=$(dirname "$(realpath "$0")")

mkdir -p $HERE/../webapp/src/abis
touch $HERE/../webapp/src/abis/hangman-abi.ts
echo -n "export const hangmanAbi = " > $HERE/../webapp/src/abis/hangman-abi.ts
cat out/Hangman.sol/Hangman.json | jq -j ".abi" >> $HERE/../webapp/src/abis/hangman-abi.ts
echo " as const;" >> $HERE/../webapp/src/abis/hangman-abi.ts
