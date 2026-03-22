---
description: Code review checklist for PR scope, test coverage, and integration — supplements CLAUDE.md quality criteria
alwaysApply: false
---

# Code Review Checklist

Supplements CLAUDE.md core criteria (concise, readable, safe, root cause). Focus here is PR-level review.

## Phase 0: Context Establishment

Before reading any code, establish WHY the change was made and WHAT is in scope.

### PR review
1. Fetch linked ticket (Linear/GitHub Issue) — understand goal and acceptance criteria
2. Read PR description — author's intended scope and approach
3. Identify baseline: `git diff <base>...HEAD` to see what THIS PR introduced
4. Compare modified files against base branch — only flag issues introduced by this PR
5. Verify PR description accuracy vs actual diff (files listed, claims made)

### Non-PR review (file/commit)
1. Ask user for review purpose and scope before starting
2. Use git blame to distinguish "changed in this work" from pre-existing code

### Baseline rule
- Pre-existing code issues are NOT review targets (mention separately if critical)
- Mechanical copies (e.g. V1 snapshots) — verify only import/reference changes against original
- New patterns introduced by the PR — compare with how existing code handles the same case

## Scope

- Changes match the stated goal — no unrelated refactors or drive-by fixes
- Each commit is atomic and self-contained
- No files that shouldn't be in the diff (generated, env, lock file churn)

## Tests

- New behavior has test coverage
- Edge cases covered: empty input, boundary values, error paths
- Tests verify behavior, not implementation details
- No flaky tests introduced (timing, order-dependent, network-dependent)

## Integration

- API contracts match between caller and callee
- DB migrations are reversible
- No breaking changes to public interfaces without version bump
- Error responses follow existing patterns

## Security (quick scan)

- No secrets, tokens, or credentials in diff
- User input validated before use
- Auth/authz checks present on new endpoints
