use poseidon::poseidon2::Poseidon2;

global MAX_LEN: u32 = 16u32;

fn main(
    commitment: pub Field,
    guess: pub Field,
    positions: pub [bool; MAX_LEN],

    word: [Field; MAX_LEN],
    word_len: u32,
) {
    let computed_commitment = Poseidon2::hash(word, word_len);
    assert(commitment == computed_commitment);

    for i in 0..MAX_LEN {
        let eq = word[i] == guess;
        let p = positions[i];
        assert(positions[i] == eq);
    }
}
