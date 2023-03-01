# Style Guide

*TODO*

## Formatting

We use `forge fmt` to format our Solidity. The following `fmt` configuration is adhered to:
```toml
[fmt]
line_length = 120
tab_width = 4
bracket_spacing = true
int_types = 'long'
multiline_func_header = 'attributes_first'
quote_style = 'double'
number_underscore = 'preserve'
single_line_statement_blocks = 'preserve'
override_spacing = false
wrap_comments = false
ignore = []
contract_new_lines = false
```

## Contract Names

1. Contract names are strictly `UpperCamelCase`.
1. Contract names should be intuitive and describe what the purpose of the contract is.
1. If the contract is a library:  
    1. If the name of the library is one word long, use `LibName`.
    1. If the name of the library is more than one word long, use `LongNameLib`.

## Functions

1. Function names are strictly `camelCase`.  
    1. If the function is `external` or `public`, it may **not** begin with an `_underscore`.
    1. If the function is `internal` or `private`, it **must** begin with an `_underscore` unless it lives in a `library` contract.
1. Function parameters and return values always begin with an `_underscore` and are strictly `camelCase`.

**Example**

```solidity
function goodFunction(uint256 _in) external pure returns (uint256 _retParam) {}

function BadFunction(uint256 in) external pure returns (uint256 retparam) {}
```

### Documentation Comments

1. All documentation comments must be `///` style and not `/**`.
1. We use [natspec](https://docs.soliditylang.org/en/v0.8.19/natspec-format.html) tags within the documentation of our functions.

**Example**

```solidity
/// @notice This is a good comment!
function good() external pure {}

/**
 * @notice This is a bad, verbose comment.
 */
function bad() external pure {}
```

## Section Headers

Within a contract, the following ordering of elements should always be followed:
1. Immutable variables
1. Constant variables
1. Events
1. `public` / `external` variables
1. `private` / `internal` variables
1. Constructor
1. `public` / `external` functions
1. `private` / `internal` functions

Within a test contract, the following ordering of elements should always be followed:
1. Environment (Any storage variables, events, etc. required for the tests)
1. Set Up (optional)
1. Tests

> **Note**  
> `error` types are left out in the above list. All errors should be globally declared in [`src/types/Errors.sol`](./src/types/Errors.sol),
> and should never be declared within other contracts.

Above each of these sections, the following header style should be used:
```solidity
////////////////////////////////////////////////////////////////
//                   Example Section Header                   //
////////////////////////////////////////////////////////////////
```

To quickly generate a section header, use the [Comment Block Generator](https://blocks.jkniest.dev/). *TODO: Add a local script to do this*

If for any reason the above sections need to be sub-divided further, feel free to create more section headers.

## Tests

1. All contracts should receive a dedicated test file in the `test` folder, mirroring the subdirectory that they exist in within `src`. Ex. `src/L1/OptimismPortal.sol` -> `test/L1/OptimismPortal.t.sol`
    1. Invariant test contracts are always stored in `test/invariants`.
1. All test contracts should be named after the contract that they are testing: `<ContractName>_Test`
    1. If multiple test contracts exist for a single contract, these test contracts should be named `<ContractName>_<SubTest>_Test`.
1. Tests should always seek to make assertions about a specific behavior of a single function.

### Test Names

All tests follow the following naming convention, where `[brackets]` indicate optionality and `<angle brackets>` indicate requirements:
```solidity
function <test[Fuzz|Diff] | invariant>_<funcName>_[reason]_<succeeds|reverts|fails>() public {
    // Your awesome test
}
```
