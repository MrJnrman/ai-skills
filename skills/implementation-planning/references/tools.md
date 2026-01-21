# Codebase Access Tools

You have access to tools that allow you to inspect the codebase when needed for your critique. Use these tools **only when necessary** to validate assumptions or understand implementation details that would materially affect your critique.

## Available Tools

### File System Tools

- **`read_file`** or **`read_many_files`**: Read the contents of one or more files
  - Use when you need to verify specific implementation details
  - Example: Checking if a particular pattern or API is already used in the codebase

- **`glob`**: Find files matching a pattern (e.g., `**/*.php`, `src/commands/*.php`)
  - Use to understand project structure or find related files
  - Example: Finding all command files to verify naming conventions

- **`search_file_content`**: Search for text patterns across the codebase
  - Use to find existing usage patterns, dependencies, or architectural decisions
  - Example: Searching for how error handling is currently implemented

- **`list_directory`**: List contents of a directory
  - Use to understand directory structure
  - Example: Checking what test files exist in a directory

### Shell Tool

- **`run_shell_command`**: Execute read-only shell commands
  - **Restriction**: Use ONLY for safe, read-only operations
  - Allowed: `git log`, `git show`, `git diff`, `ls`, `find`, `grep`, `cat`, `head`, `tail`, `wc`, `tree`
  - **Never use**: Commands that modify files, run tests, install dependencies, or make changes
  - Example: Running `git log --oneline --since="1 month ago" --no-merges` to understand recent development patterns

## When to Use Tools

Use tools strategically and sparingly:

### ✅ Good Reasons to Use Tools

1. **Verify architectural decisions**: Check if a proposed pattern already exists in the codebase
2. **Validate assumptions**: Confirm that your critique assumptions are correct before making strong recommendations
3. **Understand context**: When the plan references code that isn't clear from the plan itself
4. **Check conventions**: Verify naming conventions, code style, or architectural patterns actually used in the project

### ❌ Avoid Tool Overuse

1. **Don't read files "just to explore"**: Only read when it materially affects your critique
2. **Don't validate obvious things**: If the plan clearly explains something, trust it
3. **Don't search exhaustively**: Make targeted, specific tool calls rather than broad exploration
4. **Don't use tools for information available in the plan**: If the plan already provides the detail, don't redundantly verify it

## Tool Usage Philosophy

**Be surgical, not exploratory**. Each tool call should have a clear purpose that directly improves the quality or accuracy of your critique. Think of tools as "fact-checking" resources, not as a way to do independent research.

### Example Usage Patterns

**Poor usage**:
```
1. read_file src/ServiceProvider.php
2. read_file src/Container.php
3. read_file src/Command.php
4. search_file_content "dependency injection"
5. list_directory src/
```
This is unfocused exploration that wastes tokens.

**Good usage**:
```
1. search_file_content "interface CommandInterface"
   → Purpose: The plan proposes creating CommandInterface, checking if it already exists
2. read_file src/commands/BaseCommand.php
   → Purpose: Plan extends BaseCommand, need to verify its API to assess feasibility
```
This is targeted fact-checking that directly improves critique quality.

## Important Notes

- Tools are provided by Gemini CLI's built-in capabilities
- File operations (read_file, search_file_content, glob, list_directory) are pre-approved and will execute automatically
- Shell commands may require your confirmation depending on configuration
- All operations are read-only for safety
