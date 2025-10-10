import { useCallback } from "react";
import { useHangman } from "../hooks/useHangman"

export function StartGame() {
  const { startGame } = useHangman();
  console.log(startGame);

  const onClick = useCallback(() => {
    startGame.call(10n);
  }, [startGame.call]);

  return <div>
    <div>
      {startGame.waiting ? 'waiting...' : startGame.res}
    </div>
    <button onClick={onClick}>
      Nuevo juego
    </button>
  </div>
}
