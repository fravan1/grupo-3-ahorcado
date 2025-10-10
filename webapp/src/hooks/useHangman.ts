import { useState } from "react";
import { useNavigate } from "react-router";
import { useAccount, useWalletClient } from "wagmi";
import { hangmanAbi } from "../abis/hangman-abi";
import { numberToHex, pad } from "viem";

export function useAsyncAction<T>(callback: (...args: any[]) => Promise<T>) {
  const [waiting, setWaiting] = useState(false);
  const [res, setRes] = useState<T | null>(null);
  const call = async (...args: any[]) => {
    setWaiting(true)
    const res = await callback(...args);
    setRes(res);
    setWaiting(false)
  };
  return {
    call,
    waiting,
    res
  }
}

export function useHangman() {
  const { isConnected } = useAccount();
  const navigate = useNavigate();
  const { data: walletClient } = useWalletClient();

  const startGame = useAsyncAction(async (commitment: bigint) => {
    console.log('aaaaaaaaaaaaaa')
    if (!isConnected || !walletClient) {
      console.log("isConnected", isConnected);
      console.log("walletClient", walletClient);
      navigate('/');
    }

    if (!walletClient) {
      throw new Error();
    }

    console.log('aaaaaaaaaaaaaa')

    const txId = await walletClient.writeContract({
      abi: hangmanAbi,
      functionName: 'createGame',
      address: import.meta.env.VITE_HANGMAN_ADDRESS,
      args: [pad(numberToHex(commitment)), 16]
    });
    return txId;
  });


  return {
    startGame
  }
}
