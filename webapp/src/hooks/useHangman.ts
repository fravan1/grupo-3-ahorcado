import { useState } from "react";
import { useNavigate } from "react-router";
import { useAccount, usePublicClient, useWalletClient } from "wagmi";
import { hangmanAbi } from "../abis/hangman-abi";
import { numberToHex, pad, parseEventLogs, type Hex } from "viem";
import { anvil } from "viem/chains";

const HANGMAN_ADDRESS= import.meta.env.VITE_HANGMAN_ADDRESS;

export function useAsyncAction<T>(callback: (...args: any[]) => Promise<T>) {
  const [waiting, setWaiting] = useState(false);
  const [ready, setReady] = useState(false);
  const [res, setRes] = useState<T | undefined>(undefined);
  const call = async (...args: any[]) => {
    setWaiting(true);
    const res = await callback(...args);
    setRes(res);
    setWaiting(false);
    setReady(true);
  };
  return {
    call,
    waiting,
    res,
    ready
  }
}

export function useHangman() {
  const { isConnected } = useAccount();
  const navigate = useNavigate();
  const { data: walletClient, error } = useWalletClient();
  const publicClient = usePublicClient();
  
  const startGame = useAsyncAction(async (commitment: bigint) => {
    if (!isConnected || !walletClient || !publicClient) {
      console.log(error);
      console.log("isConnected", isConnected);
      console.log("walletClient", walletClient);
      navigate('/');
    }

    if (!walletClient) {
      throw new Error();
    }

    const txHash = await walletClient.writeContract({
      abi: hangmanAbi,
      functionName: 'createGame',
      address: HANGMAN_ADDRESS,
      args: [pad(numberToHex(commitment)), 16]
    });

    const receipt = await publicClient!.waitForTransactionReceipt({ hash: txHash});
    const logs = parseEventLogs({ 
      abi: hangmanAbi,
      logs: receipt.logs,
    });

    const newGameLog = logs.find(l => l.eventName === 'GameCreated');

    if (newGameLog === undefined) {
      throw new  Error('No new game event');
    }

    return {
      txHash: txHash,
      gameId: newGameLog.topics[1],
    };
  });

  const gameById = useAsyncAction(async (gameId: string) => {
    if (!publicClient) {
      throw new Error();
    }
    return publicClient.readContract({
      abi: hangmanAbi,
      functionName: 'games',
      args: [BigInt(gameId)],
      address: import.meta.env.VITE_HANGMAN_ADDRESS,
    });
  });


  const joinGame = useAsyncAction(async (gameId: string, commitment: bigint) => {
    if (!walletClient || !publicClient) {
      console.log(walletClient);
      throw new Error('a');
    }

    const txHash = await walletClient.writeContract({
      abi: hangmanAbi,
      functionName: 'joinGame',
      args: [BigInt(gameId), pad(numberToHex(commitment)), 16],
      address: HANGMAN_ADDRESS
    });

    const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });

    const logs = parseEventLogs({
      abi: hangmanAbi,
      logs: receipt.logs
    });

    const log = logs.find(l => l.eventName === 'GameStarted');

    if (!log) {
      throw new Error('No tiró nada');
    }


    return {
      gameId: log.topics[0],
      player1: log.topics[1],
      player2: log.topics[2],
    };
  });

  const submitGuess = useAsyncAction(async(gameId: string, guess: string) => {
    if (!walletClient || !publicClient) {
      console.log(walletClient, error);
      throw new Error('falta algo');
    }
    console.log('guess', guess)

    const charCode = guess.charCodeAt(0);

    const txHash = await walletClient.writeContract({
      abi: hangmanAbi,
      functionName: 'submitGuess',
      args: [BigInt(gameId), numberToHex(charCode)],
      address: HANGMAN_ADDRESS
    });

    const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });

    const logs = parseEventLogs({
      abi: hangmanAbi,
      logs: receipt.logs
    });

    const log = logs.find(l => l.eventName === 'GuessSubmitted');

    if (!log) {
      throw new Error('there should be a log');
    }

    return {
      gameId: log.topics[0],
      player: log.topics[1],
      guess: log.topics[2]
    }
  });


  return {
    startGame,
    gameById,
    joinGame,
    submitGuess
  }
}
