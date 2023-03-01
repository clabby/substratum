<img align="right" width="150" height="150" top="100" src="./assets/logo.png">

# substratum • [![tests](https://github.com/clabby/substratum/actions/workflows/test.yml/badge.svg?label=tests)](https://github.com/clabby/substratum/actions/workflows/test.yml) ![license](https://img.shields.io/github/license/clabby/substratum?label=license)

`substratum` is an opinionated, spec-compliant, optimized version of Optimism's [contracts-bedrock](https://github.com/ethereum-optimism/optimism/tree/develop/packages/contracts-bedrock) package.

**High-level goals**
- :broom: Clean up tech debt in `contracts-bedrock`
- :zap: Optimize
    - :heavy_dollar_sign: Support a custom calldata encoding scheme, with legacy support for ABI-encoder-V2 style calldata in the fallbacks.
- :test_tube: Have higher test coverage than `contracts-bedrock`
    - :balance_scale: Differential test this implementation against `contracts-bedrock`
    - :hammer_and_wrench: Favor forge invariants over Echidna.
- :scroll: Improve documentation (`forge doc`)
- :bomb: Nuke OZ from the Optimism contracts codebase.
    - :house_with_garden: Also trim other dependencies in favor of in-house contracts.
- :bangbang: Move to custom errors.
- :dizzy: Use custom types for values such as hashes, gas limits, timestamps, balances, etc.
- :package: Support legacy contract storage layouts, but refactor for new slots going forward.

## Contributing
See [CONTRIBUTING.md](./CONTRIBUTING.md).

## TODO

**Stage 0: Repo setup**
- [x] Add license (MIT)
- [ ] Workflows
- [ ] [`STYLE_GUIDE.md`](./STYLE_GUIDE.md)
- [ ] Task list

**Stage 1: Port / Rewrite Libraries**
- [ ] [`Arithmetic.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/libraries/Arithmetic.sol)
- [ ] [`Bytes.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/libraries/Bytes.sol)
- [ ] [`Burn.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/libraries/Burn.sol)
- [ ] [`Constants.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/libraries/Constants.sol)
- [ ] [`Encoding.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/libraries/Encoding.sol)
    - Depends on: `Hashing.sol` & `RLPWriter.sol`
- [ ] [`Hashing.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/libraries/Hashing.sol)
    - Depends on: `Encoding.sol`
- [ ] [`Predeploys.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/libraries/Predeploys.sol)
- [ ] [`SafeCall.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/libraries/SafeCall.sol)
- [x] [`Types.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/libraries/Types.sol)
- **RLP:**
    - [ ] [`RLPReader.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/libraries/rlp/RLPReader.sol)
    - [ ] [`RLPWriter.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/libraries/rlp/RLPWriter.sol)
- **Trie (? - Might not be worth with Claim-based withdrawals around the corner.)**
    - [ ] [`MerkleTrie.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/libraries/trie/MerkleTrie.sol)
    - [ ] [`SecureMerkleTrie.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/libraries/trie/SecureMerkleTrie.sol)

**Stage 2: Universal Contracts**
*TODO*

**Stage 3: L1 Contracts**
*TODO*

**Stage 4: L2 Contracts**
*TODO*

**Stage 5: Deployment Contracts**
*TODO*

**Stage 6: Rewrite test scripts in Go**
*TODO*


