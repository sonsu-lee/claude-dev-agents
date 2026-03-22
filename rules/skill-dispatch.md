---
alwaysApply: true
---

# Skill & Agent Dispatch Guide

Which skill/agent to use for each situation. Applies across all projects.

## Single Session (no Agent Teams)

| Situation | Tool | Notes |
|-----------|------|-------|
| Bug/error investigation | `systematic-debugging` skill | No Plan mode needed |
| Understanding code structure | `feature-dev:code-explorer` agent | Read-only exploration |
| Feature development | `brainstorming` → `feature-dev` skill | Clarify requirements first |
| Complex task planning | Plan mode → `plan-exit-review` | Validate before implementation |
| Before claiming completion | `verification-before-completion` skill | Always verify first |
| CSS/layout bugs | `frontend:css-craftsman` skill | Visual rendering diagnosis |
| Figma to code | `figma:implement-design` skill | Requires Figma URL |
| Text polishing | `humanizer` (AI traces) / `lang-polish` (multilingual) | |
| React performance | `vercel-react-best-practices` skill | |
| Component API design | `frontend:component-craft` skill | Shared/reusable components |
| Design system audit | `frontend:design-system-audit` skill | Token compliance, Figma sync |
| Parallel independent tasks | `dispatching-parallel-agents` skill | 2+ independent tasks |
| Research / fact-check | `deep-research` skill | Auto: search/verify/compare/quick/deep |
| Risk assessment | `governance:risk-gate` skill | Permissions, sandbox, sensitive ops |
| Multi-agent planning | `governance:orchestrator` skill | Task decomposition for teams |
| Document creation | `document-skills` plugin | PDF, PPTX, XLSX, DOCX |
| PR review (others' PR) | `code-review.md` rule → ticket + diff baseline | Phase 0 context first |
| PR self-review (before PR) | `pr-review-toolkit:review-pr` skill | Local changes only |
| GitHub PR comment review | `code-review` skill | Posts gh pr comment |

## Agent Teams (multi-agent)

For Agent Teams workflows, see `team-lead.md` rule. Key differences:
- Lead spawns teammates from `~/.claude/agents/`
- Lead includes skill instructions in spawn prompts
- Teammates invoke skills themselves during execution

## Composition Rules

- Always run `plan-exit-review` before exiting Plan mode
- Run `plan-exit-review` after feature-dev Phase 4, before starting Phase 5
- Run `verification-before-completion` before claiming work is done
- Run **"Spec check:"** after every logical step — fix deviations before proceeding (spec-guard rule enforces)
- Run `governance:risk-gate` before tasks touching permissions or production
