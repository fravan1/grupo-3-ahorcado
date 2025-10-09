// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct PlayerState {
    bytes32 wordCommitment; // My secret word (for opponent to guess)
    uint8 wordLength;

    bytes1[] revealedLetters; // Letters I have guessed correctly
    uint32 guessedLetters; // Bitmap of letters I have guessed

    uint8 remainingAttempts;
    bytes1 currentGuess; // My current guess waiting for proof (or 0)
    uint256 lastActionTime;
}

struct Game {
    address player1;
    address player2;

    PlayerState player1State;
    PlayerState player2State;

    GameStatus status; // WAITING, ACTIVE, FINISHED
    address winner; // address(0) for draw

    uint256 createdAt;
    uint256 proofTimeout; // e.g., 10 minutes
}

enum GameStatus {
    WAITING_FOR_PLAYER,
    ACTIVE,
    FINISHED
}
