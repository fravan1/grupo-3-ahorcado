import {  useCallback, useEffect } from "react";
import { useHangman } from "../hooks/useHangman"

export function StartGame() {
  const { startGame } = useHangman();
  
  const onClick = useCallback(async () => {
    await startGame.call(10n);
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
