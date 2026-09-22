# Current Project State — open-brain-v2

_Last updated: 2026-09-10 (auto-managed, update at end of sessions)_

## Active Decisions
- OB1 is the shared memory layer for all agents (Hermes + Claude Code + Claude Desktop)
- Supabase edge functions serve MCP tools (open-brain-mcp, brain-tools-mcp)
- Agent Memory API (recall/writeback) available but not yet used by Claude Code directly
- No commits or merges without Bill's explicit approval

## Open Questions
- 8,600+ untyped thoughts in the brain — needs cleanup pass
- Date range mismatch: thought_stats says Jul 9+ but recall returns June/March entries
- query defaults learn=true (creates self-replication) — always pass learn=false

## Last Session Work
- whats the oldest memeory in the brain then?
- that chats with Pinto and Oguz might have some old gold in them. any highlights?
- yeah pull the full thread

## Next Priorities
- Type the untyped entries so they're discoverable via type filters
- Understand the date range discrepancy

## Context Map
- `recipes/` — agent memory, adaptive capture, daily digest, DOK pipeline, entity wiki
- `primitives/` — shared MCP, RLS, troubleshooting, remote MCP, sensitive data redaction
- `schemas/` — SQL migrations for agent memory tables
- `server/` — standalone MCP server (Deno/Hono)
- `resources/` — companion files, heavy ingestion packs
- Supabase: https://zpeedfgyuusscsrirzsg.supabase.co
