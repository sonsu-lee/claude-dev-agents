# claude-config

~/.claude/agents + rules를 git으로 관리하여 머신 간 동기화 + 팀원 배포.

## 이 레포가 하는 일

| 전 | 후 |
|---|---|
| agents/rules가 ~/.claude/에만 존재 | git repo가 원본, ~/.claude/는 심링크 |
| 머신 B에 수동 복사 | git pull 한 줄로 동기화 |
| 팀원에게 공유 불가 | git clone + ./install.sh |

## 레포 구조

```
claude-config/
├── agents/           # 30개 에이전트 정의 (.md)
│   ├── conductor.md          # Lead — 플래닝, 태스크 분해
│   ├── dev-lead.md           # Lead — 개발 계획/리뷰
│   ├── quality-lead.md       # Lead — 품질 게이트
│   ├── frontend-dev.md       # Worker — React/CSS
│   ├── backend-dev.md        # Worker — API/서버
│   ├── code-reviewer.md      # Reviewer — 코드 리뷰
│   ├── security-auditor.md   # Reviewer — 보안 감사
│   ├── tenth-man.md          # Reviewer — 반대 의견
│   └── ...                   # 나머지 22개
├── rules/            # 6개 거버넌스 룰 (.md)
│   ├── harness-system.md     # Lead/Worker/Reviewer 역할 경계 (alwaysApply)
│   ├── team-lead.md          # Agent Teams 오케스트레이션 (alwaysApply)
│   ├── spec-guard.md         # 스펙 정합성 연속 체크 (alwaysApply)
│   ├── skill-dispatch.md     # 상황별 스킬/에이전트 라우팅 (alwaysApply)
│   ├── tool-priority.md      # 중복 도구 우선순위 (alwaysApply)
│   └── code-review.md        # PR 리뷰 체크리스트 (on-demand)
├── install.sh        # 심링크 생성 스크립트
├── .gitignore
└── SETUP.md          # 이 파일
```

## 셋업 (최초 1회)

### 이 머신 (원본)

```bash
# 1. git 초기화
cd ~/dev/projects/claude-config
chmod +x install.sh
git init
git add .
git commit -m "initial: 30 agents + 6 rules + install script"

# 2. GitHub 레포 생성 후 push
git remote add origin git@github.com:sonsu-lee/claude-config.git
git push -u origin main

# 3. 심링크 연결 (기존 agents/, rules/를 .bak으로 백업 후 심링크)
./install.sh
```

install.sh 실행 결과:
```
~/.claude/agents → ~/dev/projects/claude-config/agents  (심링크)
~/.claude/rules  → ~/dev/projects/claude-config/rules   (심링크)
~/.claude/agents.bak  (기존 파일 백업)
~/.claude/rules.bak   (기존 파일 백업)
```

### 다른 머신

```bash
cd ~/dev/projects
git clone git@github.com:sonsu-lee/claude-config.git
cd claude-config
chmod +x install.sh
./install.sh
```

### 팀원

```bash
git clone git@github.com:sonsu-lee/claude-config.git
cd claude-config
./install.sh
```

## 일상 워크플로우

```bash
# 에이전트 수정 후 (어느 머신에서든)
cd ~/dev/projects/claude-config
git add -A && git commit -m "update conductor" && git push

# 다른 머신에서 반영
cd ~/dev/projects/claude-config && git pull
# 심링크라 ~/.claude/agents/, rules/는 자동 반영
```

## 팀원 배포 시 주의

- **settings.json 미포함** — 개인 권한, 활성 플러그인 목록이 들어있어 사람마다 다름
- **CLAUDE.md 미포함** — 개인 워크플로우 프리퍼런스
- agents/와 rules/만 공유하는 것이 의도

## 에이전트 시스템 아키텍처 요약

```
하네스 구조 (harness-system.md):
  Lead (read-only, 조율)    → conductor, dev-lead, quality-lead, ops-lead, research-lead
  Worker (full tools, 구현)  → frontend-dev, backend-dev, fullstack-dev, database-eng, ...
  Reviewer (read-only, 감사) → code-reviewer, security-auditor, tenth-man, arch-advisor, ...

오케스트레이션 (team-lead.md):
  Plan → Contract → Wave → Gate → Review
  각 wave 사이에 Execution Gate (빌드/테스트) + Spec Check

모델 티어링:
  opus   — 리더/판단 (conductor, dev-lead, quality-lead, debugger, arch-advisor, tenth-man)
  sonnet — 실행/분석 (대부분의 워커, 리뷰어)
  haiku  — 경량 작업 (dep-updater, doc-researcher, type-checker)
```

## 향후 고려

- OpenCode(anomalyco) 이식 시 이 레포를 .opencode/agents/ + instructions로 변환 가능
- Claude Code 플러그인 마켓플레이스에는 rules 이식 불가 (alwaysApply 미지원) → 이 방식이 대안
