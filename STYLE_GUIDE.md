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
