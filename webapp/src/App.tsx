import { useState } from 'react'
import './App.css'
import { useAccount, usePublicClient, useReadContract, useSwitchChain, useWalletClient } from 'wagmi'
import { Account } from './components/account-info'
import { WalletOptions } from './components/wallet-options'
import { useZk } from './hooks/useZk'
import { hangmanAbi } from './abis/hangman-abi'
import { numberToHex } from 'viem'

function ConnectWallet() {
  const { isConnected } = useAccount()
  if (isConnected) return <Account />
  return <WalletOptions />
}

function SwitchChainButton() {
  const { chains, switchChain } = useSwitchChain();



  return <div>
      {chains.map((chain) => (
        <button key={chain.id} onClick={() => switchChain({ chainId: chain.id })}>
          {chain.name}
        </button>
      ))}
    </div>
}

function App() {
  const [count, setCount] = useState(0);
  const zk = useZk();
  const { data: walletClient} = useWalletClient();

  const onClick = async () => {
    if (!walletClient) {
      return
    }

    const { commitment } = await zk.calculateProof('holu', 'o');
    const res = await walletClient.writeContract({
      abi: hangmanAbi,
      functionName: 'createGame',
      address: import.meta.env.VITE_HANGMAN_ADDRESS,
      args: [numberToHex(commitment), 16]
    });
    console.log(res);
  }

  return (
    <>
      <div>
        <ConnectWallet />
      </div>
      <div>
        <SwitchChainButton />
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
      <button onClick={onClick} >WITNESS</button>
    </>
  )
}

export default App
