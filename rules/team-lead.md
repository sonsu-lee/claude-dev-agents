---
alwaysApply: true
---

# Agent Teams Orchestration Guide

When a task is complex enough to warrant multiple agents, orchestrate via Agent Teams.

## Core Principles (from verified multi-agent research)

1. **Generator ≠ Verifier** — The agent that produces output must NOT be the only one that checks it
2. **Execution > Review** — Running code/tests is more reliable than LLM-based review. Use execution gates wherever possible, LLM review only for non-executable artifacts
3. **Structured handoffs** — Pass artifacts (not raw dialogue) between agents. Each handoff must follow a defined format
4. **Bounded iteration** — Every feedback loop needs an exit condition. Max 3 retries per gate
5. **Role independence > role count** — Start with minimum viable team. Agents that verify should NOT see generator's reasoning process

## When to Use Agent Teams

| Situation | Approach |
|-----------|----------|
| Single file, simple fix | Direct — no delegation |
| Focused subtask | Subagent (Agent tool, no team) |
| Multi-file, cross-layer, or parallel review | **Agent Teams** |

## Team Composition

Start with **minimum viable team** (2 agents: worker + reviewer), scale up only when needed.

| Category | Teammates to Spawn |
|----------|-------------------|
| **Feature implementation** | dev-lead + relevant workers (frontend-dev, backend-dev, test-writer, etc.) |
| **Code review** | quality-lead + code-reviewer, security-auditor, etc. |
| **Research / investigation** | research-lead + codebase-explorer, tech-scout, etc. |
| **Refactoring / migration** | ops-lead + refactorer, migrator, etc. |
| **Architecture decision** | conductor (planning) + arch-advisor + tenth-man (challenge) |
| **CSS / styling** | frontend-dev (direct, often no team needed) |
| **Bug investigation** | debugger (direct or with codebase-explorer) |

## Workflow: Plan → Contract → Wave → Gate → Review

### Phase 1: Plan (Lead does this directly)
1. Analyze scope, identify affected files
2. Define **contracts** between teammates (API shapes, shared types, file boundaries)
3. Create tasks with explicit file ownership — no two teammates touch the same file
4. Define **acceptance criteria** per task (what "done" looks like)

### Phase 2: Execute in Waves with Gates

Each wave follows: **Execute → Verification Gate → Wave Review**

```
Wave 1: Independent tasks (parallel)
    ↓
  [Execution Gate] — run tests/build on Wave 1 output
    ↓
  [Wave Review] — lead checks: proceed / fix / abort
    ↓
Wave 2: Dependent tasks (after Wave 1)
    ↓
  [Execution Gate]
    ↓
  [Wave Review]
    ↓
Wave 3: Integration + final verification
    ↓
  [Final Quality Gate]
```

### Verification Gate (between every wave)

Run in this order — execution first, review second:

1. **Execution check** (mandatory): run tests, build, lint
   - Pass → proceed to review
   - Fail → return to workers with error output (max 3 retries)
2. **LLM review** (for non-executable artifacts): code-reviewer or quality-lead evaluates
   - Only for design docs, API contracts, architecture decisions
   - Code quality review is secondary to test results

### Wave Review (lead decides direction)

After each gate, lead evaluates:
- **Proceed**: gate passed, move to next wave
- **Fix**: specific issues found, send back to workers (with structured feedback)
- **Pivot**: scope change needed, update plan before continuing
- **Abort**: fundamental problem, escalate to user

### Phase 3: Delegate Mode
After spawning teammates, press **Shift+Tab** to enter delegate mode.
In delegate mode, the lead coordinates only — no direct code changes.

## Structured Handoff Format

Agents communicate via structured artifacts, NOT free-form messages.

### Task output (worker → lead)
```
Status: complete | blocked | needs-review
Files changed: [list]
What was done: [1-2 sentences]
Acceptance criteria met: [yes/no per criterion]
Test results: [pass/fail summary]
Blockers: [if any]
```

### Review output (reviewer → lead)
```
Verdict: pass | conditional-pass | fail
Critical issues: [count] — [list with file:line]
Major issues: [count] — [list with file:line]
Suggestions: [count] — [brief list]
```

### Feedback (lead → worker on fix)
```
Issue: [specific problem]
File: [path:line]
Expected: [what should happen]
Actual: [what happens now]
Evidence: [test output or review finding]
```

## Review Handoff Protocol (Context Isolation)

When passing work from builders to reviewers, strip builder reasoning.

### Include in reviewer handoffs
```
Review Scope:
- Files: [modified file paths]
- Spec: [original requirements / ticket]
- Acceptance Criteria: [task completion conditions]
- Diff summary: [what changed, factually]
```

### Never include
- Builder's reasoning or decision process
- Alternatives the builder considered and rejected
- Debugging history or trial-and-error
- Builder's self-assessment of the code

Builder reasoning biases reviewers — attention budget shifts from independent analysis to confirming the builder's narrative. Clean slate produces better reviews.

## Task Assignment Rules

- Assign tasks with explicit file paths: `TaskCreate("Implement login form", files: src/components/Login.tsx)`
- Include acceptance criteria in every task description
- Use `blockedBy` for dependencies between tasks
- Let teammates self-claim unassigned tasks via `TaskUpdate`
- **Independence rule**: test-writer should NOT see implementation reasoning — only the spec/requirements

## Teammate Communication

- `SendMessage(to="frontend-dev", message="...")` — direct messaging
- Teammates can message each other without going through lead
- Broadcast to all: message each teammate individually
- Use structured handoff format for all status updates

## Skill Injection for Teammates

When spawning a teammate, include relevant skill invocation instructions in the spawn prompt.
Teammates have access to installed skills but won't auto-invoke them — explicitly direct usage.

### Skill → Teammate Mapping

| Teammate | Skills to include in spawn prompt |
|----------|----------------------------------|
| **frontend-dev** | `vercel-react-best-practices`, `vercel-composition-patterns`, `frontend-design` or `web-design-guidelines` |
| **backend-dev** | `postgres` or `mysql` for DB queries, `find-docs` for library references |
| **fullstack-dev** | `vercel-react-best-practices` for frontend, `postgres`/`mysql` for backend |
| **database-eng** | `postgres`, `mysql`, `vitess`, or `neki` depending on DB engine |
| **debugger** | `systematic-debugging` for structured root cause analysis |
| **test-writer** | `test-driven-development` if available |
| **code-reviewer** | `code-review` plugin for structured review |
| **security-auditor** | `security-guidance` plugin for OWASP patterns |
| **a11y-reviewer** | `web-design-guidelines` for design system compliance |
| **infra-engineer** | `terraform-style-guide` and `terraform-test`, HashiCorp and antonbabenko plugins |
| **doc-writer** | `humanizer` to remove AI artifacts from text |
| **doc-researcher** | `find-docs` for official documentation lookup |
| **arch-advisor** | `plan-exit-review` to validate architectural decisions |
| **conductor** | `plan-exit-review` before finalizing plans |
| **refactorer** | `code-simplifier` plugin for post-refactoring cleanup |
| **ci-engineer** | `find-docs` for CI/CD platform documentation |

### Available Plugin Ecosystem (installed)

Lead can suggest any of these in spawn prompts:
- **superpowers**: brainstorming, writing-plans, verification-before-completion, systematic-debugging, TDD
- **feature-dev**: guided feature development (code-explorer, code-architect, code-reviewer agents)
- **pr-review-toolkit**: structured PR review (code-reviewer, silent-failure-hunter, comment-analyzer)
- **frontend (sonsu)**: css-inspector, design-system-auditor, css-craftsman, component-craft
- **code-review**: standalone code review
- **code-simplifier**: simplify and refine code
- **ralph-loop**: recursive quality gate until completion
- **document-skills**: PDF, PPTX, XLSX, DOCX creation + frontend-design
- **hashicorp**: terraform-code-generation, terraform-module-generation, terraform-provider-development, packer
- **serena**: symbolic code analysis (get_symbols_overview, find_referencing_symbols)
- **linear**: issue tracking (get_issue, save_issue, list_issues)
- **figma**: design-to-code (get_design_context, get_screenshot)
- **context7**: official docs lookup (resolve-library-id, query-docs)
- **research (sonsu)**: deep-research multi-phase pipeline
- **governance (sonsu)**: risk-check, ops-check, team-plan
- **lang-polish (sonsu)**: EN/JA text polishing

### Example Spawn Prompt with Skills

```
Spawn frontend-dev as teammate for auth-team:
"Implement the login form component at src/components/Login.tsx.
Use the vercel-react-best-practices skill for React patterns.
Use the frontend:css-craftsman skill if you encounter layout issues.
Acceptance criteria:
- Form renders with email/password fields
- Client-side validation on submit
- Calls POST /api/auth/login
- Error state displayed on failure
Report back using structured handoff format."
```

## Quality Gate System

### Level 1: Task Gate (automatic via TaskCompleted hook)
Runs automatically when any task is marked complete:
- Acceptance criteria from task description are met
- Only files listed in the task were modified
- No scope drift detected
- Hook blocks completion (exit 2) if any check fails

### Level 2: Wave Gate (lead runs between waves)
After each wave completes:
1. **Execution check** (mandatory): build + test + lint
2. **Spec check** (mandatory): compare wave output against spec
3. On failure → create fix task → re-validate (max 3 retries)
4. After 3 failures → escalate to user

### Level 3: Final Gate (before marking team work complete)
1. All tasks status = completed
2. Execution gate passed: build + tests + lint all green
3. Full spec check: compare all delivered work against original requirements
4. If quality-lead was spawned, its review report has 0 critical issues
5. Consider spawning tenth-man for final challenge on important decisions

### Rollback Protocol
When spec deviation is detected at any gate:
1. Create fix task with specific deviation details (Issue, File, Expected, Actual, Evidence)
2. Assign to the original worker
3. Worker fixes → re-run the gate that caught the deviation
4. Max 3 fix cycles per deviation — after that, escalate to user
5. If fix introduces new deviation, treat as new issue (separate counter)

### Escalation Triggers
- Max retries exhausted (3 per deviation)
- Scope change required (touches files outside original plan)
- Contradictory acceptance criteria discovered
- Build/test infrastructure failure (not code issue)
