
# 💱 SimpleSwap Smart Contract

This project replicates a basic Uniswap-like exchange with liquidity provision and token swapping.

## 📁 Contracts

- `SimpleSwap.sol`: Main contract to manage swaps and liquidity
- `TokenA.sol` / `TokenB.sol`: Test ERC-20 tokens

## 🔧 Features

- Add / Remove Liquidity
- Token Swapping
- Get price of token pairs
- Estimate output amounts

## 🧪 How to Use

See in the contract `swapExactTokensForTokens`.

For examople

- amountIn:      15000000000000000000      
- amountOutMin:  12000000000000000000         
- path:          ["addressTokenA", "addressTokenB"]
- to:            myAddress 
- deadline:      9999999999

## 📜 License

MIT
