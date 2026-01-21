---
name: implementation-planning
description: "Defines how implementation plans are written, structured, critiqued, and revised. Use when creating or updating ai/plan.md."
compatibility: "Requires bash. Requires gemini CLI or codex CLI for critique."
---

# Implementation Planning

This skill governs how implementation plans are authored and maintained. Plans are design documents, not code. They must be precise, actionable, and grounded in the actual state of the repository.

## When to use

- Creating a new implementation plan at `ai/plan.md`
- Updating an existing plan after critique feedback
- Reviewing whether a plan meets quality standards
- Determining appropriate critique mode (default/poc/production)
- Resolving conflicts between plan and critique feedback

## Inputs required

- **Task description**: Clear statement of what needs to be planned
- **Repo context**: Access to codebase for architecture discovery
- **Scope classification**: Is this a POC, standard feature, or production-critical change?
- **Existing plan** (if updating): Current `ai/plan.md` content
- **Critique feedback** (if revising): Current `ai/critique.md` content

## Procedure

1. **Check existing state**: Does `ai/plan.md` exist? Does `ai/critique.md` have unaddressed items?
2. **Gather repo context** (if new plan): Architecture, dependencies, testing patterns, deployment mechanism, recent related changes
3. **Write or revise plan**: Follow Required Plan Structure below; edit in place for revisions
4. **Run critique**: Use `scripts/critique_plan.sh` with appropriate mode (see Using critique_plan.sh)
5. **Address critique**: Apply Critique Handling Rules for mandatory vs discretionary items
6. **Verify completeness**: Check against Quality Checklist
7. **Iterate**: Repeat steps 4-6 until plan passes quality standards

### Using critique_plan.sh

Run `scripts/critique_plan.sh --help` first, then use the appropriate mode:

```bash
# Default mode (balanced)
scripts/critique_plan.sh

# POC mode - relaxed rigor, focus on hypothesis validation
scripts/critique_plan.sh --mode poc

# Production mode - full engineering rigor
scripts/critique_plan.sh --mode production

# Inject conversation context
scripts/critique_plan.sh --mode poc --context "Focus on the auth flow"

# Enable codebase access tools (Gemini only)
# Use when plan validation benefits from reading actual code
scripts/critique_plan.sh --enable-tools --mode production
```

| Mode | Use Case | Rigor |
|------|----------|-------|
| `default` | Standard features | Balanced |
| `poc` | Prototypes, experiments | Relaxed |
| `production` | Customer-facing, critical | Full |

**Tool-Enabled Critique**: Use `--enable-tools` (Gemini only) to allow the AI to read files, search code, and validate assumptions during critique. Best for complex plans that reference existing code or make architectural assumptions.

### Required Plan Structure

Every plan at `ai/plan.md` must contain these sections in order:

1. **Changelog (from critique)** — Added after first critique cycle
2. **Problem Statement** — What problem? Why does it matter?
3. **Goals and Non-Goals** — Explicit scope boundaries
4. **Assumptions & Constraints** — Technical constraints from the repo
5. **High-Level Architecture / Approach** — The design, data flow, abstractions
6. **Data, API, or Interface Contracts** — Schemas, signatures, formats
7. **Edge Cases & Failure Modes** — What can go wrong?
8. **Security & Privacy Considerations** — Auth, data handling, validation
9. **Rollout, Rollback, and Observability** — Deployment and monitoring
10. **Test Strategy & Acceptance Criteria** — What does "done" look like?
11. **Open Questions / Risks** — Unresolved issues, known unknowns

If a section is not applicable, state "Not applicable for this change" with rationale.

### Before Writing a Plan

Gather from the codebase:
- Existing architecture (directory structure, module boundaries)
- Relevant existing code that will be modified
- Dependency graph (what depends on this? what does it depend on?)
- Testing patterns and frameworks in use
- Configuration and environment setup
- Deployment mechanism (CI/CD, scripts)
- Recent related changes (git history)

Plans that ignore actual repo state are rejected.

### Critique Handling Rules

When `ai/critique.md` exists:

**Mandatory (blocking)**:
- "Must-fix gaps" — Every item must be addressed
- Questions — Answer in plan or defer with rationale

**Discretionary**:
- Suggestions — Apply unless they expand scope; document rejections
- Alternative approaches — Adopt if they reduce risk; document decision

**Conflict Resolution**:
1. Identify conflict explicitly
2. State trade-offs
3. Make decision with rationale
4. Never leave conflicts unresolved

**Revision Protocol**:
- Edit in place (no rewrites from scratch)
- Preserve section order
- Update Changelog with dated entries

### Scope Control

- Goals section defines what's in scope
- Non-Goals section defines what's explicitly out
- "Nice to have" goes in Future Work subsection
- Never silently expand scope

## Verification

Before finalizing, verify the plan against this checklist:

- [ ] Problem statement is clear and justified
- [ ] Goals are measurable, non-goals explicit
- [ ] Assumptions reference actual repo state
- [ ] Architecture includes data/control flow
- [ ] Contracts are concrete (not prose)
- [ ] Edge cases cover: empty input, invalid input, partial failure, timeout
- [ ] Security addresses authn, authz, input validation
- [ ] Rollout includes rollback procedure
- [ ] Test strategy maps to acceptance criteria
- [ ] Open questions have owners or deadlines
- [ ] Changelog reflects critique responses (if applicable)

A plan is ready for implementation when all checklist items pass and no blocking critique items remain.

## Failure modes / debugging

| Problem | Cause | Solution |
|---------|-------|----------|
| Critique script fails | CLI not installed or network error | Ensure `gemini` or `codex` CLI is installed and configured; verify network connectivity |
| Plan rejected as "ignoring repo state" | Assumptions not grounded in actual code | Re-gather context; cite specific files/functions in plan |
| Critique loop never converges | Scope creep or conflicting requirements | Revisit Goals/Non-Goals; explicitly defer items to Future Work |
| Empty or unhelpful critique | Wrong mode selected | Use `--mode production` for complex plans; use `--enable-tools` for code-dependent validation |
| Plan sections missing | Skipped required structure | Re-read Required Plan Structure; add "Not applicable" with rationale for genuinely N/A sections |

## Escalation

Escalate to a human when:

- Critique identifies architectural concerns beyond your domain knowledge
- Conflicting requirements cannot be resolved with available context
- Security or privacy concerns require organizational policy input
- Stakeholder alignment is needed (e.g., scope disputes, resource constraints)
- The plan affects systems or teams outside your visibility

## Reference Files

- **references/base.md** — Core critique evaluation criteria
- **references/mode-default.md** — Balanced critique calibration
- **references/mode-poc.md** — POC-appropriate relaxations
- **references/mode-production.md** — Production rigor requirements
- **references/tools.md** — Tool usage guidelines (included when --enable-tools is used)
