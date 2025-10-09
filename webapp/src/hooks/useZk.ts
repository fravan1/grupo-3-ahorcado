import hangmanCircuit from '../circuits/hangman.json'
import { UltraHonkBackend } from '@aztec/bb.js';
import { Noir } from '@noir-lang/noir_js';
import { poseidon2Hash } from '@zkpassport/poseidon2';


const noir = new Noir(hangmanCircuit as unknown as any);
const backend = new UltraHonkBackend(hangmanCircuit.bytecode);

export function useZk() {
  
  

  const calculateWitness = async () => {
    const word = new Array(16);
    word.fill(0n);
    const positions = new Array(16).fill(false);

    const commitment = poseidon2Hash(word);
    // const commitment = poseidon2Hash([1n, 1n]);
    const wtns = await noir.execute({
      word: word.map(c => c.toString()),
      positions,
      guess: '1',
      commitment: commitment.toString()
    });
    console.log(wtns);
  }

  return {
    calculateWitness
  }
}
