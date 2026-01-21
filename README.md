# AI Skills

A collection of reusable AI skills for Claude Code.

## Getting Started

### Clone the Repository

```bash
git clone git@github.com:MrJnrman/ai-skills.git
```

Or using HTTPS:

```bash
git clone https://github.com/MrJnrman/ai-skills.git
```

### Directory Structure

```
ai-skills/
├── README.md
└── skills/
    └── (your skills go here)
```

## Installing Skills

Skills need to be symlinked to your local `.claude/skills` directory to be available in Claude Code.

### Option 1: Symlink Individual Skills

```bash
# Create the skills directory if it doesn't exist
mkdir -p ~/.claude/skills

# Symlink a specific skill
ln -s /path/to/ai-skills/skills/skill-name.md ~/.claude/skills/skill-name.md
```

### Option 2: Symlink the Entire Skills Directory

If you want all skills from this repo to be available:

```bash
# Remove existing skills directory if it exists (backup first if needed)
# mv ~/.claude/skills ~/.claude/skills.backup

# Symlink the entire skills directory
ln -s /path/to/ai-skills/skills ~/.claude/skills
```

### Option 3: Use a Setup Script

Create a simple setup script for convenience:

```bash
#!/bin/bash
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"

mkdir -p "$CLAUDE_SKILLS_DIR"

for skill in "$REPO_DIR"/skills/*.md; do
    if [ -f "$skill" ]; then
        skill_name=$(basename "$skill")
        ln -sf "$skill" "$CLAUDE_SKILLS_DIR/$skill_name"
        echo "Linked: $skill_name"
    fi
done

echo "Skills installation complete!"
```

## Creating New Skills

1. Create a new `.md` file in the `skills/` directory
2. Follow the skill format:

```markdown
---
name: skill-name
description: Brief description of what the skill does
---

# Skill Name

Instructions and prompts for the skill...
```

## Keeping Skills Updated

Since skills are symlinked, updating is simple:

```bash
cd /path/to/ai-skills
git pull origin trunk
```

Your local Claude Code will automatically use the updated skills.

## Contributing

1. Create a new branch from `trunk`
2. Add or modify skills in the `skills/` directory
3. Submit a pull request

## License

Feel free to use and share these skills.
