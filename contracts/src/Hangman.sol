// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVerifier} from "./Verifier.sol";
import "./HangmanStructs.sol";

contract Hangman is Ownable{
    IVerifier public verifier;
    mapping (uint256 => Game) public games;
    uint256 public gameCounter;

    event VerifierUpdated(IVerifier _newVerifier);
    event GameCreated(uint256 indexed gameId, address indexed player1, uint8 wordLength);
    event GameStarted(uint256 indexed gameId, address indexed player1, address indexed player2);
    event GuessSubmitted(uint256 indexed gameId, address indexed guesser, bytes1 letter);
    event ProofVerified(uint256 indexed gameId, address indexed prover, bool isCorrect, uint256[] positions);
    event GameFinished(uint256 indexed gameId, address indexed winner, string reason);

    constructor(IVerifier _verifier)Ownable(msg.sender){
        verifier = _verifier;
    }

    function setVerifier(IVerifier _newVerifier) external onlyOwner{
        verifier = _newVerifier;
        emit VerifierUpdated(_newVerifier);
    }

    /**
     * @notice Create a new game with a secret word
     * @param _wordCommitment Hash of the secret word (keccak256(abi.encodePacked(word, salt))) ??
     * @param _wordLength Length of the secret word
     */
    function createGame(bytes32 _wordCommitment, uint8 _wordLength) external{
        uint256 gameId = gameCounter++;

        emit GameCreated(gameId,msg.sender,_wordLength);
    }

    /**
     * @notice Join an existing game with your own secret word
     * @param _gameId The game to join
     * @param _wordCommitment Hash of your secret word
     * @param _wordLength Length of your secret word
     */
    function joinGame(uint256 _gameId, bytes32 _wordCommitment, uint8 _wordLength) external{}

    /**
     * @notice Submit a letter guess for your opponent's word
     * @param _gameId The game ID
     * @param _letter The letter to guess (lowercase a-z)
     */
    function submitGuess(uint256 _gameId, bytes1 _letter) external{}

    /**
     * @notice Submit a zero-knowledge proof for an opponent's guess
     * @param _gameId The game ID
     * @param _proof The ZK proof from Noir circuit
     * @param _letterPositions Array indicating where the letter appears (1-indexed, 0 = not present)
     * @param _isCorrect Whether the guess was correct
     */
    function submitProof(
        uint256 _gameId, 
        bytes calldata _proof,
        uint256[] calldata _letterPositions,
        bool _isCorrect
    ) external{}

    /**
     * @notice Claim victory if opponent hasn't responded within timeout
     * @param _gameId The game ID
     */
    function claimTimeout(uint256 _gameId) external{}

    // ============================================
    // INTERNAL FUNCTIONS
    // ============================================
    /**
     * @notice Check if the game has been won
     * @param _gameId The game ID
     */
    function _checkWinConditions(uint256 _gameId) internal {
        //emit GameFinished()
    }

    // ============================================
    // VIEW FUNCTIONS
    // ============================================
    /**
     * @notice Get the current state of a game
     * @param _gameId The game ID
     */
    function getGameState(uint256 _gameId) external view returns (
        address player1,
        address player2,
        GameStatus status,
        address winner,
        uint8 player1WordLength,
        uint8 player2WordLength,
        uint8 player1WrongGuesses,
        uint8 player2WrongGuesses
    ) {
        Game storage game = games[_gameId];
        return (
            game.player1,
            game.player2,
            game.status,
            game.winner,
            game.player1State.wordLength,
            game.player2State.wordLength,
            game.player1State.wrongGuesses,
            game.player2State.wrongGuesses
        );
    }

    /**
     * @notice Get revealed letters for a player's word
     * @param _gameId The game ID
     * @param _playerNum 1 for player1's word, 2 for player2's word
     */
    function getRevealedLetters(uint256 _gameId, uint8 _playerNum) external view returns (bytes1[] memory) {
        Game storage game = games[_gameId];
        if (_playerNum == 1) {
            return game.player1State.revealedLetters;
        } else {
            return game.player2State.revealedLetters;
        }
    }
}