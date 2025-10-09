import hangmanCircuit from '../circuits/hangman.json'
import { UltraHonkBackend } from '@aztec/bb.js';
import { Noir } from '@noir-lang/noir_js';
import { poseidon2 } from 'poseidon-lite';


const noir = new Noir(hangmanCircuit as unknown as any);
const backend = new UltraHonkBackend(hangmanCircuit.bytecode);

export function useZk() {
  const word = new Array(16);
  word.fill(0n);
  const commitment = poseidon2([0n, 4])

  const positions = new Array(16).fill(false);
  positions[0] = true;
  positions[1] = true;
  positions[2] = true;
  positions[3] = true;
  console.log(positions);
  console.log(positions.length);

  const calculateWitness = async () => {
    const wtns = await noir.execute({
      word: word.map(c => c.toString()),
      word_len: 4,
      positions,
      guess: '0',
      commitment: commitment.toString()
    });
    console.log(wtns);
  }

  return {
    calculateWitness
  }
}
