#!/bin/bash

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$REPO_DIR/skills"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"

usage() {
    echo "Usage: $0 [options] [skill-name]"
    echo ""
    echo "Link AI skills to your local Claude Code configuration."
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -l, --list     List available skills"
    echo "  -a, --all      Link all available skills (default if no skill specified)"
    echo "  -r, --remove   Remove symlinks instead of creating them"
    echo ""
    echo "Examples:"
    echo "  $0              # Link all skills"
    echo "  $0 --all        # Link all skills"
    echo "  $0 my-skill     # Link a specific skill"
    echo "  $0 -r my-skill  # Remove a specific skill link"
    echo "  $0 -r --all     # Remove all skill links"
    echo "  $0 --list       # List available skills"
}

list_skills() {
    echo "Available skills:"
    echo ""
    local found=0
    for skill in "$SKILLS_DIR"/*.md; do
        if [ -f "$skill" ]; then
            skill_name=$(basename "$skill" .md)
            echo "  - $skill_name"
            found=1
        fi
    done
    if [ $found -eq 0 ]; then
        echo "  (no skills found)"
    fi
}

link_skill() {
    local skill_name="$1"
    local skill_file="$SKILLS_DIR/$skill_name.md"

    if [ ! -f "$skill_file" ]; then
        echo "Error: Skill '$skill_name' not found at $skill_file"
        return 1
    fi

    mkdir -p "$CLAUDE_SKILLS_DIR"
    ln -sf "$skill_file" "$CLAUDE_SKILLS_DIR/$skill_name.md"
    echo "Linked: $skill_name"
}

remove_skill() {
    local skill_name="$1"
    local link_path="$CLAUDE_SKILLS_DIR/$skill_name.md"

    if [ -L "$link_path" ]; then
        rm "$link_path"
        echo "Removed: $skill_name"
    elif [ -e "$link_path" ]; then
        echo "Warning: $link_path exists but is not a symlink, skipping"
    else
        echo "Warning: $skill_name is not linked"
    fi
}

link_all() {
    local count=0
    mkdir -p "$CLAUDE_SKILLS_DIR"

    for skill in "$SKILLS_DIR"/*.md; do
        if [ -f "$skill" ]; then
            skill_name=$(basename "$skill" .md)
            ln -sf "$skill" "$CLAUDE_SKILLS_DIR/$skill_name.md"
            echo "Linked: $skill_name"
            ((count++)) || true
        fi
    done

    if [ $count -eq 0 ]; then
        echo "No skills found to link."
    else
        echo ""
        echo "Successfully linked $count skill(s) to $CLAUDE_SKILLS_DIR"
    fi
}

remove_all() {
    local count=0

    for skill in "$SKILLS_DIR"/*.md; do
        if [ -f "$skill" ]; then
            skill_name=$(basename "$skill" .md)
            local link_path="$CLAUDE_SKILLS_DIR/$skill_name.md"
            if [ -L "$link_path" ]; then
                rm "$link_path"
                echo "Removed: $skill_name"
                ((count++)) || true
            fi
        fi
    done

    if [ $count -eq 0 ]; then
        echo "No linked skills found to remove."
    else
        echo ""
        echo "Successfully removed $count skill link(s)"
    fi
}

# Parse arguments
REMOVE=0
ALL=0
SKILL_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -l|--list)
            list_skills
            exit 0
            ;;
        -a|--all)
            ALL=1
            shift
            ;;
        -r|--remove)
            REMOVE=1
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            SKILL_NAME="$1"
            shift
            ;;
    esac
done

# Execute based on arguments
if [ -n "$SKILL_NAME" ]; then
    if [ $REMOVE -eq 1 ]; then
        remove_skill "$SKILL_NAME"
    else
        link_skill "$SKILL_NAME"
    fi
elif [ $ALL -eq 1 ] || [ $REMOVE -eq 0 ]; then
    if [ $REMOVE -eq 1 ]; then
        remove_all
    else
        link_all
    fi
else
    usage
    exit 1
fi
