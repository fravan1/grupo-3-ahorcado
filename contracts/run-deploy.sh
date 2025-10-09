
set -e

HERE=$(dirname "$(realpath "$0")")

(
    cd $HERE &&
    forge script script/Hangman.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80  --disable-code-size-limit --ffi
)
