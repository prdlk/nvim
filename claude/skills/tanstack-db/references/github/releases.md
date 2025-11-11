# Releases

## @tanstack/query-db-collection@0.2.37: @tanstack/query-db-collection@0.2.37

**Published**: 2025-10-27

### Patch Changes

-   **Behavior change**: `utils.refetch()` now uses exact query key targeting (previously used prefix matching). This prevents unintended cascading refetches of related queries. For example, refetching `['todos', 'project-1']` will no longer trigger refetches of `['todos']` or `['todos', 'project-2']`. ([#552](https://github.com/TanStack/db/pull/552))

    Additionally, `utils.refetch()` now bypasses `enabled: false` to support manual/imperative refetch patterns (matching TanS

## @tanstack/vue-db@0.0.69: @tanstack/vue-db@0.0.69

**Published**: 2025-10-24

### Patch Changes

-   Updated dependencies \[[`970616b`](https://github.com/TanStack/db/commit/970616b6db723d1716eecd5076417de5d6e9a884)]:
    -   @tanstack/db@0.4.14


## @tanstack/trailbase-db-collection@0.1.36: @tanstack/trailbase-db-collection@0.1.36

**Published**: 2025-10-24

### Patch Changes

-   Updated dependencies \[[`970616b`](https://github.com/TanStack/db/commit/970616b6db723d1716eecd5076417de5d6e9a884)]:
    -   @tanstack/db@0.4.14


## @tanstack/svelte-db@0.1.36: @tanstack/svelte-db@0.1.36

**Published**: 2025-10-24

### Patch Changes

-   Updated dependencies \[[`970616b`](https://github.com/TanStack/db/commit/970616b6db723d1716eecd5076417de5d6e9a884)]:
    -   @tanstack/db@0.4.14


## @tanstack/solid-db@0.1.36: @tanstack/solid-db@0.1.36

**Published**: 2025-10-24

### Patch Changes

-   Updated dependencies \[[`970616b`](https://github.com/TanStack/db/commit/970616b6db723d1716eecd5076417de5d6e9a884)]:
    -   @tanstack/db@0.4.14


## @tanstack/rxdb-db-collection@0.1.25: @tanstack/rxdb-db-collection@0.1.25

**Published**: 2025-10-24

### Patch Changes

-   Updated dependencies \[[`970616b`](https://github.com/TanStack/db/commit/970616b6db723d1716eecd5076417de5d6e9a884)]:
    -   @tanstack/db@0.4.14


## @tanstack/react-db@0.1.36: @tanstack/react-db@0.1.36

**Published**: 2025-10-24

### Patch Changes

-   Updated dependencies \[[`970616b`](https://github.com/TanStack/db/commit/970616b6db723d1716eecd5076417de5d6e9a884)]:
    -   @tanstack/db@0.4.14


## @tanstack/query-db-collection@0.2.36: @tanstack/query-db-collection@0.2.36

**Published**: 2025-10-24

### Patch Changes

-   Updated dependencies \[[`970616b`](https://github.com/TanStack/db/commit/970616b6db723d1716eecd5076417de5d6e9a884)]:
    -   @tanstack/db@0.4.14


## @tanstack/electric-db-collection@0.1.38: @tanstack/electric-db-collection@0.1.38

**Published**: 2025-10-24

### Patch Changes

-   Updated dependencies \[[`970616b`](https://github.com/TanStack/db/commit/970616b6db723d1716eecd5076417de5d6e9a884)]:
    -   @tanstack/db@0.4.14


## @tanstack/db@0.4.14: @tanstack/db@0.4.14

**Published**: 2025-10-24

### Patch Changes

-   Fix collection cleanup to fire status:change event with 'cleaned-up' status ([#714](https://github.com/TanStack/db/pull/714))

    Previously, when a collection was garbage collected, event handlers were removed before the status was changed to 'cleaned-up'. This prevented listeners from receiving the status:change event, breaking the collection factory pattern where collections listen for cleanup to remove themselves from a cache.

    Now, the cleanup process:

    1.  C

