# README

This is a Truffle project. Containing an Ethereum demo of the SereaphID.
In addition there are some unit tests implemented.

## Installation

Following applications are required:

- Truffle: A development environment and testing framework.
- Ganache-cli: A local standalone private Ethereum network/simulator

Both tools are part of the [truffle suite](https://truffleframework.com/).

```bash
truffle version
> Truffle v5.0.1 (core: 5.0.1)
> Solidity v0.5.0 (solc-js)
> Node v8.10.0

ganache-cli --version
> Ganache CLI v6.1.8 (ganache-core: 2.2.1)
```

## Testing the project

```bash
# In terminal 1 run
ganache-cli

# In terminal 2 run
truffle test
```

## Project structure

- `contracts/interfaces` contains the defined interfaces for SeraphID.
- `contracts` contains a reference implementation for demo purposes
- `test` contains unit tests

## Cryptographic functions

Ethereum cryptography is based on:

- Asymmetric cryptography: secp256k1
- Hash: Keccak256 SHA-3

**Private key / Public key / Address**
Ethereum uses ECDSA for the key handling. The algorithm in use is `secp256k1`.

- Private key: Are 256 Bits random data (32 Bytes)
- Public key: Ethereum uses uncompressed public keys. And is 65 Bytes long and starts with hex 0x04...
- Address: Are the last 20 bytes from the Keccak256 SHA-3 Hash from the public key.

More details [Mastering Ethereum](https://github.com/ethereumbook/ethereumbook/blob/develop/04keys-addresses.asciidoc)