use poseidon::poseidon2::Poseidon2;

global MAX_LEN: u32 = 16u32;

fn main(
    commitment: pub Field,
    guess: pub Field,
    positions: pub [bool; MAX_LEN],
    word: [Field; MAX_LEN],
) {
    let computed_commitment = Poseidon2::hash(word, MAX_LEN);
    assert(commitment == computed_commitment);

    for i in 0..MAX_LEN {
        let eq = word[i] == guess;
        assert(positions[i] == eq);
    }
}

fn str_to_word<let N: u32>(str: str<N>) -> ([Field; MAX_LEN], u32) {
    let str = str.as_bytes();

    let mut word = [0; MAX_LEN];
    for i in 0..str.len() {
        word[i] = str[i] as Field;
    }

    (word, str.len())
}

#[test]
fn test_one_correct() {
    let (word, len) = str_to_word("trepidating");
    let commitment = Poseidon2::hash(word, MAX_LEN);

    let guess = "p".as_bytes()[0] as Field;

    let mut positions = [false; MAX_LEN];
    positions[3] = true;

    main(commitment, guess, positions, word);
}

#[test]
fn test_many_correct() {
    let (word, len) = str_to_word("iridiscent");
    let commitment = Poseidon2::hash(word, MAX_LEN);

    let guess = "i".as_bytes()[0] as Field;

    let mut positions = [false; MAX_LEN];
    positions[0] = true;
    positions[2] = true;
    positions[4] = true;

    main(commitment, guess, positions, word);
}

#[test]
fn test_none_correct() {
    let (word, len) = str_to_word("cocacolastic");
    let commitment = Poseidon2::hash(word, MAX_LEN);

    let guess = "z".as_bytes()[0] as Field;

    let mut positions = [false; MAX_LEN];

    main(commitment, guess, positions, word);
}

#[test(should_fail)]
fn test_invalid_omit() {
    let (word, len) = str_to_word("kerfuffle");
    let commitment = Poseidon2::hash(word, len);

    let guess = "f".as_bytes()[0] as Field;

    let mut positions = [false; MAX_LEN];
    positions[3] = true;
    positions[6] = true;

    main(commitment, guess, positions, word);
}

#[test(should_fail)]
fn test_invalid_extra() {
    let (word, len) = str_to_word("codswallop");
    let commitment = Poseidon2::hash(word, len);

    let guess = "w".as_bytes()[0] as Field;

    let mut positions = [false; MAX_LEN];
    positions[4] = true;
    positions[9] = true;

    main(commitment, guess, positions, word);
}

#[test(should_fail)]
fn test_invalid_swap() {
    let (word, len) = str_to_word("platypus");
    let commitment = Poseidon2::hash(word, len);

    let guess = "y".as_bytes()[0] as Field;

    let mut positions = [false; MAX_LEN];
    positions[1] = true;

    main(commitment, guess, positions, word);
}

#[test(should_fail)]
fn test_invalid_commit<let N: u32>(fake_word: [Field; MAX_LEN], fake_len: u32) {
    let (word, len) = str_to_word("fuzzing");
    let commitment = Poseidon2::hash(word, len);

    let guess = "y".as_bytes()[0] as Field;

    let mut positions = [false; MAX_LEN];

    main(commitment, guess, positions, fake_word);
}

