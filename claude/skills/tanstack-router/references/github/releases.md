# Releases

## v1.133.37: None

**Published**: 2025-10-29

Version 1.133.37 - 10/29/25, 2:31 AM

## Changes

### Fix

- fix output path for spa shell (#5682) (80a9868) by Manuel Schiller

## Packages

- @tanstack/start-plugin-core@1.133.37
- @tanstack/solid-start@1.133.37
- @tanstack/react-start@1.133.37
- @tanstack/start-static-server-functions@1.133.37

## v1.133.36: None

**Published**: 2025-10-29

Version 1.133.36 - 10/29/25, 1:10 AM

## Changes

### Fix

- router: bump tanstack store to ^0.8 (#5680) (f9bf3a5) by Birk Skyum

## Packages

- @tanstack/router-core@1.133.36
- @tanstack/solid-router@1.133.36
- @tanstack/react-router@1.133.36
- @tanstack/solid-router-ssr-query@1.133.36
- @tanstack/react-router-ssr-query@1.133.36
- @tanstack/router-ssr-query-core@1.133.36
- @tanstack/zod-adapter@1.133.36
- @tanstack/valibot-adapter@1.133.36
- @tanstack/arktype-adapter@1.133.36
- @tanstack/router

## v1.133.35: None

**Published**: 2025-10-28

Version 1.133.35 - 10/28/25, 9:34 PM

## Changes

### Refactor

- router-core: more stable url decoding (#5663) (915de64) by Nico Lynzaad

### Test

- react-start: fix query version in server-routes (#5672) (e06cfad) by Birk Skyum
- solid-start: fix solid-query when used in ssr (#5665) (9d6c63b) by @brenelz
- solid-router: use default generated values in basic file based (#5662) (e2be32a) by Nico Lynzaad

### Docs

- solid-start: fix ssr start-basic-solid-query (#5666) (215ae1f) by Birk Skyum

#

## v1.133.34: None

**Published**: 2025-10-27

Version 1.133.34 - 10/27/25, 11:14 PM

## Changes

### Fix

- fix static server functions (#5650) (1bf65ac) by @brenelz

### Chore

- solid: bump solid to 1.9.10 (#5661) (818a4ee) by Birk Skyum

### Test

- start: fix search-params tests (#5643) (3eeeb88) by Birk Skyum
- solid-start: serialization-adapters suite (#5557) (dd8867d) by Birk Skyum
- solid-start: align search param test to react (#5657) (34bddbe) by Birk Skyum
- solid-start: fix dev server for suspense transition (#5647) (b5ac27b) by

## v1.133.33: None

**Published**: 2025-10-26

Version 1.133.33 - 10/26/25, 7:39 PM

## Changes

### Fix

- solid-start: redirect from server function (#5637) (78892de) by Birk Skyum

### Chore

- update query to consistent 5.90 (#5634) (645de23) by Birk Skyum

### Test

- solid-start: server-functions e2e (#5616) (d2ac37c) by Birk Skyum

### Ci

- apply automated fixes (f4ce824) by autofix-ci[bot]
- apply automated fixes (0bda974) by autofix-ci[bot]

## Packages

- @tanstack/solid-router-ssr-query@1.133.33
- @tanstack/react-router-ssr-query

## v1.133.32: None

**Published**: 2025-10-26

Version 1.133.32 - 10/26/25, 5:07 PM

## Changes

### Fix

- fix React router Link component in SVG elements (#5590) (9607ef6) by Durgé Seerden

### Test

- solid-router: update basic-file-based (#5633) (aefd20f) by Birk Skyum

## Packages

- @tanstack/react-router@1.133.32
- @tanstack/react-router-ssr-query@1.133.32
- @tanstack/zod-adapter@1.133.32
- @tanstack/valibot-adapter@1.133.32
- @tanstack/arktype-adapter@1.133.32
- @tanstack/router-devtools@1.133.32
- @tanstack/react-router-devtools@1.1

## v1.133.31: None

**Published**: 2025-10-26

Version 1.133.31 - 10/26/25, 10:23 AM

## Changes

### Fix

- pass server context to handler (#5601) (41cc7e1) by Samy Al Zahrani
- solid-router: isTransitioning and handleLeave/handleEnter (#5630) (e7b9041) by Birk Skyum

## Packages

- @tanstack/solid-router@1.133.31
- @tanstack/start-server-core@1.133.31
- @tanstack/solid-router-ssr-query@1.133.31
- @tanstack/solid-router-devtools@1.133.31
- @tanstack/solid-start@1.133.31
- @tanstack/solid-start-client@1.133.31
- @tanstack/solid-start-server@

## v1.133.30: None

**Published**: 2025-10-26

Version 1.133.30 - 10/26/25, 1:40 AM

## Changes

### Fix

- solid-router: apply style to link (#5628) (4c3bd6b) by Birk Skyum
- solid-router: fix external link ref (#5629) (55393f1) by Birk Skyum

## Packages

- @tanstack/solid-router@1.133.30
- @tanstack/solid-router-ssr-query@1.133.30
- @tanstack/solid-router-devtools@1.133.30
- @tanstack/solid-start@1.133.30
- @tanstack/solid-start-client@1.133.30
- @tanstack/solid-start-server@1.133.30

## v1.133.29: None

**Published**: 2025-10-25

Version 1.133.29 - 10/25/25, 11:45 PM

## Changes

### Fix

- auto discover static routes for prerendering (475707e) by @FatahChan

### Test

- solid-router: js-only-file-based e2e suite (#5626) (00efd13) by Birk Skyum
- solid-router: generator-cli-only e2e suite (#5625) (9bc2969) by Birk Skyum

## Packages

- @tanstack/router-generator@1.133.29
- @tanstack/start-plugin-core@1.133.29
- @tanstack/router-cli@1.133.29
- @tanstack/router-plugin@1.133.29
- @tanstack/router-vite-plugin@1.133.29
- @tan

## v1.133.28: None

**Published**: 2025-10-25

Version 1.133.28 - 10/25/25, 10:51 PM

## Changes

### Fix

- fix transform id regex (#5624) (eed6a79) by Manuel Schiller

### Test

- solid-router: add basepath-file-based e2e suite (#5623) (54e0be8) by Birk Skyum
- solid-router: un-skip link tests (#5621) (08d78c1) by Birk Skyum
- solid-router: fix timing in loaders test (#5622) (735c1e3) by Birk Skyum
- solid-start: sync server-routes e2e to react (#5618) (b5c96d4) by Birk Skyum
- solid: add params.spec.ts to start/router (#5617) (3ce120b) by

