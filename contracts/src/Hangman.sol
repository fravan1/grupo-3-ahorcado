// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVerifier} from "./Verifier.sol";
import "./HangmanStructs.sol";

contract Hangman is Ownable {
    IVerifier public verifier;
    mapping(uint256 => Game) public games;
    uint256 public gameCounter;
    uint8 public constant MAX_WORD_LEN = 16;
    uint8 public constant DEFAULT_ATTEMPTS = 6;

    event VerifierUpdated(IVerifier _newVerifier);
    event GameCreated(uint256 indexed gameId, address indexed player1, uint8 wordLength);
    event GameStarted(uint256 indexed gameId, address indexed player1, address indexed player2);
    event GuessSubmitted(uint256 indexed gameId, address indexed guesser, bytes1 letter);
    event ProofVerified(uint256 indexed gameId, address indexed prover, uint256[] positions);
    event GameFinished(uint256 indexed gameId, address indexed winner, string reason);

    error InvalidWordLenght();
    error GameNotFound();
    error GameAlreadyStarted();
    error InvalidPlayer();
    error GameNotActive();
    error NotPlayerInGame();
    error InvalidInput();
    error GuessRepeated();
    error GuessInCourse();
    error NoGuessInCourse();
    error Cheater();
    error DeadPlayer();

    constructor(IVerifier _verifier) Ownable(msg.sender) {
        verifier = _verifier;
    }

    function setVerifier(IVerifier _newVerifier) external onlyOwner {
        verifier = _newVerifier;
        emit VerifierUpdated(_newVerifier);
    }

    /**
     * @notice Create a new game with a secret word
     * @param _wordCommitment Poseidon hash of the secret word
     * @param _wordLength Length of the secret word
     */
    function createGame(bytes32 _wordCommitment, uint8 _wordLength) external {
        if (_wordCommitment == 0
          || _wordLength > MAX_WORD_LEN
          || _wordLength == 0) revert InvalidWordLenght();

        uint256 gameId = gameCounter++;
        Game storage game = games[gameId];

        game.status = GameStatus.WAITING_FOR_PLAYER;
        game.createdAt = block.timestamp;

        game.player1 = msg.sender;
        game.player1State.wordCommitment = _wordCommitment;
        game.player1State.wordLength = _wordLength;
        game.player1State.lastActionTime = block.timestamp;

        emit GameCreated(gameId, msg.sender, _wordLength);
    }

    /**
     * @notice Join an existing game with your own secret word
     * @param _gameId The game to join
     * @param _wordCommitment Hash of your secret word
     * @param _wordLength Length of your secret word
     */
    function joinGame(uint256 _gameId, bytes32 _wordCommitment, uint8 _wordLength) external {
        Game storage game = games[_gameId];

        if (game.player1 == address(0)) revert GameNotFound();
        if (game.status != GameStatus.WAITING_FOR_PLAYER) revert GameAlreadyStarted();
        if (msg.sender == game.player1) revert InvalidPlayer();
        if (_wordCommitment == 0
          || _wordLength > MAX_WORD_LEN
          || _wordLength == 0) revert InvalidWordLenght();

        game.status = GameStatus.ACTIVE;

        game.player2 = msg.sender;
        game.player2State.wordCommitment = _wordCommitment;
        game.player2State.wordLength = _wordLength;
        game.player2State.lastActionTime = block.timestamp;

        game.player1State.remainingAttempts = DEFAULT_ATTEMPTS;
        game.player2State.remainingAttempts = DEFAULT_ATTEMPTS;

        game.player1State.revealedLetters = new bytes1[](game.player2State.wordLength);
        game.player2State.revealedLetters = new bytes1[](game.player1State.wordLength);

        emit GameStarted(_gameId, game.player1, msg.sender);
    }

    /**
     * @notice Submit a letter guess for your opponent's word
     * @param _gameId The game ID
     * @param _letter The letter to guess (lowercase a-z)
     */

    function submitGuess(uint256 _gameId, bytes1 _letter) external {
        Game storage game = games[_gameId];

        if (game.player1 == address(0)) revert GameNotFound();
        if (game.status != GameStatus.ACTIVE) revert GameNotActive();
        if (msg.sender != game.player1 && msg.sender != game.player2) revert NotPlayerInGame();

        // Determine which state to update (opposite player's word)
        PlayerState storage myState = msg.sender == game.player1
            ? game.player1State
            : game.player2State;

        if (myState.remainingAttempts == 0) revert DeadPlayer();

        // Validate letter (Only a-z allowed)
        uint8 letterIndex = uint8(_letter);
        if (letterIndex < 97 || 122 < letterIndex) revert InvalidInput();
        letterIndex -= 97; // 'a' = 97

        // Check if letter already guessed
        uint32 mask = uint32(1) << letterIndex;
        if (myState.guessedLetters & mask != 0) revert GuessRepeated();

        // Check no pending guess exists
        if (myState.currentGuess != 0) revert GuessInCourse();

        // Mark letter as guessed
        myState.guessedLetters = myState.guessedLetters | mask;

        // Set pending guess
        myState.currentGuess = _letter;
        myState.lastActionTime = block.timestamp;

        emit GuessSubmitted(_gameId, msg.sender, _letter);
    }

    /**
     * @notice Submit a zero-knowledge proof for an opponent's guess
     * @param _gameId The game ID
     * @param _proof The ZK proof from Noir circuit
     * @param _letterPositions (0/1) Array indicating where the letter appears
     */
    function submitProof(
        uint256 _gameId,
        bytes calldata _proof,
        uint256[] calldata _letterPositions
    ) external {
        Game storage game = games[_gameId];

        if (game.player1 == address(0)) revert GameNotFound();
        if (game.status != GameStatus.ACTIVE) revert GameNotActive();
        if (msg.sender != game.player1 && msg.sender != game.player2) revert NotPlayerInGame();

        PlayerState storage opponentState = msg.sender == game.player1
            ? game.player2State
            : game.player1State;

        PlayerState storage myState = msg.sender == game.player1
            ? game.player1State
            : game.player2State;

        if (opponentState.currentGuess == 0) revert NoGuessInCourse();

        //TODO: agregar validacion para que _letterPositions tenga el largo esperado
        //revertir con otro error
        //el ciclo se va de range antes de poder checkear el if y explota

        //uint256 lastPosition = 0;
        for (uint256 i = myState.wordLength; i < _letterPositions.length; i++) {
            if (_letterPositions[i] != 0) revert InvalidInput();
        }

        bytes32[] memory publicInputs = new bytes32[](2 + MAX_WORD_LEN);
        publicInputs[0] = myState.wordCommitment;
        publicInputs[1] = opponentState.currentGuess;

        for (uint256 i = 0; i < MAX_WORD_LEN; i++) {
            publicInputs[2 + i] = bytes32(_letterPositions[i]);
        }

        bool proofIsValid = verifier.verify(_proof, publicInputs);

        if (!proofIsValid) revert Cheater();

        bool guessIsCorrect = false;
        for (uint256 i = 0; i < opponentState.revealedLetters.length; i++) {
            if (_letterPositions[i] != 0) {
                guessIsCorrect = true;
                opponentState.revealedLetters[i] = opponentState.currentGuess;
            }
        }

        if (!guessIsCorrect) opponentState.remainingAttempts--;

        opponentState.currentGuess = 0;

        emit ProofVerified(_gameId, msg.sender, _letterPositions);

        _checkGameEnd(_gameId);
    }

    /**
     * @notice Claim victory if opponent hasn't responded within timeout
     * @param _gameId The game ID
     */
    function claimTimeout(uint256 _gameId) external {}

    // ============================================
    // INTERNAL FUNCTIONS
    // ============================================
    /**
     * @notice Check if the game has been won
     * @param _gameId The game ID
     */
    function _checkGameEnd(uint256 _gameId) internal {
        Game storage game = games[_gameId];

        bool player1Guessed = _isWordComplete(game.player1State.revealedLetters);
        bool player2Guessed = _isWordComplete(game.player2State.revealedLetters);

        bool player1Died = game.player1State.remainingAttempts == 0;
        bool player2Died = game.player2State.remainingAttempts == 0;

        // game ended
        if ((player1Guessed || player1Died) && (player2Guessed || player2Died)) {
            game.status = GameStatus.FINISHED;

            //address winner;
            string memory reason;

            if (player1Died && player2Died) { // tie
                //winner = address(0);
                reason = "Both players lost";
            } else if (player1Died) { // player 2 guessed
                game.winner = game.player2;
                reason = "Player 2 was the only one who guessed";
            } else if (player2Died) { // player 1 guessed
                game.winner = game.player1;
                reason = "Player 1 was the only one who guessed";
            } else { // both guessed
                if (game.player1State.remainingAttempts == game.player2State.remainingAttempts) {
                    //winner = address(0);
                    reason = "Both players guessed at the same time";
                } else if (game.player1State.remainingAttempts < game.player2State.remainingAttempts) {
                    game.winner = game.player1;
                    reason = "Player 1 guessed faster than player 2";
                } else {
                    game.winner = game.player2;
                    reason = "Player 2 guessed faster than player 1";
                }
            }

            emit GameFinished(_gameId, game.winner, reason);
        }
    }

    function _isWordComplete(bytes1[] storage revealedLetters) internal view returns (bool) {
        for (uint256 i = 0; i < revealedLetters.length; i++) {
            if (revealedLetters[i] == 0) return false;
        }
        return true;
    }

    // ============================================
    // VIEW FUNCTIONS
    // ============================================
    /**
     * @notice Get the current state of a game
     * @param _gameId The game ID
     */
    function getGameState(uint256 _gameId)
        external
        view
        returns (
            address player1,
            address player2,
            GameStatus status,
            address winner,
            uint8 player1WordLength,
            uint8 player2WordLength,
            uint8 player1WrongGuesses,
            uint8 player2WrongGuesses
        )
    {
        Game storage game = games[_gameId];
        return (
            game.player1,
            game.player2,
            game.status,
            game.winner,
            game.player1State.wordLength,
            game.player2State.wordLength,
            game.player1State.remainingAttempts,
            game.player2State.remainingAttempts
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
