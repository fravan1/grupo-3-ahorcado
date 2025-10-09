// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct PlayerState {
    bytes32 wordCommitment; // Their secret word (for opponent to guess)
    uint8 wordLength;
    bool[] revealedPositions; // Positions opponent has revealed
    bytes1[] revealedLetters; // Letters opponent has guessed correctly
    uint32 guessedLetters; // All letters opponent tried
    uint8 attemptsRemaining;
    //uint8 wrongGuesses;          // Opponent's wrong guesses on this word
    bytes1 pendingGuess; // Opponent's current guess waiting for proof
    bool proofSubmitted; // Has proof been submitted for pending guess
}

struct Game {
    address player1;
    address player2;

    PlayerState player1State; // Player 1's word (Player 2 is guessing)
    PlayerState player2State; // Player 2's word (Player 1 is guessing)

    uint8 maxWrongGuesses; // Usually 6
    //uint256 currentRound;
    GameStatus status; // WAITING, ACTIVE, FINISHED
    address winner; // address(0) for draw

    uint256 lastActionTime;
    uint256 proofTimeout; // e.g., 10 minutes
}

enum GameStatus {
    WAITING_FOR_PLAYER,
    ACTIVE,
    FINISHED
}
