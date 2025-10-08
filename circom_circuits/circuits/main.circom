pragma circom 2.2.2;

template EntryPoint() {
    input signal in;

    in === 10;
}

component main = EntryPoint();