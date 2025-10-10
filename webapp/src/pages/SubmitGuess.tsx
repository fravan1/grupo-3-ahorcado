import { useCallback, useEffect, useState } from "react";
import { useHangman } from "../hooks/useHangman";
import { useParams } from "react-router";
import { useAccount } from "wagmi";

export function SubmitGuess() {
  const params = useParams();
  const { address } = useAccount();
  const [char, setChar] = useState<string>('');
  const { submitGuess } = useHangman();

  const { gameById } = useHangman();

  useEffect(() => {
    gameById.call(params.gameId)
  }, []);

  const onClick = useCallback(() => {
    console.log(char![0]);
    submitGuess.call(params.gameId, char![0]);
  }, [submitGuess.call]);

  const handleChange= (e: any) => {
    console.log(e.target.value);
    setChar(e.target.value);
  }

  if (!gameById.res) {
    return 'waiting...'
  }

  return <div>
    <h1>SUBMIT!</h1>
    <p>Yo mismo: {address}</p>
    Letra!: <input type="text" onChange={handleChange}></input>

    <button onClick={onClick} disabled={char.length === 0}>Mandale!</button>
    <div>
      <div>Player 1: {gameById.res[0]}</div>
      <div>Player 2: {gameById.res[1]}</div>
    </div>
  </div>
}
