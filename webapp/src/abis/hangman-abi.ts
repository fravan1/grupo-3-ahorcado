export const hangmanAbi = [
  {
    "type": "constructor",
    "inputs": [
      {
        "name": "_verifier",
        "type": "address",
        "internalType": "contract IVerifier"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "DEFAULT_ATTEMPTS",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint8",
        "internalType": "uint8"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "MAX_WORD_LEN",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint8",
        "internalType": "uint8"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "claimTimeout",
    "inputs": [
      {
        "name": "_gameId",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "createGame",
    "inputs": [
      {
        "name": "_wordCommitment",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "_wordLength",
        "type": "uint8",
        "internalType": "uint8"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "gameCounter",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "games",
    "inputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [
      {
        "name": "player1",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "player2",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "player1State",
        "type": "tuple",
        "internalType": "struct PlayerState",
        "components": [
          {
            "name": "remainingAttempts",
            "type": "uint8",
            "internalType": "uint8"
          },
          {
            "name": "wordCommitment",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "wordLength",
            "type": "uint8",
            "internalType": "uint8"
          },
          {
            "name": "revealedLetters",
            "type": "bytes1[]",
            "internalType": "bytes1[]"
          },
          {
            "name": "guessedLetters",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "currentGuess",
            "type": "bytes1",
            "internalType": "bytes1"
          },
          {
            "name": "lastActionTime",
            "type": "uint256",
            "internalType": "uint256"
          }
        ]
      },
      {
        "name": "player2State",
        "type": "tuple",
        "internalType": "struct PlayerState",
        "components": [
          {
            "name": "remainingAttempts",
            "type": "uint8",
            "internalType": "uint8"
          },
          {
            "name": "wordCommitment",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "wordLength",
            "type": "uint8",
            "internalType": "uint8"
          },
          {
            "name": "revealedLetters",
            "type": "bytes1[]",
            "internalType": "bytes1[]"
          },
          {
            "name": "guessedLetters",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "currentGuess",
            "type": "bytes1",
            "internalType": "bytes1"
          },
          {
            "name": "lastActionTime",
            "type": "uint256",
            "internalType": "uint256"
          }
        ]
      },
      {
        "name": "status",
        "type": "uint8",
        "internalType": "enum GameStatus"
      },
      {
        "name": "winner",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "createdAt",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "proofTimeout",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getGameState",
    "inputs": [
      {
        "name": "_gameId",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [
      {
        "name": "player1",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "player2",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "status",
        "type": "uint8",
        "internalType": "enum GameStatus"
      },
      {
        "name": "winner",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "player1WordLength",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "player2WordLength",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "player1WrongGuesses",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "player2WrongGuesses",
        "type": "uint8",
        "internalType": "uint8"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getRevealedLetters",
    "inputs": [
      {
        "name": "_gameId",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "_playerNum",
        "type": "uint8",
        "internalType": "uint8"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bytes1[]",
        "internalType": "bytes1[]"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "joinGame",
    "inputs": [
      {
        "name": "_gameId",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "_wordCommitment",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "_wordLength",
        "type": "uint8",
        "internalType": "uint8"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "owner",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "renounceOwnership",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setVerifier",
    "inputs": [
      {
        "name": "_newVerifier",
        "type": "address",
        "internalType": "contract IVerifier"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "submitGuess",
    "inputs": [
      {
        "name": "_gameId",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "_letter",
        "type": "bytes1",
        "internalType": "bytes1"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "submitProof",
    "inputs": [
      {
        "name": "_gameId",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "_proof",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "_letterPositions",
        "type": "uint256[]",
        "internalType": "uint256[]"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "transferOwnership",
    "inputs": [
      {
        "name": "newOwner",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "verifier",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "contract IVerifier"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "event",
    "name": "GameCreated",
    "inputs": [
      {
        "name": "gameId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      },
      {
        "name": "player1",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "wordLength",
        "type": "uint8",
        "indexed": false,
        "internalType": "uint8"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "GameFinished",
    "inputs": [
      {
        "name": "gameId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      },
      {
        "name": "winner",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "reason",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "GameStarted",
    "inputs": [
      {
        "name": "gameId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      },
      {
        "name": "player1",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "player2",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "GuessSubmitted",
    "inputs": [
      {
        "name": "gameId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      },
      {
        "name": "guesser",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "letter",
        "type": "bytes1",
        "indexed": false,
        "internalType": "bytes1"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OwnershipTransferred",
    "inputs": [
      {
        "name": "previousOwner",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "newOwner",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "ProofVerified",
    "inputs": [
      {
        "name": "gameId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      },
      {
        "name": "prover",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "positions",
        "type": "uint256[]",
        "indexed": false,
        "internalType": "uint256[]"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "VerifierUpdated",
    "inputs": [
      {
        "name": "_newVerifier",
        "type": "address",
        "indexed": false,
        "internalType": "contract IVerifier"
      }
    ],
    "anonymous": false
  },
  {
    "type": "error",
    "name": "Cheater",
    "inputs": []
  },
  {
    "type": "error",
    "name": "DeadPlayer",
    "inputs": []
  },
  {
    "type": "error",
    "name": "GameAlreadyStarted",
    "inputs": []
  },
  {
    "type": "error",
    "name": "GameNotActive",
    "inputs": []
  },
  {
    "type": "error",
    "name": "GameNotFound",
    "inputs": []
  },
  {
    "type": "error",
    "name": "GuessInCourse",
    "inputs": []
  },
  {
    "type": "error",
    "name": "GuessRepeated",
    "inputs": []
  },
  {
    "type": "error",
    "name": "InvalidInput",
    "inputs": []
  },
  {
    "type": "error",
    "name": "InvalidPlayer",
    "inputs": []
  },
  {
    "type": "error",
    "name": "InvalidWordLenght",
    "inputs": []
  },
  {
    "type": "error",
    "name": "NoGuessInCourse",
    "inputs": []
  },
  {
    "type": "error",
    "name": "NotPlayerInGame",
    "inputs": []
  },
  {
    "type": "error",
    "name": "OwnableInvalidOwner",
    "inputs": [
      {
        "name": "owner",
        "type": "address",
        "internalType": "address"
      }
    ]
  },
  {
    "type": "error",
    "name": "OwnableUnauthorizedAccount",
    "inputs": [
      {
        "name": "account",
        "type": "address",
        "internalType": "address"
      }
    ]
  }
] as const;
