---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(gh issue:*)
description: Create a New Issue
---

Create a new issue in the repository using the gh cli with an appropriate title, relevant file paths, and links to documentation if applicable using the following context: #$ARGUMENTS

# Instructions

1. For each url provided in the context use the `mcp__crawling_exa` to extract essential information.
2. Think deeply about the cleanest implementation strategy prior to creating the issue.
3. Add all File Paths affected and docs resources under a section in h2 for Context. If you cannot determine the file paths associated with the task then ask the user.
4. Add Acceptance criteria as the last section with checkboxes under an h2 section. Ensure that the Acceptance Criteria enables Test-Driven Development.
5. Always ensure issues are created in the same format as the Example in the final section

# Guidelines

- Always keep the title short and descriptive so that it can be recorded as a single line in a changelog entry
- Always include any expected data types as code formatted examples if necessary
- Always include the relevant file paths of expected files to be changed
- Always keep the issue body as succinct as possible with only essential context
- If protobuf or sql files will be changed with this issue add the 'breaking' label to the issue
- Always assign the Issue to @prnk28

# Label List

NAME               DESCRIPTION                                                                    COLOR
bug                Something isn't working                                                        #d73a4a
documentation      Documentation improvements or additions                                        #0075ca
duplicate          This issue or pull request already exists                                      #CFD3D7
enhancement        Improvement to existing functionality                                          #a2eeef
feature            New feature or request                                                         #0e8a16
good first issue   Good for newcomers                                                             #7057ff
help wanted        Extra attention is needed                                                      #008672
logical            Needs logical implementation for function                                      #D6DC3B
question           Further information is requested                                               #D4A5A5
dependencies       Dependency updates                                                             #0366d6
database           Database changes, migrations, or queries                                       #1ABC9C
webauthn           WebAuthn authentication and credentials                                        #FF7F0E
refactor           Code restructuring without changing functionality                              #d62728
enhance            Performance or usability improvements (use 'enhancement' instead)              #9467bd
api                REST, gRPC, or WebAuthn API changes                                            #2ECC71
backend            Core blockchain logic and keeper implementations                               #27AE60
config             Configuration files, parameters, or setup                                      #16A085
modules            Cosmos SDK module changes (use specific x/* labels instead)                    #17becf
observability      Monitoring, logging, metrics, and debugging                                    #FF6B6B
testing            Unit, integration, or e2e tests                                                #4ECDC4
deploy             Docker, Kubernetes, or deployment configs                                      #2496ED
ipfs               IPFS integration and decentralized storage                                     #65C2CB
devtools           Development tooling, build scripts, or IDE                                     #7F8C8D
testnet            Testnet configurations and deployments                                         #8B5A3C
breaking           Breaking changes requiring migration                                           #B60205
docs               Documentation updates (alias)                                                  #0366D6
w3c                W3C standards compliance (DID, WebAuthn, etc.)                                 #005A9C
x/did              Decentralized Identity module                                                  #9B59B6
cross-chain        Multi-chain integrations and protocols                                         #E67E22
ibc                Inter-Blockchain Communication protocol                                        #F39C12
ica                Interchain Accounts functionality                                              #F1C40F
x/dwn              Decentralized Web Node module                                                  #3498DB
x/ucan             User Controlled Authorization Networks module                                  #E74C3C
polish             Code cleanup, formatting, or minor improvements                                #FFEAA7
javascript         JavaScript code changes                                                        #F7DF1E
pkg/dns            DNS package and resolution                                                     #0052CC
pkg:ipfs           IPFS package and storage                                                       #4A90E2
pkg/vaults         Vaults package and secure storage                                              #2E86DE
x/svc              Service module                                                                 #5DADE2
x/dex              Decentralized Exchange module                                                  #AF7AC5
sdk                                                                                               #ededed
pkg                                                                                               #ededed
security                                                                                          #ededed
cli                                                                                               #ededed
test                                                                                              #ededed
security/critical  Critical security vulnerability requiring immediate attention (CVSS 9.0-10.0)  #B60205
security/high      High priority security issue requiring prompt resolution (CVSS 7.0-8.9)        #D93F0B
security/medium    Medium priority security issue (CVSS 4.0-6.9)                                  #FBCA04
security/low       Low priority security improvement (CVSS 0.1-3.9)                               #0E8A16
go                 Pull requests that update go code                                              #16e2e2

# Example

An example issue should be formatted as:

```md
Title: Implement x/dwn vaults plugin
Labels: x/dwn, feature

## Requirements

- Must include DWN Bytes in Protobuf
- Must Spawn DWN Plugins using Genesis Params
- Must have Gas Free Query Methods for Spawn and Verify

## Context

### Affected Files

- @x/dwn/keeper/keeper.go
- @x/dwn/client/wasm/main.go
- @x/dwn/types/genesis.go

### Relevant Documentation

- [Example Doc 1](https://example.com)
- [Example Doc 2](https://example.com)

## Acceptance Criteria

- [ ] Tests for Spawning Plugins from the x/dwn Genesis
- [ ] Tests for Resolving Vault Secret Data from IPFS
- [ ] Test for full-round Sign/Verify/Refresh on-chain
- [ ] Grpc Gateway Compatibility for HTTP Requests
```
