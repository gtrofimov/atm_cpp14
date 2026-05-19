---
name: create-agent-skills
description: Create new agent skills for Copilot. Use this when developing new skills to teach Copilot specialized tasks, or when asked to make a skill or create agent skills.
license: MIT
---

# Create Agent Skills

This skill provides comprehensive guidance for creating new agent skills that extend Copilot's capabilities with specialized instructions, scripts, and resources.

## When to use this skill

Use this skill when you need to:
- Create a new agent skill from scratch
- Develop specialized instructions for Copilot to follow
- Package reusable task guidance for a project or team
- Share skills in repositories or across projects
- Create both project-level and personal skills

## What are agent skills?

Agent Skills are open-standard folders containing:
- **Instructions** (SKILL.md): Markdown files with YAML frontmatter describing what the skill does
- **Scripts**: Executable files that automate tasks
- **Resources**: Examples, templates, or reference materials
- **Configuration**: Any supporting files needed for the skill

Skills are stored in:
- **Project skills**: `.github/skills/` or `.claude/skills/` (repository-specific)
- **Personal skills**: `~/.copilot/skills/` or `~/.claude/skills/` (shared across projects)

## Step-by-step: Creating a skill

### 1. Create the skill directory

Create a new subdirectory under `.github/skills/` (for project-level skills) with a lowercase, hyphenated name matching your skill's purpose:

```bash
mkdir -p .github/skills/your-skill-name
cd .github/skills/your-skill-name
```

**Directory naming rules:**
- Use lowercase letters
- Use hyphens for spaces (e.g., `image-conversion` not `image conversion`)
- The directory name should ideally match the `name` field in SKILL.md
- Keep names descriptive but concise

### 2. Create the SKILL.md file

Create a `SKILL.md` file (exact filename required) with YAML frontmatter and Markdown content:

```markdown
---
name: your-skill-name
description: Clear description of what this skill does and when Copilot should use it.
license: MIT
---

# Your Skill Title

Introductory paragraph explaining the skill's purpose and scope.

## When to use this skill

- Use case 1
- Use case 2
- Use case 3

## Prerequisites

List any requirements:
- Environment variables
- Installed tools
- System setup
- Permissions needed

## Step-by-step process

### Step 1: Description

Detailed instructions for first step.

```bash
# Code examples
command --with-flags
```

### Step 2: Description

More instructions...

## Key considerations

- Important gotchas
- Best practices
- Common mistakes to avoid

## Examples

Provide concrete examples of how to use the skill.

## Troubleshooting

Common issues and solutions.
```

### 3. SKILL.md frontmatter requirements

Your frontmatter must include:

- **name** (required): Unique identifier, lowercase with hyphens
  ```yaml
  name: github-actions-debugging
  ```

- **description** (required): Tell Copilot when to use this skill
  ```yaml
  description: Debug failing GitHub Actions workflows. Use this when diagnosing CI/CD failures.
  ```

- **license** (optional): License for the skill
  ```yaml
  license: MIT
  ```

### 4. Write comprehensive instructions

In the Markdown body, include:

- **Purpose**: Clear explanation of what the skill accomplishes
- **When to use it**: Specific scenarios when Copilot should apply this skill
- **Prerequisites**: Setup steps, environment variables, required tools
- **Step-by-step process**: Numbered sections with clear, actionable steps
- **Code examples**: Shell commands, scripts, or configuration samples
- **Key considerations**: Best practices, common pitfalls, performance notes
- **Examples**: Real-world scenarios showing the skill in action
- **Troubleshooting**: Solutions to common problems

### 5. (Optional) Add supporting scripts and resources

Store additional files in the skill directory:

```
.github/skills/your-skill-name/
├── SKILL.md                    # Main skill instructions
├── scripts/
│   ├── setup.sh               # Setup script
│   └── run-task.sh            # Task execution script
├── templates/
│   └── example-config.yaml    # Configuration template
└── examples/
    └── sample-output.md       # Example output or results
```

### 6. Structure your SKILL.md effectively

**Good structure example:**

```markdown
---
name: api-documentation
description: Generate API documentation automatically. Use this when creating or updating API documentation.
license: MIT
---

# API Documentation Generation

## When to use this skill
- Creating documentation for REST APIs
- Updating API docs after interface changes
- Generating OpenAPI/Swagger specs

## Prerequisites
- Tool 1 installed
- Environment variable setup

## Step-by-step process

### Step 1: Analyze the API
[Instructions...]

### Step 2: Generate documentation
[Instructions...]

## Key considerations
- API versioning
- Authentication methods
- Rate limiting documentation

## Examples
- Example 1
- Example 2
```

## How Copilot uses your skill

1. **Detection**: Copilot matches your task prompt against skill descriptions
2. **Loading**: The SKILL.md file is injected into Copilot's context
3. **Execution**: Copilot follows your instructions and uses any scripts/resources
4. **Adaptation**: Copilot applies the skill appropriately to the specific task

## Automated Skill Creation (Phase 1 Improved)

Instead of manual steps, use the automated scaffolding script for Phase 1 features:

```bash
./.github/skills/create-agent-skills/scripts/create-skill-v2.sh \
  my-skill-name \
  "Clear description of what this skill does"
```

**What v2 script does automatically:**
- ✅ Validates inputs before creating files (fail-fast)
- ✅ Creates standardized directory structure
- ✅ Generates SKILL.md template
- ✅ Outputs structured JSON metadata
- ✅ Creates decision log documenting design choices
- ✅ Makes scripts executable

**Output includes:**
```json
{
  "status": "success",
  "execution_id": "...",
  "outputs": {"primary_artifact": ".github/skills/my-skill-name"},
  "next_steps": ["Edit SKILL.md", "Test with Copilot"]
}
```

The script follows **Phase 1** of our improvement initiatives (standardized I/O + decision logging).

## Best practices

### DO:
- ✅ Write clear, step-by-step instructions
- ✅ Include concrete examples and code snippets
- ✅ Specify when the skill should be used (in description)
- ✅ List all prerequisites upfront
- ✅ Keep skills focused on specific tasks
- ✅ Use simple, direct language
- ✅ Provide error handling and troubleshooting guidance
- ✅ Test your skill with actual tasks

### DON'T:
- ❌ Make descriptions vague or too general
- ❌ Skip prerequisites or setup steps
- ❌ Include overly complex or nested instructions
- ❌ Mix multiple unrelated tasks in one skill
- ❌ Use unclear variable names or abbreviations
- ❌ Forget to explain why each step matters

## Tips for effective skills

### 1. Be specific about when to use

**Poor description**: "Helps with testing"
**Good description**: "Run unit tests with coverage analysis for C++ projects using GoogleTest and C/C++test instrumentation."

### 2. Include practical examples

Show actual commands, outputs, and expected results so Copilot understands exactly what to do.

### 3. Anticipate common problems

Include a troubleshooting section addressing:
- Environment setup issues
- Common error messages
- Performance considerations

### 4. Reference available tools

If your skill uses Model Context Protocol (MCP) servers or VS Code tools, reference them explicitly:
- `Use the GitHub MCP Server with the 'get_workflow_runs' tool`
- `Use VS Code's built-in terminal for commands`

### 5. Make scripts executable

For any shell scripts in your skill:

```bash
chmod +x .github/skills/your-skill-name/scripts/*.sh
```

### 6. Document skill dependencies

If your skill depends on other skills, mention it:
> This skill builds on the `python-testing` skill; ensure that's available first.

## Testing your skill

1. **Manual verification**: Follow your own instructions step-by-step
2. **Ask Copilot directly**: "Use my new skill to [task]"
3. **Edge cases**: Test with different scenarios the skill should handle
4. **Iterate**: Refine instructions based on how well Copilot follows them

## Sharing your skill

Once your skill is complete:

1. **In a repository**: Commit to `.github/skills/` and push to GitHub
2. **Publicly**: Share in repositories like [anthropics/skills](https://github.com/anthropics/skills) or [github/awesome-copilot](https://github.com/github/awesome-copilot)
3. **Personally**: Store in `~/.copilot/skills/` for use across your projects

## Example: Full skill structure

```
.github/skills/database-migration/
├── SKILL.md
├── scripts/
│   ├── validate-schema.sh
│   └── generate-migration.sh
├── templates/
│   └── migration-template.sql
└── examples/
    └── successful-migration.md
```

## Troubleshooting

### Skill not being used
- Check description is specific and matches your task
- Ensure SKILL.md filename is exact (case-sensitive on Linux/Mac)
- Verify YAML frontmatter is valid

### Copilot not following instructions
- Simplify and clarify the steps
- Add practical examples
- Break complex processes into smaller substeps
- Include expected outputs so Copilot knows when it's correct

### Skills in wrong location
- Project skills go in `.github/skills/` or `.claude/skills/`
- Personal skills go in `~/.copilot/skills/` or `~/.claude/skills/`
- Verify the directory exists and contains SKILL.md

## Resources

- [GitHub Copilot Skills Documentation](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
- [Open Agent Skills Standard](https://github.com/agentskills/agentskills)
- [Community Skills Examples](https://github.com/anthropics/skills)
- [GitHub Awesome Copilot](https://github.com/github/awesome-copilot)
