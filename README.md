# Rather Wallet

This project consists of a smart wallet which allows the user to save funds within it and also allows funds to be invested in different liquidity mining programs.

* [Challenge Documentation](https://drive.google.com/file/d/1GDE_1QtUvLESGJBRCUCQE820_8QU9Z-B/view?usp=sharing)

## Technologies and protocols used

This repository uses the following technologies and protocols:
* [Solidity](https://docs.soliditylang.org/en/v0.8.17/)
* [Hardhat](https://hardhat.org/docs)
* [OpenZeppelin](https://docs.openzeppelin.com/)
* [SushiSwap](https://docs.sushi.com/)

## Documentation

The information on smart contracts can be found at the following link:
* [Documentation](https://github.com/Ljrr3045/ratherLabs-smartContract-challenge/blob/master/docs/index.md)

## Getting started

The first step is to clone this repository:
```
# Get the latest version of the project
git clone https://github.com/Ljrr3045/ratherLabs-smartContract-challenge.git

# Change to home directory
cd ratherLabs-smartContract-challenge
```

To install all package dependencies run:
```
# Install all dependencies
npm i
```

Set your .env file with the following variables:
* [.env.example](https://github.com/Ljrr3045/ratherLabs-smartContract-challenge/blob/master/.env.example)

## Useful commands

```
# Compile contracts
npm run build:contracts

# Run tests
npm run test:contracts

# Run contracts coverage
npm run coverage:contracts

# Run deploy script
npm run deploy:contracts

# Generate documentation
npm run doc:contracts
```

