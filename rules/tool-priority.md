---
alwaysApply: true
---

# Tool Priority

When duplicate tools exist, prefer left:

- **Code exploration**: Read/Glob/Grep → Serena (when symbolic analysis needed)
- **Issue tracking**: Linear (company) / GitHub Issues (personal)
- **Browser automation**: agent-browser CLI (default, 93% less context) → Playwright MCP (fallback)
- **Code review**: pr-review-toolkit (PR) / code-review (single file)
- **Web content fetch**: WebFetch (static pages) → Zyte `extract_browser_html` (JS-heavy/SPA — when WebFetch returns CSS/empty) → Perplexity (when extraction fails entirely)
- **Library/framework docs**: Context7 MCP (`resolve-library-id` → `query-docs`) — for versioned API docs of known libraries only, NOT for general web pages or blog posts
- **Research/fact-check**: deep-research skill (Exa→WebFetch→Zyte→Perplexity escalation)
- **Infrastructure**: Terraform plugin
