import hangmanCircuit from '../circuits/hangman.json'
import { UltraHonkBackend } from '@aztec/bb.js';
import { Noir } from '@noir-lang/noir_js';
import { poseidon2Hash } from '@zkpassport/poseidon2';


const noir = new Noir(hangmanCircuit as unknown as any);
const backend = new UltraHonkBackend(hangmanCircuit.bytecode);

export function useZk() {
  
  

  const calculateProof = async (word: string, guess: string) => {
    if (word.length > 16) {
      throw new Error('Words longer than 16 characters do not exist in this realm');
    }

    if (guess.length !== 1) {
      throw new Error('Exactly 1 letter at the time should be guessed');
    }

    const chars = word.split('').map(char => char.charCodeAt(0));

    while (chars.length < 16) {
      chars.push(0);
    }
    const guessCode = guess.charCodeAt(0);

    const positions = chars.map(c => c === guessCode);

    const commitment = poseidon2Hash(chars.map(c => BigInt(c)));

    const wtns = await noir.execute({
      word: chars.map(c => c.toString()),
      positions,
      guess: guessCode.toString(),
      commitment: commitment.toString()
    });

    const proof = await backend.generateProof(wtns.witness);

    return {
      proof,
      commitment
    };
  }

  return {
    calculateProof
  }
}
