# claude-dev-agents

[한국어](./README.ko.md) | [日本語](./README.ja.md)

Manage Claude Code `~/.claude/agents` + `rules` via git — sync across machines, share with teammates.

## What This Repo Does

| Before | After |
|---|---|
| agents/rules live only in `~/.claude/` | Git repo is the source of truth; `~/.claude/` is symlinked |
| Manual copy to another machine | `git pull` to sync |
| No way to share with teammates | `git clone` + `./install.sh` |

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
├── install.sh        # Symlink setup script
└── README.md
```

## Setup (One-Time)

### This Machine (Origin)

```bash
git clone git@github.com:sonsu-lee/claude-dev-agents.git
cd claude-dev-agents
chmod +x install.sh
./install.sh
```

After `install.sh`:
```
~/.claude/agents → ~/dev/projects/claude-dev-agents/agents  (symlink)
~/.claude/rules  → ~/dev/projects/claude-dev-agents/rules   (symlink)
~/.claude/agents.bak  (existing files backed up)
~/.claude/rules.bak   (existing files backed up)
```

### Another Machine / Teammates

```bash
git clone git@github.com:sonsu-lee/claude-dev-agents.git
cd claude-dev-agents
./install.sh
```

## Daily Workflow

```bash
# After editing agents (on any machine)
cd ~/dev/projects/claude-dev-agents
git add -A && git commit -m "update conductor" && git push

# Sync on another machine
cd ~/dev/projects/claude-dev-agents && git pull
# Symlinks mean ~/.claude/agents/ and rules/ update automatically
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
