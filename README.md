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
├── setup.sh
└── skills/
    └── (your skills go here)
```

## Installing Skills

Skills need to be symlinked to your local `~/.claude/skills` directory to be available in Claude Code. Use the included `setup.sh` script to manage this.

### Link All Skills

```bash
./setup.sh
```

### Link a Specific Skill

```bash
./setup.sh skill-name
```

### List Available Skills

```bash
./setup.sh --list
```

### Remove Skill Links

```bash
# Remove a specific skill
./setup.sh --remove skill-name

# Remove all skill links
./setup.sh --remove --all
```

### Full Usage

```
Usage: ./setup.sh [options] [skill-name]

Options:
  -h, --help     Show help message
  -l, --list     List available skills
  -a, --all      Link all available skills (default if no skill specified)
  -r, --remove   Remove symlinks instead of creating them

Examples:
  ./setup.sh              # Link all skills
  ./setup.sh --all        # Link all skills
  ./setup.sh my-skill     # Link a specific skill
  ./setup.sh -r my-skill  # Remove a specific skill link
  ./setup.sh -r --all     # Remove all skill links
  ./setup.sh --list       # List available skills
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
