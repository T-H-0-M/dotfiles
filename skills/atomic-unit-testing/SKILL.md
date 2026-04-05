---
name: atomic-unit-testing
description: >-
  Enforces atomic, deterministic unit tests with focused assertions and core
  branch coverage. Use when writing, editing, or reviewing unit tests
  (Jest/describe/it), mocks, or test setup; when the user asks for tests or test
  fixes; or when touching *.test.ts, *.test.tsx, or __tests__ under core app or
  services logic.
---

# Atomic unit testing

Apply these rules for **every new or changed test** that touches **core modules** (app, services, shared logic).

## Atomic structure

- Use **one behavior branch** per `it(...)`.
- Use **one trigger or action** per test.
- Assert **one primary outcome** per test.
- Do **not** combine multiple branches in a single scenario.

## Determinism

- **Freeze time** (fake timers / fixed dates) for date-sensitive logic.
- **Stub randomness** (`Math.random`, UUID generators) when behavior depends on it.
- **Mock boundaries**: network, notifications, purchases, router, storage, and other native/runtime APIs.
- Avoid **real device or runtime side effects** in unit tests.

## Core branch coverage

- Cover at least **one guard or validation** path.
- Cover at least **one failure or error** path.
- Cover **platform or premium branching** when the production code has it.

## Hygiene

- **Clear or reset mocks** between tests (`afterEach` / `beforeEach` as appropriate).
- Do **not** rely on order or leftover state from other tests.
- Keep assertions **behavior-oriented**; avoid noisy checks on implementation details.
