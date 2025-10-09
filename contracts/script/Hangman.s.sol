// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Counter} from "../src/Counter.sol";
import {HonkVerifier} from '../src/Verifier.sol';
import {Hangman} from '../src/Hangman.sol';
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol' ;

contract CounterScript is Script {
    Counter public counter;
    HonkVerifier public verifier;
    Hangman public hangman;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        verifier = new HonkVerifier();
        hangman = new Hangman(verifier);

        
        string memory verifierMsg = string.concat("VERIFIER_ADDRESS=", Strings.toHexString(address(verifier)));
        console.logString(verifierMsg);
        string memory hangmanMsg = string.concat("HANGMAN_ADDRESS=", Strings.toHexString(address(verifier)));
        console.logString(hangmanMsg);

        string[] memory inputs = new string[](4);
        inputs[0] = "bash";
        inputs[1] = "prepare-webapp-env.sh";
        inputs[2] = Strings.toHexString(address(verifier));
        inputs[3] = Strings.toHexString(address(hangman));

        vm.ffi(inputs);
        vm.stopBroadcast();
    }
}
