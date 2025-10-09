import { useState } from 'react'
import './App.css'
import { useAccount } from 'wagmi'
import { Account } from './components/account-info'
import { WalletOptions } from './components/wallet-options'
import { useZk } from './hooks/useZk'

function ConnectWallet() {
  const { isConnected } = useAccount()
  if (isConnected) return <Account />
  return <WalletOptions />
}

function App() {
  const [count, setCount] = useState(0);
  const zk = useZk();

  return (
    <>
      <div>
        <ConnectWallet />
      </div>
      <h1>Vite + React</h1>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR {import.meta.env.VITE_VERIFIER_ADDRESS}
        </p>
        <pre>
        </pre>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>
      <button onClick={zk.calculateWitness} >WITNESS</button>
    </>
  )
}

export default App
