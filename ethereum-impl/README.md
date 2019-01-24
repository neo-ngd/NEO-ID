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
