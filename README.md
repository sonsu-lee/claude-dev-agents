# claude-dev-agents

[한국어](./README.ko.md) | [日本語](./README.ja.md)

Manage Claude Code `~/.claude/agents` + `rules` via git — sync across machines, share with teammates.

## What This Repo Does

| Before | After |
|---|---|
| agents/rules live only in `~/.claude/` | Git repo is the source of truth; installed via copy |
| Manual copy to another machine | `git pull && ./install.sh` to sync |
| No way to share with teammates | `git clone` + `./install.sh` |
| Same config leaks into other AI CLIs | Project-level install keeps configs isolated |

## Repo Structure

```
claude-dev-agents/
├── agents/           # 30 agent definitions (.md)
│   ├── conductor.md          # Lead — planning, task decomposition
│   ├── dev-lead.md           # Lead — dev planning/review
│   ├── quality-lead.md       # Lead — quality gates
│   ├── frontend-dev.md       # Worker — React/CSS
│   ├── backend-dev.md        # Worker — API/server
│   ├── code-reviewer.md      # Reviewer — code review
│   ├── security-auditor.md   # Reviewer — security audit
│   ├── tenth-man.md          # Reviewer — devil's advocate
│   └── ...                   # 22 more
├── rules/            # 6 governance rules (.md)
│   ├── harness-system.md     # Lead/Worker/Reviewer role boundaries (alwaysApply)
│   ├── team-lead.md          # Agent Teams orchestration (alwaysApply)
│   ├── spec-guard.md         # Spec consistency checks (alwaysApply)
│   ├── skill-dispatch.md     # Context-based skill/agent routing (alwaysApply)
│   ├── tool-priority.md      # Duplicate tool priority (alwaysApply)
│   └── code-review.md        # PR review checklist (on-demand)
├── install.sh        # Copy-based install script
└── README.md
```

## Setup

### Install to a Project (default)

```bash
cd ~/dev/my-app
~/dev/personal/claude-dev-agents/install.sh
```

Copies `agents/` and `rules/` into `~/dev/my-app/.claude/`.
Each project gets its own copy — no interference with Codex or other AI CLIs.

### Install Globally

```bash
./install.sh --global
```

Copies into `~/.claude/` (applies to all projects).

### Remove Old Symlinks

If you previously used the symlink-based install:

```bash
./install.sh --unlink
```

### Sync After Updates

```bash
cd ~/dev/personal/claude-dev-agents && git pull

cd ~/dev/my-app && ~/dev/personal/claude-dev-agents/install.sh  # re-copy to project
```

## Agent System Architecture

```
Harness Structure (harness-system.md):
  Lead (read-only, orchestration)  → conductor, dev-lead, quality-lead, ops-lead, research-lead
  Worker (full tools, execution)   → frontend-dev, backend-dev, fullstack-dev, database-eng, ...
  Reviewer (read-only, audit)      → code-reviewer, security-auditor, tenth-man, arch-advisor, ...

Orchestration (team-lead.md):
  Plan → Contract → Wave → Gate → Review
  Execution Gate (build/test) + Spec Check between each wave

Model Tiering:
  opus   — leaders/judgment (conductor, dev-lead, quality-lead, debugger, arch-advisor, tenth-man)
  sonnet — execution/analysis (most workers, reviewers)
  haiku  — lightweight tasks (dep-updater, doc-researcher, type-checker)
```

## Notes

- **settings.json not included** — contains personal permissions and plugin lists (varies per user)
- **CLAUDE.md not included** — personal workflow preferences
- Only `agents/` and `rules/` are shared by design
