import { useCallback, useEffect } from "react";
import { useHangman } from "../hooks/useHangman";
import { useParams } from "react-router";
import { useAccount } from "wagmi";
import { useZk } from "../hooks/useZk";

export function SubmitProof() {
  const params = useParams();
  const { address } = useAccount();
  const { gameById, submitProof } = useHangman();
  const { calculateProof } = useZk();


  useEffect(() => {
    gameById.call(params.gameId)
  }, []);

  const onClick = useCallback(async () => {
    const { proof, positions } = await calculateProof('hola', 'a');

    await submitProof.call(params.gameId, proof.proof, positions);
  }, [submitProof.call]);

  if (!gameById.res) {
    return 'waiting...'
  }

  return <div>
    <h1>¡MANDA LA PRUEBA!</h1>
    <p>Yo mismo: {address}</p>

    <button onClick={onClick}>Mandale!</button>
    <div>
      <div>Player 1: {gameById.res[0]}</div>
      <div>Player 1 commitment: {gameById.res[2].wordCommitment}</div>
      <div>Player 2: {gameById.res[1]}</div>
      <div>Player 2 commitment: {gameById.res[3].wordCommitment}</div>
    </div>

  </div>
}
