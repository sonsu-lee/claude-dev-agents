---
description: Continuous spec alignment guard — checks after every logical step, retries on deviation
alwaysApply: true
---

# Spec Guard

## Rule: No spec, no implementation

Before writing ANY implementation code, one of the following must exist:
- Linked ticket (Linear/GitHub Issue) with defined scope
- User-confirmed scope in conversation
- Approved plan (Plan mode)

If none exist, ASK before writing code. Do not infer scope.

## Continuous spec check (after every logical step)

After completing each logical chunk of work, run a spec check immediately:

```
Spec check:
- Requested: [what the spec/ticket/plan asked for]
- Implemented: [what was actually done in this step]
- Deviation: [none | list deviations]
- Files touched: [list — are all within scope?]
```

### What counts as a "logical step"
- A component/module implementation
- A file group change (e.g. route + template + test)
- A phase boundary in a multi-step plan
- Any point where you would naturally pause and report progress

### On deviation
If the spec check finds ANY deviation:
1. Do NOT proceed to the next step
2. Fix the deviation immediately
3. Re-run the spec check
4. Only proceed when deviation is "none"

### Scope drift
- Only modify files within the defined scope
- If a change requires touching files outside scope, STOP and confirm with user
- "While I'm here" improvements are out of scope — mention, don't implement

## Exceptions

- Exploratory tasks (research, prototyping) — no spec required
- User explicitly says "just do it" or "skip spec check"
- Single-line fixes where scope is self-evident
- Code review (read-only) — use Phase 0 from code-review.md instead

## Automated Gate Integration

Spec checks are enforced at multiple levels in Agent Teams workflows:

### TaskCompleted hook (automatic)
When a task is marked complete, the TaskCompleted hook verifies:
- Acceptance criteria from the task description are satisfied
- Only assigned files were modified
- No scope drift

If the hook returns `{ok: false}`, the task completion is blocked and the agent receives feedback about what failed.

### Stop hook (spec-verification-gate)
Before the session ends, the spec-verification-gate hook verifies that at least one spec check was performed. If not, it blocks completion and requires the spec check format.

### Manual override
User can bypass automated gates by saying "skip spec check" or "just do it".
