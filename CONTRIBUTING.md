# Contributing

First of all, thank you for wanting to contribute :heart: Any and all contributors are welcome!

Before creating a PR, please make sure you've read this short document.

### Feature Parity with `contracts-bedrock`

As `substratum` is not the canonical implementation of the Bedrock contracts, the initial goal is to reach parity with
the behavior of `contracts-bedrock`. Because `contracts-bedrock` is in active development, this unfortunately makes for
a moving target, but this should be easier to deal with once the implementation reaches maturity.

### Security

Due to the above, any divergence in the behavior of `substratum`'s contracts from their counterparts in `contracts-bedrock` is 
**considered a *high-severity* bug**.

## Pull Request Process

**Pre-flight checklist**
1. Is the code that you're submitting licensed under another license than MIT? `substratum` is MIT licensed, and cannot
   accept contributions that contain code with differing licenses.
1. Have you consulted the [`Style Guide`](./STYLE_GUIDE.md)? PRs with changes that do not adhere to the style guide will not be merged.
1. Have you written accompanying tests and/or modified existing tests for your changes?
    1. Do your tests pass?
1. Have you ran `forge fmt`?

**Review Process**
1. While `substratum` is in development, PRs will require only one authorized approval to be merged. Once your PR is approved, feel free to merge it yourself if the
   reviewer did not do so for you.
1. We'll do our best to submit timely reviews - if your PR has remained stale for a few days, feel free to reach out to an authorized reviewer.
