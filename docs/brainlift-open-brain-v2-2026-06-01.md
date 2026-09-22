Last updated 2026-06-01

# Open Brain v2 — Operator BrainLift

**Owner:** Bill Gleeson
**Purpose:** Consolidated knowledge from Open Brain v2 system — spanning CloudFix operations, AWS cost optimization, FinOps automation, AI tooling, digital marketing, and personal operating context. This document is the distilled output of the DOK pipeline (8,042 thoughts → DOK2 clusters → DOK3 insights → DOK4 SPOVs).

**Knowledge Flow Architecture:**
- DOK1 facts → captured from emails, Substack (Nate's Newsletter), ChatGPT memory, Perplexity, Google Drive, calendar, chat imports
- DOK2 clusters → 16 validated knowledge clusters
- DOK3 insights → 27 synthesized insights
- DOK4 SPOVs → 62 SPOVs (strategic points of view)

---

## Operator Profile

**Bill Gleeson** — sole operator of CloudFix (AWS cost optimization SaaS, ~$2M ARR) and RightSpend (commitment-free EC2 discounts). Based in Sandycove, Dublin. Wife Elaine, three sons (Dan 22, Dermot 19, Pierce 15), dog Honey.

**Role spans:** product, sales, customer success, technical operations, Salesforce/NetSuite admin, n8n automation, AI-first workflow design.

**Tech stack:** n8n (business automation), Supabase (Open Brain v2), AWS (S3, CloudFormation, Systems Manager), WordPress/Bitnami Lightsail, GitHub Actions, Python, Google Apps Script, Stripe, Brevo, Apollo, RB2B.

**Writing preferences:** Direct, casual, information-rich. Short sentences. Bullets and numbered lists. Active voice. No jargon. Dollar amounts rounded to whole numbers. Banned words: ensure, leverage, synergize, streamline, robust, comprehensive, cutting-edge.

**Volunteers:** Shamrock Rovers FC / Junior Hoops administration. Editing a 200,000-word Shamrock Rovers reference book.

---

## DOK4 — SPOVs (Strategic Points of View)

### 1. Implementation > Innovation

Adoption velocity beats capability. The companies winning with AI aren't the ones with the most advanced implementations — they're the ones that shipped faster and learned from usage.

**Evidence:**
- D2-CONTEXTWINDOWS.1: Average AI solution deployment takes 6 weeks from pilot to production (Nate's Substack)
- Solo founders shipping in weeks outcompete 50-person departments building for Q3
- Production agents "re-discover" ~85% of context on each run — vector DB-only retrieval is a primary failure mode

**CloudFix implication:** Speed of finder deployment and customer onboarding matters more than feature depth. Reduce time-to-first-savings below 7 days.

### 2. Cost-Conscious Tools Win During Gold Rush

In an AI infrastructure spending surge ($185B Google capex in 2026), the tools that help companies monitor, optimize, and control that spend are the safe bet — not the tools adding more capability.

**Evidence:**
- D2-ANTHROPIC.1: Anthropic launched self-hosted sandboxes, self-hosted Evals, and extended thinking for Opus — cost control features, not capability features
- D2-AGENTMEMORY.1: agentmemory reduces context token costs through persistent memory layers
- RightSpend customer (DirectVLA) under auditor scrutiny for coverage levels — demand for cost governance is real-time

**CloudFix implication:** Position CloudFix as the cost governance layer for AWS, not just a savings tool. Auditor-ready reporting and coverage SLOs are the wedge.

### 3. Solo + AI Beats Teams

The structural advantage is shifting from team size to operator + AI leverage. One person with good AI tooling and domain expertise outperforms traditional teams at execution speed.

**Evidence:**
- Jack Dorsey/Block cut 4,000 roles based on "intelligence tools" thesis — management layer itself being replaced
- 44% of US workers saw at least one management layer cut in the past year (Korn Ferry)
- Perplexity Computer: multi-model orchestration, 19 frontier models, spawns sub-agents, persists for months — $200/month

**CloudFix implication:** Bill's solo operator model is the template, not the constraint. Every CloudFix workflow should be AI-first, human-in-the-loop only where needed.

### 4. Transparent Cost Lens

FinOps transparency exposes how cost insight is created, who controls it, and where value leaks. The consulting firm disappears; what remains is an auditable, self-learning FinOps ecosystem.

**Evidence:**
- DOK4.1–4.4 chain from AI Consulting BrainLift: Transparency → Automation Drift → Training Sabotage → Pricing Drift
- Western Digital: $450k realized savings in 6 weeks ($1M annualized)
- Conn's HomePlus: $85k savings in first month
- 78 automated finders across all AWS accounts

**CloudFix implication:** Every recommendation should include an explainer log. Target ≥90% of recommendations with traceable lineage. Mean-time-to-explain (MTTX) < 48h.

### 5. Distribution Ate Capability

The Cognition–Infosys deal pattern: distribution channels beat product capability in AI. Owning the customer relationship through data flow and workflow integration is more defensible than model quality.

**Evidence:**
- Nate's Substack analysis: startups disrupt slow incumbents, but fastest adopters win — not smartest
- AI companies "renting their position" — Perplexity's product excellence doesn't guarantee survival
- CloudFix Marketplace data shows daily customer activity — distribution through AWS Marketplace is the moat

**CloudFix implication:** AWS Marketplace integration and partner channels (ITGeeks, managed service providers) are the growth path, not feature development.

---

## DOK3 — Insights

### I3.1 — Synthesis Is Dead
Traditional consulting sells "summary as insight." LLMs trained on telemetry outperform humans at pattern recognition. Clients expect automated cognition that traces directly to operational data.

### I3.2 — Telemetry Beats Interviews
AI trained on logs and tickets generates sharper optimization hypotheses than interview-based discovery. Humans self-censor; telemetry tells truth. Interview-based discovery is now an integrity risk.

### I3.3 — IaC Discipline vs Automation Drift
Drift isn't the absence of IaC — it's IaC ossified around obsolete assumptions. CloudFix finders embed optimization logic that can silently regress. 65–75% of identified savings achieved; remaining 25–35% blocked by IaC or permissions issues.

### I3.4 — Targeted Engagement Effectiveness
Resistance to FinOps automation is political psychology, not ignorance. Engineers avoid change due to blame asymmetry: failed savings = career risk; unclaimed waste = safety. Adoption increases only when objections are modeled as test cases.

### I3.5 — Dynamic FinOps Equilibrium
Static pricing and automation logic create dual drift — financial and technical. FinOps maturity depends on continuous re-baselining of both IaC and cost models. RI/SP coverage needs SLO-based governance, not one-time purchases.

### I3.6 — Corporate AI Tool Defaults Are a Trap
IT picks a default AI tool that can't deliver frontier results. Workers stuck in the middle pay the cost in 30-minute chunks and 5-minute corrections. The real cost isn't the subscription — it's the productivity tax of working around a mediocre tool.

---

## DOK2 — Knowledge Tree

### CloudFix Optimization Mechanics [D2-CF]
- 78 automated finders across all AWS accounts
- 65–75% savings achieved, 25–35% blocked by IaC/permissions
- Drift emerges in IaC-encoded optimizations after 3–6 months without refresh
- Western Digital: $450k in 6 weeks, $1M annualized
- Conn's HomePlus: $85k first month

### AWS Optimization Services [D2-AWS]
- Compute Optimizer requires 14 days telemetry for baseline accuracy
- S3 Intelligent Tiering adds monitoring and transition cost complexity
- Trusted Advisor pricing guidance lags 3–4 weeks behind usage data

### IaC and Automation Governance [D2-IAC]
- CloudFormation in-place upgrades require simultaneous master account access
- Permissions boundaries create 25–35% savings realization gap
- Semantic versioning for automation logic prevents silent regressions

### FinOps Practices & Adoption [D2-FP]
- Blame asymmetry drives adoption resistance: failed savings = career risk
- Adversarial enablement cycles outperform passive training
- Time-to-first-change < 7 days is the critical adoption metric

### PricingOps [D2-PO]
- RI/SP coverage SLOs should target ≥95%
- Rate-delta MTTD < 24 hours
- Pricing re-baseline cadence ≤ 30 days
- RightSpend customer (DirectVLA) under auditor pressure — real-time governance demand

### AI Agent Memory & Context [D2-CONTEXT]
- Production agents re-discover ~85% of context per invocation
- Knowledge layers (retrieval contracts, pre-assembled context, provenance) cut redundant fetches
- Agent memory reduces context token costs through persistent layers

### Anthropic & Model Evolution [D2-ANTHROPIC]
- Self-hosted sandboxes for code execution on user-owned servers
- Self-hosted Evals for enterprise evaluation
- Extended thinking for Opus — cost control features, not capability features
- Claude Code for CLI/desktop/IDE: Opus with faster output via /fast toggle

### Cost-Conscious Tooling [D2-COST]
- Google $185B AI infrastructure capex in 2026 — spend monitoring demand is massive
- Gemini 3.5 Flash: agentic workflows, coding, long-horizon task execution
- Karpathy joins Anthropic — talent flowing to safety/cost-focused labs

---

## DOK1 — Fact Sources

**By source:**
- **Substack (Nate's Newsletter):** 41 items — contrarian AI strategy, agent architecture, tool selection, adoption psychology
- **Google Drive/Docs:** 412 items — customer data, operational docs, BrainLift drafts
- **Gmail:** 125 items — customer emails, BrainLift updates, vendor communications
- **Google Chat:** 109 items — internal conversations
- **MCP captures:** 59 items — direct knowledge captures
- **ChatGPT Memory:** 20 items — personal profile, preferences, project context
- **Perplexity:** 7 items — research queries
- **Read.ai meetings:** 1 item — CloudFix Stack Update, partner demo with ITGeeks

---

## Experts to Follow

**Brandon Pizzacalla** — CloudFix & Contently CEO, $9B M&A transaction experience. Direct line on cost optimization strategy and M&A value creation.
`@bpizzacalla` on LinkedIn and X

**Nate (Nate's Newsletter)** — Best AI strategy writing in 2026. Contrarian, data-driven, framework-heavy. Primary DOK1 source for market positioning.
natesnewsletter.substack.com

**J.R. Storment** — FinOps Foundation exec director, co-author "Cloud FinOps." Framework expertise for FinOps maturity.
`@jrstorment` on LinkedIn

**Corey Quinn** — Last Week in AWS, Duckbill Group. Hidden AWS cost gotchas with practical commentary.
Bluesky

**Stephen Barr** — CloudFix evangelist. Writes clearly about pricing traps, resource misconfigurations, real-world optimization trade-offs.
LinkedIn, X

---

## System State (2026-06-01)

- **Total thoughts:** 8,042 (after dedup from 23,690)
- **DOK2 clusters:** 16
- **DOK3 insights:** 27
- **DOK4 SPOVs:** 62
- **Pipeline:** all pointers current (May 31)
- **Ingestion:** twice daily via n8n, content filter active (50 char minimum)
- **Storage:** ~470MB (projected under 500MB free tier after dedup)
