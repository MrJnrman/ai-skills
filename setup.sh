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

# Get skill type: "file", "directory", or "none"
get_skill_type() {
    local skill_name="$1"
    local skill_file="$SKILLS_DIR/$skill_name.md"
    local skill_dir="$SKILLS_DIR/$skill_name"

    if [ -f "$skill_file" ]; then
        echo "file"
    elif [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
        echo "directory"
    else
        echo "none"
    fi
}

list_skills() {
    echo "Available skills:"
    echo ""
    local found=0

    # List single-file skills (*.md)
    for skill in "$SKILLS_DIR"/*.md; do
        if [ -f "$skill" ]; then
            skill_name=$(basename "$skill" .md)
            echo "  - $skill_name (file)"
            found=1
        fi
    done

    # List directory-based skills (containing SKILL.md)
    for skill_dir in "$SKILLS_DIR"/*/; do
        if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
            skill_name=$(basename "$skill_dir")
            echo "  - $skill_name (directory)"
            found=1
        fi
    done

    if [ $found -eq 0 ]; then
        echo "  (no skills found)"
    fi
}

link_skill() {
    local skill_name="$1"
    local skill_type
    skill_type=$(get_skill_type "$skill_name")

    mkdir -p "$CLAUDE_SKILLS_DIR"

    case "$skill_type" in
        file)
            ln -sf "$SKILLS_DIR/$skill_name.md" "$CLAUDE_SKILLS_DIR/$skill_name.md"
            echo "Linked: $skill_name (file)"
            ;;
        directory)
            ln -sf "$SKILLS_DIR/$skill_name" "$CLAUDE_SKILLS_DIR/$skill_name"
            echo "Linked: $skill_name (directory)"
            ;;
        none)
            echo "Error: Skill '$skill_name' not found"
            echo "  Checked: $SKILLS_DIR/$skill_name.md"
            echo "  Checked: $SKILLS_DIR/$skill_name/SKILL.md"
            return 1
            ;;
    esac
}

remove_skill() {
    local skill_name="$1"
    local link_file="$CLAUDE_SKILLS_DIR/$skill_name.md"
    local link_dir="$CLAUDE_SKILLS_DIR/$skill_name"
    local removed=0

    # Check for file symlink
    if [ -L "$link_file" ]; then
        rm "$link_file"
        echo "Removed: $skill_name (file)"
        removed=1
    elif [ -e "$link_file" ]; then
        echo "Warning: $link_file exists but is not a symlink, skipping"
    fi

    # Check for directory symlink
    if [ -L "$link_dir" ]; then
        rm "$link_dir"
        echo "Removed: $skill_name (directory)"
        removed=1
    elif [ -e "$link_dir" ] && [ -d "$link_dir" ]; then
        echo "Warning: $link_dir exists but is not a symlink, skipping"
    fi

    if [ $removed -eq 0 ]; then
        echo "Warning: $skill_name is not linked"
    fi
}

link_all() {
    local count=0
    mkdir -p "$CLAUDE_SKILLS_DIR"

    # Link single-file skills
    for skill in "$SKILLS_DIR"/*.md; do
        if [ -f "$skill" ]; then
            skill_name=$(basename "$skill" .md)
            ln -sf "$skill" "$CLAUDE_SKILLS_DIR/$skill_name.md"
            echo "Linked: $skill_name (file)"
            ((count++)) || true
        fi
    done

    # Link directory-based skills
    for skill_dir in "$SKILLS_DIR"/*/; do
        if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
            skill_name=$(basename "$skill_dir")
            ln -sf "${skill_dir%/}" "$CLAUDE_SKILLS_DIR/$skill_name"
            echo "Linked: $skill_name (directory)"
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

    # Remove file-based skill links
    for skill in "$SKILLS_DIR"/*.md; do
        if [ -f "$skill" ]; then
            skill_name=$(basename "$skill" .md)
            local link_path="$CLAUDE_SKILLS_DIR/$skill_name.md"
            if [ -L "$link_path" ]; then
                rm "$link_path"
                echo "Removed: $skill_name (file)"
                ((count++)) || true
            fi
        fi
    done

    # Remove directory-based skill links
    for skill_dir in "$SKILLS_DIR"/*/; do
        if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
            skill_name=$(basename "$skill_dir")
            local link_path="$CLAUDE_SKILLS_DIR/$skill_name"
            if [ -L "$link_path" ]; then
                rm "$link_path"
                echo "Removed: $skill_name (directory)"
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
