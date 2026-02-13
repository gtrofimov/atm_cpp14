#!/bin/bash

# Skill scaffolding script
# Usage: create-skill.sh <skill-name> <skill-description>
# Example: create-skill.sh my-testing-skill "Run automated tests for Node.js projects"

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <skill-name> <skill-description> [license]"
    echo ""
    echo "Example:"
    echo "  $0 my-testing-skill 'Run automated tests for Node.js projects' MIT"
    echo ""
    echo "Note: skill-name should be lowercase with hyphens (e.g., my-skill-name)"
    exit 1
fi

SKILL_NAME="$1"
SKILL_DESCRIPTION="$2"
LICENSE="${3:-MIT}"
SKILL_DIR=".github/skills/$SKILL_NAME"
SKILLS_ROOT="${SKILLS_ROOT:-.github/skills}"

# Validate skill name format
if ! [[ "$SKILL_NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "Error: Skill name must be lowercase with hyphens and alphanumeric characters."
    echo "Example: my-skill-name (not My-Skill-Name or my_skill_name)"
    exit 1
fi

# Check if skill already exists
if [ -d "$SKILL_DIR" ]; then
    echo "Error: Skill directory already exists: $SKILL_DIR"
    exit 1
fi

# Create directory structure
echo "Creating skill structure for: $SKILL_NAME"
mkdir -p "$SKILL_DIR/scripts"
mkdir -p "$SKILL_DIR/templates"
mkdir -p "$SKILL_DIR/examples"

# Create SKILL.md file
cat > "$SKILL_DIR/SKILL.md" << EOF
---
name: $SKILL_NAME
description: $SKILL_DESCRIPTION
license: $LICENSE
---

# $(echo "$SKILL_NAME" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

Brief introduction explaining what this skill does.

## When to use this skill

- Use case 1
- Use case 2
- Use case 3

## Prerequisites

List any requirements:
- Environment setup
- Required tools
- Permissions

## Step-by-step process

### Step 1: First action

Detailed instructions for the first step.

\`\`\`bash
# Example commands
command --flag
\`\`\`

### Step 2: Second action

More instructions...

## Key considerations

- Important gotchas
- Best practices
- Common mistakes to avoid

## Examples

Provide concrete examples of how to use this skill.

## Troubleshooting

Common issues and solutions.
EOF

echo "✓ Created $SKILL_DIR/SKILL.md"

# Create template README for scripts directory
cat > "$SKILL_DIR/scripts/README.md" << EOF
# Scripts

Add executable scripts here that automate tasks for this skill.

Example:
\`\`\`bash
#!/bin/bash
# Your script content
\`\`\`

Don't forget to make scripts executable:
\`\`\`bash
chmod +x script-name.sh
\`\`\`
EOF

echo "✓ Created scripts directory"

# Create templates directory README
cat > "$SKILL_DIR/templates/README.md" << EOF
# Templates

Add configuration templates, examples, or boilerplate files here.

These files can be used as references or starting points for tasks.
EOF

echo "✓ Created templates directory"

# Create examples directory README
cat > "$SKILL_DIR/examples/README.md" << EOF
# Examples

Add example files, sample outputs, or walkthrough documentation here.

Examples help users understand how to apply this skill.
EOF

echo "✓ Created examples directory"

echo ""
echo "✅ Skill '$SKILL_NAME' created successfully!"
echo ""
echo "Next steps:"
echo "1. Edit $SKILL_DIR/SKILL.md with your skill's instructions"
echo "2. Add any scripts to $SKILL_DIR/scripts/"
echo "3. Add templates/examples to their respective directories"
echo "4. Test your skill with an actual task"
echo ""
echo "Skill directory structure:"
echo "$SKILL_DIR/"
echo "├── SKILL.md"
echo "├── scripts/"
echo "├── templates/"
echo "└── examples/"
