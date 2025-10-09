#!/usr/bin/env bash

set -e

HERE=$(dirname "$(realpath "$0")")
TARGET_DOTENV="$HERE/../webapp/.env"


touch $TARGET_DOTENV

echo "VITE_VERIFIER_ADDRESS=$1" > $TARGET_DOTENV
echo "VITE_HANGMAN_ADDRESS=$2" >> $TARGET_DOTENV