import { useParams } from "react-router";
import { useHangman } from "../hooks/useHangman";
import { useCallback, useEffect } from "react";
import { useZk } from "../hooks/useZk";

export function JoinGame() {
  const params = useParams();
  const { calculateCommitment } = useZk();


  const { gameById, joinGame } = useHangman();

  useEffect(() => {
    gameById.call(params.gameId)
  }, []);

  const onClick = useCallback(async () => {
    const { commitment } = calculateCommitment('coso');
    await joinGame.call(params.gameId, commitment);
  }, [joinGame.call])

  if (!gameById.res) {
    return 'waiting...'
  }

  console.log(gameById.res);

  return <div>
    <div>
      <div>Player 1: {gameById.res[0]}</div>
      <div>Player 2: {gameById.res[1]}</div>
    </div>
    <div>
      {joinGame.res?.toString() || ''}
    </div>
    <div>
      <button onClick={onClick}>Join</button>
    </div>
  </div>
}
