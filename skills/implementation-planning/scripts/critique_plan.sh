#!/usr/bin/env bash
#
# critique_plan.sh - Send an implementation plan to an external AI for critique
#
# Usage:
#   critique_plan.sh [options] [engine] [plan_path] [output_path]
#
# Options:
#   --mode <mode>           Critique mode: poc, production, default (default: default)
#   --context <text>        Additional context to inject into the prompt
#   --context-file <path>   File containing additional context to inject
#   --enable-tools          Enable codebase access tools (Gemini only)
#   --dry-run               Print composed prompt without executing
#   --help                  Show this help message
#
# Positional Arguments:
#   engine      - "auto", "gemini", or "codex" (default: auto)
#   plan_path   - Path to the plan file (default: ai/plan.md)
#   output_path - Path for critique output (default: ai/critique.md)
#
# Environment Variables:
#   CRITIQUE_MODEL_GEMINI  - Gemini model to use (default: gemini-2.5-pro)
#   CRITIQUE_MODEL_CODEX   - Codex model to use (default: o3)
#
# Examples:
#   # POC mode with auto-detected engine
#   critique_plan.sh --mode poc
#
#   # Production mode with Gemini
#   critique_plan.sh --mode production gemini
#
#   # Inject conversation context
#   critique_plan.sh --context "Focus on the database migration strategy"
#
#   # Inject context from file (useful for Claude Code integration)
#   critique_plan.sh --context-file /tmp/critique-context.txt --mode poc
#

set -euo pipefail

# Resolve script directory for finding sibling files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFERENCES_DIR="$SCRIPT_DIR/../references"

# Defaults
MODE="default"
CONTEXT=""
CONTEXT_FILE=""
ENABLE_TOOLS=false
DRY_RUN=false
ENGINE="auto"
PLAN_PATH="ai/plan.md"
OUTPUT_PATH="ai/critique.md"

# Configuration
GEMINI_MODEL="${CRITIQUE_MODEL_GEMINI:-gemini-2.5-pro}"
CODEX_MODEL="${CRITIQUE_MODEL_CODEX:-gpt-5.2-codex}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_debug() {
    if [[ "${DEBUG:-}" == "1" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1" >&2
    fi
}

show_help() {
    head -50 "$0" | grep -E '^#' | sed 's/^# \?//'
    exit 0
}

# Parse arguments
parse_args() {
    local positional=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            --mode)
                MODE="$2"
                shift 2
                ;;
            --context)
                CONTEXT="$2"
                shift 2
                ;;
            --context-file)
                CONTEXT_FILE="$2"
                shift 2
                ;;
            --enable-tools)
                ENABLE_TOOLS=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_help
                ;;
            -*)
                log_error "Unknown option: $1"
                exit 1
                ;;
            *)
                positional+=("$1")
                shift
                ;;
        esac
    done

    # Assign positional arguments
    if [[ ${#positional[@]} -ge 1 ]]; then
        ENGINE="${positional[0]}"
    fi
    if [[ ${#positional[@]} -ge 2 ]]; then
        PLAN_PATH="${positional[1]}"
    fi
    if [[ ${#positional[@]} -ge 3 ]]; then
        OUTPUT_PATH="${positional[2]}"
    fi
}

# Detect available CLI tools
detect_engine() {
    local has_gemini=false
    local has_codex=false

    if command -v gemini &>/dev/null; then
        has_gemini=true
    fi

    if command -v codex &>/dev/null; then
        has_codex=true
    fi

    if [[ "$has_gemini" == "true" && "$has_codex" == "true" ]]; then
        echo "gemini"
    elif [[ "$has_gemini" == "true" ]]; then
        echo "gemini"
    elif [[ "$has_codex" == "true" ]]; then
        echo "codex"
    else
        echo "none"
    fi
}

# Validate inputs
validate() {
    # Check plan file exists
    if [[ ! -f "$PLAN_PATH" ]]; then
        log_error "Plan file not found: $PLAN_PATH"
        exit 1
    fi

    # Check references directory exists
    if [[ ! -d "$REFERENCES_DIR" ]]; then
        log_error "References directory not found: $REFERENCES_DIR"
        exit 1
    fi

    # Check base reference exists
    if [[ ! -f "$REFERENCES_DIR/base.md" ]]; then
        log_error "Base reference not found: $REFERENCES_DIR/base.md"
        exit 1
    fi

    # Validate mode
    local mode_file="$REFERENCES_DIR/mode-${MODE}.md"
    if [[ ! -f "$mode_file" ]]; then
        log_error "Unknown mode: $MODE"
        log_error "Available modes: poc, production, default"
        exit 1
    fi

    # Check context file if specified
    if [[ -n "$CONTEXT_FILE" && ! -f "$CONTEXT_FILE" ]]; then
        log_error "Context file not found: $CONTEXT_FILE"
        exit 1
    fi

    # Resolve engine if auto
    if [[ "$ENGINE" == "auto" ]]; then
        ENGINE=$(detect_engine)
        if [[ "$ENGINE" == "none" ]]; then
            log_error "No supported CLI tool found. Install 'gemini' or 'codex' CLI."
            exit 1
        fi
        log_info "Auto-detected engine: $ENGINE"
    fi

    # Validate engine choice
    if [[ "$DRY_RUN" == "false" ]]; then
        case "$ENGINE" in
            gemini)
                if ! command -v gemini &>/dev/null; then
                    log_error "Gemini CLI not found."
                    exit 1
                fi
                ;;
            codex)
                if ! command -v codex &>/dev/null; then
                    log_error "Codex CLI not found."
                    exit 1
                fi
                ;;
            *)
                log_error "Unknown engine: $ENGINE. Use 'auto', 'gemini', or 'codex'."
                exit 1
                ;;
        esac
    fi

    # Validate tools flag compatibility
    if [[ "$ENABLE_TOOLS" == "true" && "$ENGINE" == "codex" ]]; then
        log_error "Tool-enabled critique is only supported with Gemini CLI."
        log_error "Codex does not support tools in this implementation."
        log_error "Either use Gemini or remove the --enable-tools flag."
        exit 1
    fi
}

# Build the full prompt from components
build_prompt() {
    local base_prompt
    local mode_prompt
    local plan_content
    local additional_context=""

    # Load base prompt
    base_prompt=$(cat "$REFERENCES_DIR/base.md")

    # Load mode-specific prompt
    mode_prompt=$(cat "$REFERENCES_DIR/mode-${MODE}.md")

    # Load plan content
    plan_content=$(cat "$PLAN_PATH")

    # Build additional context section
    if [[ -n "$CONTEXT_FILE" ]]; then
        additional_context=$(cat "$CONTEXT_FILE")
    fi
    if [[ -n "$CONTEXT" ]]; then
        if [[ -n "$additional_context" ]]; then
            additional_context="${additional_context}

${CONTEXT}"
        else
            additional_context="$CONTEXT"
        fi
    fi

    # Compose final prompt
    cat <<EOF
${base_prompt}

---

${mode_prompt}
EOF

    # Add tools reference if enabled
    if [[ "$ENABLE_TOOLS" == "true" ]]; then
        local tools_prompt
        tools_prompt=$(cat "$REFERENCES_DIR/tools.md")
        cat <<EOF

---

${tools_prompt}
EOF
    fi

    # Add context section if provided
    if [[ -n "$additional_context" ]]; then
        cat <<EOF

---

# Additional Context

The following context was provided for this specific critique:

${additional_context}
EOF
    fi

    # Add the plan
    cat <<EOF

---

# Implementation Plan to Critique

\`\`\`markdown
${plan_content}
\`\`\`

Begin your critique now.
EOF
}

# Run critique with Gemini CLI
run_gemini() {
    local prompt="$1"

    log_info "Running critique with Gemini CLI (model: $GEMINI_MODEL)..."

    # Build command with tool approval flags if tools are enabled
    local gemini_cmd="gemini -m \"$GEMINI_MODEL\""

    if [[ "$ENABLE_TOOLS" == "true" ]]; then
        # Pre-approve safe read-only tools to avoid interactive prompts
        gemini_cmd="$gemini_cmd --allowed-tools \"read_file,search_file_content,glob,list_directory\""

        # Optional: Use --approval-mode=yolo for shell commands
        # Uncomment if you want fully automated critique with no prompts at all
        # gemini_cmd="$gemini_cmd --approval-mode=yolo"

        log_info "Tools enabled: read_file, search_file_content, glob, list_directory"
    fi

    echo "$prompt" | eval "$gemini_cmd" > "$OUTPUT_PATH"
}

# Run critique with Codex CLI
run_codex() {
    local prompt="$1"

    log_info "Running critique with Codex CLI (model: $CODEX_MODEL)..."

    # Use codex exec with stdin, -o to write final message to output file
    echo "$prompt" | codex exec -m "$CODEX_MODEL" -o "$OUTPUT_PATH" --skip-git-repo-check -
}

# Main execution
main() {
    parse_args "$@"

    log_info "Plan critique starting"
    log_info "  Mode: $MODE"
    log_info "  Plan: $PLAN_PATH"
    log_info "  Output: $OUTPUT_PATH"
    log_info "  Tools: $ENABLE_TOOLS"
    [[ -n "$CONTEXT" ]] && log_info "  Context: (inline, ${#CONTEXT} chars)"
    [[ -n "$CONTEXT_FILE" ]] && log_info "  Context file: $CONTEXT_FILE"

    validate

    # Build the prompt
    local prompt
    prompt=$(build_prompt)

    # Dry run: just print the prompt
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Dry run mode - printing composed prompt:"
        echo ""
        echo "$prompt"
        exit 0
    fi

    # Ensure output directory exists
    mkdir -p "$(dirname "$OUTPUT_PATH")"

    # Execute with selected engine
    case "$ENGINE" in
        gemini)
            run_gemini "$prompt"
            ;;
        codex)
            run_codex "$prompt"
            ;;
    esac

    if [[ -f "$OUTPUT_PATH" && -s "$OUTPUT_PATH" ]]; then
        log_info "Critique written to: $OUTPUT_PATH"
        echo ""
        echo "--- Critique Preview (first 30 lines) ---"
        head -30 "$OUTPUT_PATH"
        echo "..."
    else
        log_error "Critique file is empty or was not created"
        exit 1
    fi
}

main "$@"
