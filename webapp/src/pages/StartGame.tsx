import {  useCallback, useEffect } from "react";
import { useHangman } from "../hooks/useHangman"
import { useZk } from "../hooks/useZk";

export function StartGame() {
  const { startGame } = useHangman();
  const { calculateCommitment } = useZk();
  
  const onClick = useCallback(async () => {
    const {commitment} = calculateCommitment('hola');
    
    await startGame.call(commitment);
  }, [startGame.call]);

  console.log(startGame.waiting);

  return <div>
    <div>
      {!startGame.ready ? 'waiting...' : startGame.res?.gameId}
    </div>
    <button onClick={onClick}>
      Nuevo juego
    </button>
  </div>
}
