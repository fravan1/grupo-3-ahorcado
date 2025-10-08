// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVerifier} from "./Verifier.sol";

contract Hangman is Ownable{
    IVerifier public verifier;
    bytes32 public word;

    event VerifierUpdated(IVerifier _newVerifier);

    constructor(IVerifier _verifier)Ownable(msg.sender){
        verifier = _verifier;
    }

    function setVerifier(IVerifier _newVerifier) external onlyOwner{
        verifier = _newVerifier;
        emit VerifierUpdated(_newVerifier);
    }


}