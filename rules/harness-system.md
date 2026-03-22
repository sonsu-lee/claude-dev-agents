---
description: Defines three harness categories (Lead, Worker, Reviewer) with structural constraints for agent teams
alwaysApply: true
---

# Harness System

Agent harnesses define structural constraints during team execution. Each agent belongs to exactly one harness category. These are enforced boundaries, not suggestions.

## Lead Harness

**Agents**: conductor, quality-lead, dev-lead, ops-lead, research-lead

| Dimension | Constraint |
|-----------|-----------|
| Context | Full task scope, spec, architecture, team status |
| Tools | Read-only (Read, Glob, Grep) |
| Verification | Spec check required before wave transitions and final gate |
| Escalation | To user when: scope ambiguity, spec deviation, max retries exhausted |
| File access | No modifications — plans and coordinates only |

### Lead responsibilities
- Decompose work into tasks with explicit file ownership
- Run spec checks at wave boundaries
- Gate decisions: proceed / fix / pivot / abort
- Strip builder reasoning before passing to reviewers (context isolation)

## Worker Harness

**Agents**: frontend-dev, backend-dev, fullstack-dev, test-writer, database-eng, infra-engineer

| Dimension | Constraint |
|-----------|-----------|
| Context | Only assigned task description + listed files |
| Tools | Full (Read, Glob, Grep, Write, Edit, Bash) |
| Verification | Self-test before reporting complete (build, lint, or test must pass) |
| Escalation | To lead when: blocked, scope unclear, file conflict |
| File access | Only files listed in task assignment |

### Worker responsibilities
- Implement within assigned file boundaries
- Run relevant checks before marking task complete
- Report via structured handoff format
- Never modify files outside task scope — report the need, don't act

## Reviewer Harness

**Agents**: code-reviewer, security-auditor, tenth-man, arch-advisor, perf-analyst

| Dimension | Constraint |
|-----------|-----------|
| Context | Artifacts only — files, diff, spec, acceptance criteria |
| Tools | Read-only (Read, Glob, Grep) |
| Verification | Structured report with severity ratings required |
| Escalation | To lead with verdict (pass / conditional-pass / fail) |
| File access | Read-only — never modify code |
| Isolation | No access to builder reasoning (clean slate) |

### Context isolation (clean slate pattern)
- Receives only: file paths, diff summary, spec, acceptance criteria
- Does NOT receive: builder's reasoning, decision process, debug history
- Reads code directly and forms independent conclusions
- If builder reasoning is accidentally included, ignore it

### Reviewer responsibilities
- Read code independently — do not rely on builder's explanation
- Rate findings by severity (critical > major > minor > nitpick)
- Include file:line references for every finding
- Provide actionable suggestions, not just problem descriptions

## Cross-cutting Rules

### Scope enforcement
- Workers: only assigned files
- Leads: coordination only, no direct implementation
- Reviewers: analysis only, no modifications

### Handoff format
All inter-agent communication uses the structured handoff format defined in team-lead.md. Free-form messages are for clarification only, not status updates.
