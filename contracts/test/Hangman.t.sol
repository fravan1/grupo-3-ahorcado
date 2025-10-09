// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Hangman} from "../src/Hangman.sol";
import {IVerifier} from "../src/Verifier.sol";
import {PlayerState, GameStatus} from "../src/HangmanStructs.sol";

contract MockVerifier is IVerifier {
    bool public shouldVerify;

    constructor(bool _shouldVerify) {
        shouldVerify = _shouldVerify;
    }

    function verify(bytes calldata, bytes32[] calldata) external view returns (bool) {
        return shouldVerify;
    }

    function setShouldVerify(bool _shouldVerify) external {
        shouldVerify = _shouldVerify;
    }
}

contract HangmanTest is Test {
    Hangman public hangman;
    MockVerifier public verifier;

    address public owner = address(this);
    address public player1 = address(0x1);
    address public player2 = address(0x2);
    address public player3 = address(0x3);

    bytes32 public word1Commitment = keccak256(abi.encodePacked("hello", uint256(12345)));
    bytes32 public word2Commitment = keccak256(abi.encodePacked("world", uint256(67890)));

    uint8 public constant WORD_LENGTH_5 = 5;
    uint8 public constant WORD_LENGTH_6 = 6;

    event GameCreated(uint256 indexed gameId, address indexed player1, uint8 wordLength);
    event GameStarted(uint256 indexed gameId, address indexed player1, address indexed player2);
    event GuessSubmitted(uint256 indexed gameId, address indexed guesser, bytes1 letter);
    event ProofVerified(uint256 indexed gameId, address indexed prover, uint256[] positions);
    event GameFinished(uint256 indexed gameId, address indexed winner, string reason);

    function setUp() public {
        verifier = new MockVerifier(true);
        hangman = new Hangman(verifier);
    }

    // ============================================
    // CONSTRUCTOR & SETUP TESTS
    // ============================================

    function test_Constructor() public view {
        assertEq(address(hangman.verifier()), address(verifier));
        assertEq(hangman.owner(), owner);
        assertEq(hangman.gameCounter(), 0);
        assertEq(hangman.MAX_WORD_LEN(), 16);
        assertEq(hangman.DEFAULT_ATTEMPTS(), 6);
    }

    function test_SetVerifier_AsOwner() public {
        MockVerifier newVerifier = new MockVerifier(false);

        vm.expectEmit(true, true, true, true);
        emit Hangman.VerifierUpdated(newVerifier);

        hangman.setVerifier(newVerifier);
        assertEq(address(hangman.verifier()), address(newVerifier));
    }

    function test_SetVerifier_RevertIf_NotOwner() public {
        MockVerifier newVerifier = new MockVerifier(false);

        vm.prank(player1);
        vm.expectRevert();
        hangman.setVerifier(newVerifier);
    }

    // ============================================
    // CREATE GAME TESTS
    // ============================================

    function test_CreateGame_Success() public {
        vm.prank(player1);

        vm.expectEmit(true, true, false, true);
        emit GameCreated(0, player1, WORD_LENGTH_5);

        hangman.createGame(word1Commitment, WORD_LENGTH_5);

        (address p1, address p2,,, GameStatus status,,,) = hangman.games(0);

        assertEq(p1, player1);
        assertEq(p2, address(0));
        assertEq(uint8(status), uint8(GameStatus.WAITING_FOR_PLAYER));
        assertEq(hangman.gameCounter(), 1);
    }

    function test_CreateGame_RevertIf_WordTooShort() public {
        vm.prank(player1);
        vm.expectRevert(Hangman.InvalidWordLenght.selector);
        hangman.createGame(word1Commitment, 0);
    }

    function test_CreateGame_RevertIf_WordTooLong() public {
        vm.prank(player1);
        vm.expectRevert(Hangman.InvalidWordLenght.selector);
        hangman.createGame(word1Commitment, 17);
    }

    function test_CreateGame_MultipleGames() public {
        vm.prank(player1);
        hangman.createGame(word1Commitment, WORD_LENGTH_5);

        vm.prank(player2);
        hangman.createGame(word2Commitment, WORD_LENGTH_6);

        assertEq(hangman.gameCounter(), 2);

        (address p1_game0,,,,,,,) = hangman.games(0);
        (address p1_game1,,,,,,,) = hangman.games(1);

        assertEq(p1_game0, player1);
        assertEq(p1_game1, player2);
    }

    // ============================================
    // JOIN GAME TESTS
    // ============================================

    function test_JoinGame_Success() public {
        vm.prank(player1);
        hangman.createGame(word1Commitment, WORD_LENGTH_5);

        vm.prank(player2);

        vm.expectEmit(true, true, true, false);
        emit GameStarted(0, player1, player2);

        hangman.joinGame(0, word2Commitment, WORD_LENGTH_6);

        (address p1, address p2,,, GameStatus status,,,) = hangman.games(0);

        assertEq(p1, player1);
        assertEq(p2, player2);
        assertEq(uint8(status), uint8(GameStatus.ACTIVE));
    }

    function test_JoinGame_RevertIf_GameNotFound() public {
        vm.prank(player2);
        vm.expectRevert(Hangman.GameNotFound.selector);
        hangman.joinGame(999, word2Commitment, WORD_LENGTH_6);
    }

    function test_JoinGame_RevertIf_AlreadyStarted() public {
        vm.prank(player1);
        hangman.createGame(word1Commitment, WORD_LENGTH_5);

        vm.prank(player2);
        hangman.joinGame(0, word2Commitment, WORD_LENGTH_6);

        vm.prank(player3);
        vm.expectRevert(Hangman.GameAlreadyStarted.selector);
        hangman.joinGame(0, word2Commitment, WORD_LENGTH_6);
    }

    function test_JoinGame_RevertIf_JoiningOwnGame() public {
        vm.prank(player1);
        hangman.createGame(word1Commitment, WORD_LENGTH_5);

        vm.prank(player1);
        vm.expectRevert(Hangman.InvalidPlayer.selector);
        hangman.joinGame(0, word2Commitment, WORD_LENGTH_6);
    }

    function test_JoinGame_RevertIf_InvalidWordLength() public {
        vm.prank(player1);
        hangman.createGame(word1Commitment, WORD_LENGTH_5);

        vm.prank(player2);
        vm.expectRevert(Hangman.InvalidWordLenght.selector);
        hangman.joinGame(0, word2Commitment, 0);

        vm.prank(player2);
        vm.expectRevert(Hangman.InvalidWordLenght.selector);
        hangman.joinGame(0, word2Commitment, 17);
    }

    // ============================================
    // SUBMIT GUESS TESTS
    // ============================================
    
    function test_SubmitGuess_Success() public {
        _setupActiveGame();
        
        vm.prank(player1);
        
        vm.expectEmit(true, true, false, true);
        emit GuessSubmitted(0, player1, "a");
        
        hangman.submitGuess(0, "a");
        
        (,, PlayerState memory p1State,,,,,) = hangman.games(0);
        assertEq(p1State.currentGuess, "a");
        assertEq(p1State.guessedLetters, 1); // Bit 0 set for 'a'
    }
    
    function test_SubmitGuess_RevertIf_GameNotActive() public {
        vm.prank(player1);
        hangman.createGame(word1Commitment, WORD_LENGTH_5);
        
        vm.prank(player1);
        vm.expectRevert(Hangman.GameNotActive.selector);
        hangman.submitGuess(0, "a");
    }
    
    function test_SubmitGuess_RevertIf_NotPlayerInGame() public {
        _setupActiveGame();
        
        vm.prank(player3);
        vm.expectRevert(Hangman.NotPlayerInGame.selector);
        hangman.submitGuess(0, "a");
    }
    
    function test_SubmitGuess_RevertIf_InvalidLetter_Uppercase() public {
        _setupActiveGame();
        
        vm.prank(player1);
        vm.expectRevert(Hangman.InvalidInput.selector);
        hangman.submitGuess(0, "A");
    }
    
    function test_SubmitGuess_RevertIf_InvalidLetter_Number() public {
        _setupActiveGame();
        
        vm.prank(player1);
        vm.expectRevert(Hangman.InvalidInput.selector);
        hangman.submitGuess(0, "1");
    }
    
    function test_SubmitGuess_RevertIf_InvalidLetter_Special() public {
        _setupActiveGame();
        
        vm.prank(player1);
        vm.expectRevert(Hangman.InvalidInput.selector);
        hangman.submitGuess(0, "!");
    }
    
    function test_SubmitGuess_RevertIf_RepeatedGuess() public {
        _setupActiveGame();
        
        vm.prank(player1);
        hangman.submitGuess(0, "a");
        
        // Submit proof to clear currentGuess
        uint256[] memory positions = new uint256[](hangman.MAX_WORD_LEN());
        positions[0] = 0;
        
        vm.prank(player2);
        hangman.submitProof(0, "", positions);
        
        // Try to guess 'a' again
        vm.prank(player1);
        vm.expectRevert(Hangman.GuessRepeated.selector);
        hangman.submitGuess(0, "a");
    }
    
    function test_SubmitGuess_RevertIf_GuessInCourse() public {
        _setupActiveGame();
        
        vm.prank(player1);
        hangman.submitGuess(0, "a");
        
        vm.prank(player1);
        vm.expectRevert(Hangman.GuessInCourse.selector);
        hangman.submitGuess(0, "b");
    }
    
    function test_SubmitGuess_RevertIf_PlayerDead() public {
        _setupActiveGame();
        
        // Make player1 lose all attempts
        for (uint8 i = 0; i < 6; i++) {
            bytes1 letter = bytes1(uint8(97 + i)); // a, b, c, d, e, f
            
            vm.prank(player1);
            hangman.submitGuess(0, letter);
            
            uint256[] memory positions = new uint256[](hangman.MAX_WORD_LEN());
            positions[0] = 0; // Letter not in word
            
            vm.prank(player2);
            hangman.submitProof(0, "", positions);
        }
        
        // Try to guess after death
        vm.prank(player1);
        vm.expectRevert(Hangman.DeadPlayer.selector);
        hangman.submitGuess(0, "g");
    }
    
    function test_SubmitGuess_MultipleDifferentLetters() public {
        _setupActiveGame();

        bytes1[3] memory letters = [bytes1("a"), bytes1("e"), bytes1("z")];

        for (uint256 i = 0; i < letters.length; i++) {
            vm.prank(player1);
            hangman.submitGuess(0, letters[i]);

            uint256[] memory positions = new uint256[](hangman.MAX_WORD_LEN());
            positions[0] = 0;

            vm.prank(player2);
            hangman.submitProof(0, "", positions);
        }

        (,, PlayerState memory p1State,,,,,) = hangman.games(0);

        // Check bitmap: 'a'=0, 'e'=4, 'z'=25
        uint32 expectedBitmap = (1 << 0) | (1 << 4) | (1 << 25);
        assertEq(p1State.guessedLetters, expectedBitmap);
    }

    // ============================================
    // SUBMIT PROOF TESTS
    // ============================================
    
    function test_SubmitProof_LetterNotInWord() public {
        _setupActiveGame();
        
        vm.prank(player1);
        hangman.submitGuess(0, "x");
        
        uint256[] memory positions = new uint256[](hangman.MAX_WORD_LEN());
        
        vm.prank(player2);
        
        vm.expectEmit(true, true, false, true);
        emit ProofVerified(0, player2, positions);
        
        hangman.submitProof(0, "", positions);
        
        (,, PlayerState memory p1State,,,,,) = hangman.games(0);
        
        assertEq(p1State.currentGuess, bytes1(0));
        assertEq(p1State.remainingAttempts, 5);
        for (uint8 i = 0; i < p1State.revealedLetters.length; i++)
            assertEq(p1State.revealedLetters[i], 0);
    }
    
    function test_SubmitProof_LetterInWord_SinglePosition() public {
        _setupActiveGame();
        
        vm.prank(player1);
        hangman.submitGuess(0, "h");
        
        uint256[] memory positions = new uint256[](hangman.MAX_WORD_LEN());
        positions[0] = 1;
        
        vm.prank(player2);
        hangman.submitProof(0, "", positions);
        
        (,, PlayerState memory p1State,,,,,) = hangman.games(0);
        
        assertEq(p1State.currentGuess, bytes1(0));
        assertEq(p1State.remainingAttempts, 6);
        assertEq(p1State.revealedLetters[0], "h");
        for (uint8 i = 1; i < p1State.revealedLetters.length; i++)
            assertEq(p1State.revealedLetters[i], 0);
    }
    
    function test_SubmitProof_LetterInWord_MultiplePositions() public {
        _setupActiveGame();
        
        vm.prank(player1);
        hangman.submitGuess(0, "l");
        
        uint256[] memory positions = new uint256[](hangman.MAX_WORD_LEN());
        positions[2] = 1;
        positions[3] = 1;
        
        vm.prank(player2);
        hangman.submitProof(0, "", positions);
        
        (,, PlayerState memory p1State,,,,,) = hangman.games(0);
        
        assertEq(p1State.currentGuess, bytes1(0));
        assertEq(p1State.remainingAttempts, 6);
        assertEq(p1State.revealedLetters[2], "l");
        assertEq(p1State.revealedLetters[3], "l");
        for (uint8 i = 0; i < 2; i++)
            assertEq(p1State.revealedLetters[i], 0);
        for (uint8 i = 4; i < p1State.revealedLetters.length; i++)
            assertEq(p1State.revealedLetters[i], 0);
    }
    
    function test_SubmitProof_RevertIf_NoGuessInCourse() public {
        _setupActiveGame();
        
        uint256[] memory positions = new uint256[](hangman.MAX_WORD_LEN());
        
        vm.prank(player2);
        vm.expectRevert(Hangman.NoGuessInCourse.selector);
        hangman.submitProof(0, "", positions);
    }
    
    function test_SubmitProof_RevertIf_WrongProver() public {
        _setupActiveGame();
        
        vm.prank(player1);
        hangman.submitGuess(0, "a");
        
        uint256[] memory positions = new uint256[](hangman.MAX_WORD_LEN());
        
        // Player1 trying to prove their own guess
        vm.prank(player1);
        vm.expectRevert(Hangman.NoGuessInCourse.selector);
        hangman.submitProof(0, "", positions);
    }
    
    function test_SubmitProof_RevertIf_VerificationFails() public {
        _setupActiveGame();
        
        vm.prank(player1);
        hangman.submitGuess(0, "a");
        
        verifier.setShouldVerify(false);
        
        uint256[] memory positions = new uint256[](hangman.MAX_WORD_LEN());
        
        vm.prank(player2);
        vm.expectRevert(Hangman.Cheater.selector);
        hangman.submitProof(0, "", positions);
    }
    
    function test_SubmitProof_RevertIf_InvalidPositions_TooMany() public {
        _setupActiveGame();
        
        vm.prank(player1);
        hangman.submitGuess(0, "a");
        
        uint256[] memory positions = new uint256[](hangman.MAX_WORD_LEN());
        for (uint256 i = 0; i < 7; i++) {
            positions[i] = i + 1;
        }
        
        vm.prank(player2);
        vm.expectRevert(Hangman.InvalidInput.selector);
        hangman.submitProof(0, "", positions);
    }
    
    function test_SubmitProof_RevertIf_InvalidPositions_OutOfBounds() public {
        _setupActiveGame();
        
        vm.prank(player1);
        hangman.submitGuess(0, "a");
        
        uint256[] memory positions = new uint256[](2);
        positions[0] = 10; // Beyond word length
        positions[1] = 0;
        
        vm.prank(player2);
        vm.expectRevert(Hangman.InvalidInput.selector);
        hangman.submitProof(0, "", positions);
    }

    // ============================================
    // GAME END SCENARIOS
    // ============================================

    function test_GameEnd_Tie_BothComplete_SameAttempts() public {
        _setupActiveGame();

        uint256[] memory p1Positions = new uint256[](hangman.MAX_WORD_LEN());
        uint256[] memory p2Positions = new uint256[](hangman.MAX_WORD_LEN());

        for (uint8 i = 0; i < 6; i++) p1Positions[i] = 1;
        for (uint8 i = 0; i < 5; i++) p2Positions[i] = 1;

        // Player1 completes
        vm.prank(player1);
        hangman.submitGuess(0, "w");

        vm.prank(player2);
        hangman.submitProof(0, "", p1Positions);

        // Player2 completes
        vm.prank(player2);
        hangman.submitGuess(0, "w");
        
        vm.prank(player1);
        hangman.submitProof(0, "", p2Positions);
        
        (,,,, GameStatus status, address winner,,) = hangman.games(0);
        
        assertEq(uint8(status), uint8(GameStatus.FINISHED));
        assertEq(winner, address(0));
    }

    function test_GameEnd_Player2Wins_MoreLives() public {
        _setupActiveGame();

        uint256[] memory noPositions = new uint256[](hangman.MAX_WORD_LEN());
        uint256[] memory p1Positions = new uint256[](hangman.MAX_WORD_LEN());
        uint256[] memory p2Positions = new uint256[](hangman.MAX_WORD_LEN());

        for (uint8 i = 0; i < 6; i++) p1Positions[i] = 1;
        for (uint8 i = 0; i < 5; i++) p2Positions[i] = 1;

        // Player1 guesses wrong
        vm.prank(player1);
        hangman.submitGuess(0, "x");

        vm.prank(player2);
        hangman.submitProof(0, "", noPositions);

        // Player1 completes
        vm.prank(player1);
        hangman.submitGuess(0, "y");

        vm.prank(player2);
        hangman.submitProof(0, "", p1Positions);

        // Player2 completes
        vm.prank(player2);
        hangman.submitGuess(0, "z");
        
        vm.prank(player1);
        hangman.submitProof(0, "", p2Positions);
        
        (,,,, GameStatus status, address winner,,) = hangman.games(0);
        
        assertEq(uint8(status), uint8(GameStatus.FINISHED));
        assertEq(winner, player2);
    }

    function test_GameEnds_Player1Wins_Completes() public {
        _setupActiveGame();

        // Make player 2 die first
        for (uint8 i = 0; i < 6; i++) {
            bytes1 wrongLetter = bytes1(97 + i);

            vm.prank(player2);
            hangman.submitGuess(0, wrongLetter);

            uint256[] memory noPositions = new uint256[](hangman.MAX_WORD_LEN());

            vm.prank(player1);
            hangman.submitProof(0, "", noPositions);
        }

        // Player 1 guesses all letters correctly to complete the word
        vm.prank(player1);
        hangman.submitGuess(0, "x");

        uint256[] memory allPositions = new uint256[](hangman.MAX_WORD_LEN());
        for (uint256 i = 0; i < 6; i++) allPositions[i] = 1;

        vm.prank(player2);
        hangman.submitProof(0, "", allPositions);

        (,,,, GameStatus status, address winner,,) = hangman.games(0);
        
        assertEq(uint8(status), uint8(GameStatus.FINISHED));
        assertEq(winner, player1);
    }

    function test_GameEnds_BothDie() public {
        _setupActiveGame();
        
        // Player 1 dies (6 wrong guesses)
        for (uint8 i = 0; i < 6; i++) {
            bytes1 letter = bytes1(uint8(97 + i));
            
            vm.prank(player1);
            hangman.submitGuess(0, letter);
            
            uint256[] memory positions = new uint256[](hangman.MAX_WORD_LEN());
            positions[0] = 0;
            
            vm.prank(player2);
            hangman.submitProof(0, "", positions);
        }
        
        // Player 2 dies (6 wrong guesses)
        for (uint8 i = 6; i < 12; i++) {
            bytes1 letter = bytes1(uint8(97 + i));
            
            vm.prank(player2);
            hangman.submitGuess(0, letter);
            
            uint256[] memory positions = new uint256[](hangman.MAX_WORD_LEN());
            positions[0] = 0;
            
            vm.prank(player1);
            hangman.submitProof(0, "", positions);
        }
        
        (,,,, GameStatus status, address winner,,) = hangman.games(0);
        
        assertEq(uint8(status), uint8(GameStatus.FINISHED));
        assertEq(winner, address(0)); // Tie
    }

    // ============================================
    // HELPER FUNCTIONS
    // ============================================
    
    function _setupActiveGame() internal returns (uint256 gameId) {
        vm.prank(player1);
        hangman.createGame(word1Commitment, WORD_LENGTH_5);
        
        vm.prank(player2);
        hangman.joinGame(0, word2Commitment, WORD_LENGTH_6);
        
        return 0;
    }
}
