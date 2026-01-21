# Implementation Planning Skill

This skill defines how Claude Code writes, structures, and revises implementation plans.

## Folder Structure

```
implementation-planning/
├── SKILL.md                      # Main skill definition (loaded by Claude Code)
├── scripts/
│   └── critique_plan.sh          # Sends plan to external AI for critique
├── references/
│   ├── base.md                   # Core critique instructions (always included)
│   ├── mode-default.md           # Balanced critique (default)
│   ├── mode-poc.md               # POC-appropriate critique (relaxed rigor)
│   └── mode-production.md        # Production-grade critique (full rigor)
└── README.md
```

## Usage

### Writing Plans

Claude Code automatically uses `SKILL.md` when creating or updating `ai/plan.md`.

### Running Critiques

```bash
# Show help
scripts/critique_plan.sh --help

# Default mode (balanced)
scripts/critique_plan.sh

# POC mode - relaxed requirements, focus on core hypothesis
scripts/critique_plan.sh --mode poc

# Production mode - full engineering rigor
scripts/critique_plan.sh --mode production

# Specify engine explicitly
scripts/critique_plan.sh --mode poc gemini

# Inject additional context (from conversation)
scripts/critique_plan.sh --context "Focus on the auth flow, ignore UI concerns"

# Inject context from file
scripts/critique_plan.sh --context-file /tmp/context.txt --mode poc

# Preview composed prompt without executing
scripts/critique_plan.sh --mode production --dry-run

# Custom paths
scripts/critique_plan.sh --mode default auto path/to/plan.md path/to/critique.md
```

### Tool-Enabled Critique (Gemini Only)

Enable codebase access tools to allow Gemini to read files, search code, and validate assumptions during critique:

```bash
# Enable tools for more thorough critique
scripts/critique_plan.sh --enable-tools --mode production

# Tools work with all modes
scripts/critique_plan.sh --enable-tools --mode poc
```

**Important notes:**
- Tool access is **Gemini-only** - Codex does not support tools in this implementation
- File operations (read_file, search_file_content, glob, list_directory) are pre-approved and run automatically
- Shell commands may require confirmation (can be bypassed by uncommenting `--approval-mode=yolo` in the script)
- Tools increase token usage - use when plan validation benefits outweigh costs

**When to use tools:**
- ✅ Complex architectural changes that reference existing code
- ✅ Plans that make assumptions about current implementation patterns
- ✅ Critiques that need to verify conventions or naming standards
- ❌ Simple feature additions with clear requirements
- ❌ Plans that are self-contained and well-explained

**Example:**
```bash
# Plan proposes extending BaseCommand - tools can verify its API
echo "# Plan: Add new CLI command extending BaseCommand" > ai/plan.md
scripts/critique_plan.sh --enable-tools
# Gemini may read src/commands/BaseCommand.php to validate approach
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `CRITIQUE_MODEL_GEMINI` | Gemini model to use | `gemini-2.5-pro` |
| `CRITIQUE_MODEL_CODEX` | Codex model to use | `o3` |

## Critique Modes

| Mode | Use Case | Rigor |
|------|----------|-------|
| `default` | Standard features, internal tools | Balanced |
| `poc` | Prototypes, experiments | Relaxed |
| `production` | Customer-facing, critical infrastructure | Full |

### POC Mode

Relaxed requirements for proof of concept work:
- Ignores missing error handling, observability, security hardening
- Focuses on: Does the approach validate the hypothesis? Is the architecture fundamentally sound?
- Only flags issues that would invalidate the POC or require complete rewrite

### Production Mode

Full engineering rigor for production deployments:
- Requires comprehensive error handling, security, observability
- Demands rollback procedures and operational runbooks
- Flags missing performance testing and load considerations

## Context Injection

The `--context` and `--context-file` flags inject conversation-specific guidance:

```bash
# Focus on specific concerns
--context "We're primarily concerned about database migration safety"

# Provide codebase context
--context "The existing auth uses JWT with Redis session storage"

# Skip certain areas
--context "Ignore test coverage - we'll address that in a follow-up"
```

## Customizing Critique Behavior

Edit files in `references/`:
- `base.md` — Core evaluation criteria and output format (affects all modes)
- `mode-*.md` — Mode-specific calibration and must-fix thresholds

## Workflow

1. Claude Code writes `ai/plan.md` following the structure in `SKILL.md`
2. Run `scripts/critique_plan.sh --mode <mode>` → critique written to `ai/critique.md`
3. Claude Code reads critique and revises `ai/plan.md` per critique handling rules
4. Repeat until plan is approved
