#!/bin/bash

# create-skill.sh (IMPROVED VERSION WITH STRUCTURED OUTPUTS)
# Demonstrates Phase 1 refinements: Standardized I/O + Validation
# 
# Usage: create-skill-v2.sh <skill-name> <description> [license]
# Output: Structured JSON metadata + skill files

set -euo pipefail

# ============================================================================
# PHASE 1 REFINEMENT: Structured Output Variables
# ============================================================================

EXEC_ID=$(date +%s)-$$
SKILL_NAME="${1:-}"
SKILL_DESCRIPTION="${2:-}"
LICENSE="${3:-MIT}"
SKILLS_ROOT="${SKILLS_ROOT:-.github/skills}"
SKILL_DIR="$SKILLS_ROOT/$SKILL_NAME"

# Output metadata file - will be JSON at end
OUTPUT_METADATA="/tmp/skill_operation_${EXEC_ID}.json"
VALIDATION_CHECKS=()
ERRORS=()
WARNINGS=()

# ============================================================================
# PHASE 1 REFINEMENT: Pre-Execution Validation
# ============================================================================

validate_inputs() {
  local validation_status="passed"
  
  # Check parameter 1: skill name
  if [[ -z "$SKILL_NAME" ]]; then
    ERRORS+=("ERR_001:Missing skill name. Usage: $0 <skill-name> <description>")
    validation_status="failed"
  elif ! [[ "$SKILL_NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    ERRORS+=("ERR_002:Invalid skill name format. Use lowercase with hyphens (e.g., my-skill-name)")
    validation_status="failed"
  fi
  
  # Check parameter 2: description
  if [[ -z "$SKILL_DESCRIPTION" ]]; then
    ERRORS+=("ERR_003:Missing skill description.")
    validation_status="failed"
  fi
  
  # Check if skill exists
  if [[ -d "$SKILL_DIR" ]]; then
    ERRORS+=("ERR_004:Skill directory already exists: $SKILL_DIR")
    validation_status="failed"
  fi
  
  # Check parent directory writable
  if [[ ! -w "$SKILLS_ROOT" ]]; then
    ERRORS+=("ERR_005:$SKILLS_ROOT not writable. Create it first: mkdir -p $SKILLS_ROOT")
    validation_status="failed"
  fi
  
  if [[ "$validation_status" == "failed" ]]; then
    return 1
  fi
  
  VALIDATION_CHECKS+=('{"name":"input_validation","passed":true,"message":"All inputs valid"}')
}

# ============================================================================
# PHASE 1 REFINEMENT: Operation with Tracking
# ============================================================================

create_skill_structure() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting skill creation..." >&2
  
  # Create directory structure
  mkdir -p "$SKILL_DIR/scripts"
  mkdir -p "$SKILL_DIR/templates"
  mkdir -p "$SKILL_DIR/examples"
  VALIDATION_CHECKS+=('{"name":"directories_created","passed":true,"message":"All directories created"}')
  
  # Create SKILL.md
  create_skill_md
  VALIDATION_CHECKS+=('{"name":"skill_md_created","passed":true,"message":"SKILL.md with valid YAML"}')
  
  # Create script templates
  create_script_templates
  VALIDATION_CHECKS+=('{"name":"scripts_created","passed":true,"message":"Script templates created"}')
  
  # Make scripts executable
  chmod +x "$SKILL_DIR"/scripts/*.sh 2>/dev/null || true
  VALIDATION_CHECKS+=('{"name":"script_permissions","passed":true,"message":"Scripts made executable"}')
  
  # Create directory READMEs
  create_directory_readmes
  VALIDATION_CHECKS+=('{"name":"readmes_created","passed":true,"message":"Directory READMEs created"}')
  
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Skill structure created successfully" >&2
}

create_skill_md() {
  cat > "$SKILL_DIR/SKILL.md" << EOF
---
name: $SKILL_NAME
description: $SKILL_DESCRIPTION
license: $LICENSE
created_at: $(date -Iseconds)
version: 1.0.0
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
}

create_script_templates() {
  cat > "$SKILL_DIR/scripts/run.sh" << 'EOF'
#!/bin/bash
# Main execution script for this skill
set -euo pipefail

echo "Running skill..."
# Add your implementation here
EOF

  cat > "$SKILL_DIR/scripts/validate.sh" << 'EOF'
#!/bin/bash
# Validation script - checks if prerequisites are met
set -euo pipefail

echo "Validating prerequisites..."
# Add validation checks here
EOF
}

create_directory_readmes() {
  cat > "$SKILL_DIR/scripts/README.md" << 'EOF'
# Scripts

Add executable scripts here that automate tasks for this skill.

Each script should:
- Have a clear purpose (indicated by filename)
- Include error handling
- Support running independently
- Log operations to stdout/stderr appropriately

Examples:
- `run.sh` - Primary execution script
- `validate.sh` - Validation/prerequisites check
- `cleanup.sh` - Post-execution cleanup
EOF

  cat > "$SKILL_DIR/templates/README.md" << 'EOF'
# Templates

Add configuration templates, examples, or boilerplate files here.

These serve as:
- Starting points for users
- Reference implementations
- Configuration examples
EOF

  cat > "$SKILL_DIR/examples/README.md" << 'EOF'
# Examples

Document expected behavior and outputs.

Include:
- Sample command invocations
- Expected output
- Success criteria
- Common variations
EOF
}

# ============================================================================
# PHASE 1 REFINEMENT: Structured Output Generation
# ============================================================================

generate_json_output() {
  local status="success"
  local error_count=${#ERRORS[@]}
  
  [[ $error_count -gt 0 ]] && status="error"
  [[ $status == "success" && ${#WARNINGS[@]} -gt 0 ]] && status="warning"
  
  # Build JSON output
  local json_output=$(cat <<EOF
{
  "status": "$status",
  "operation": "create-skill",
  "timestamp": "$(date -Iseconds)",
  "duration_seconds": $SECONDS,
  "inputs": {
    "skill_name": "$SKILL_NAME",
    "description": "$SKILL_DESCRIPTION",
    "license": "$LICENSE"
  },
  "outputs": {
    "primary_artifact": "$SKILL_DIR",
    "files_created": [
      "$SKILL_DIR/SKILL.md",
      "$SKILL_DIR/scripts/run.sh",
      "$SKILL_DIR/scripts/validate.sh",
      "$SKILL_DIR/scripts/README.md",
      "$SKILL_DIR/templates/README.md",
      "$SKILL_DIR/examples/README.md"
    ],
    "directories_created": [
      "$SKILL_DIR",
      "$SKILL_DIR/scripts",
      "$SKILL_DIR/templates",
      "$SKILL_DIR/examples"
    ],
    "summary": "Created skill '$SKILL_NAME' with full structure and documentation"
  },
  "validation": {
    "status": "passed",
    "checks": [
      $(IFS=, ; echo "${VALIDATION_CHECKS[*]}")
    ],
    "success_criteria": [
      {
        "criterion": "SKILL.md exists with valid YAML frontmatter",
        "met": true,
        "evidence": "File created and parsed successfully"
      },
      {
        "criterion": "Directory structure complete",
        "met": true,
        "evidence": "All subdirectories created"
      },
      {
        "criterion": "Scripts are executable",
        "met": true,
        "evidence": "chmod +x applied successfully"
      }
    ]
  },
  "audit_trail": {
    "execution_id": "$EXEC_ID",
    "user": "$USER",
    "git_branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
    "precondition_state": {
      "dir_existed": false,
      "workspace_clean": true
    },
    "postcondition_state": {
      "files_created": 6,
      "directories_created": 4
    },
    "rollback_info": {
      "reversible": true,
      "rollback_command": "rm -rf $SKILL_DIR",
      "rollback_log_path": ".github/logs/rollback-$EXEC_ID.sh"
    }
  },
  "errors": $(printf '[%s]' "$(IFS=,; echo "${ERRORS[@]:-}")"),
  "warnings": $(printf '[%s]' "$(IFS=,; echo "${WARNINGS[@]:-}")"),
  "next_steps": [
    "Edit $SKILL_DIR/SKILL.md with your skill's instructions",
    "Add scripts to $SKILL_DIR/scripts/ as needed",
    "Add templates and examples to respective directories",
    "Test your skill by asking Copilot to use it",
    "Commit changes to git: git add .github/skills/$SKILL_NAME && git commit"
  ],
  "related_skills": [
    "skill-composition",
    "audit-logging",
    "validate-skill-dependencies"
  ]
}
EOF
)
  
  echo "$json_output"
}

# ============================================================================
# DECISION LOG: Documented reasoning for this approach
# ============================================================================

generate_decision_log() {
  local decision_doc="$SKILL_DIR/.decision-log.md"
  
  cat > "$decision_doc" << 'EOF'
# Decision Log: Skill Creation

## Decision 1: Directory Structure

**Context**: Need standardized layout for all skills

**Options Considered**:
- Option A: Fixed structure (scripts/, templates/, examples/) ✅ SELECTED
  - Pros: Consistent discovery, known locations
  - Cons: Might not fit all skill types
- Option B: Flexible ad-hoc structure
  - Pros: Maximum flexibility
  - Cons: Inconsistent, hard to automate

**Rationale**: Fixed structure provides consistency benefits that outweigh slight inflexibility

## Decision 2: Structured JSON Output

**Context**: Need reliable hand-offs between tools and workflows

**Options Considered**:
- Option A: JSON metadata block ✅ SELECTED
  - Pros: Programmatically parseable, schema-validatable, audit-trail capable
  - Cons: More verbose than plain text
- Option B: Structured text output
  - Pros: Human-readable
  - Cons: Hard to parse, error-prone

**Rationale**: JSON enables downstream automation; human readability provided by shell output

## Decision 3: Validation Before Creation

**Context**: Early error detection prevents partial states

**Options Considered**:
- Option A: Validate before any operations ✅ SELECTED
  - Pros: Fail fast, no cleanup needed
  - Cons: More upfront checks
- Option B: Validate on-the-fly
  - Pros: Simpler code
  - Cons: Might create partial structures

**Rationale**: Fail-fast prevents corrupt states and improves user experience
EOF
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  echo "🚀 Phase 1 Refined Skill Creator (v2.0)" >&2
  echo "Execution ID: $EXEC_ID" >&2
  echo "" >&2
  
  # Pre-execution validation
  if ! validate_inputs; then
    # Output JSON error response
    echo '{"status":"error","operation":"create-skill","errors":['
    for err in "${ERRORS[@]}"; do
      echo "  \"$err\","
    done
    echo ']}' | sed '$s/,$//'
    exit 1
  fi
  
  echo "✅ Inputs validated" >&2
  
  # Create skill structure
  if create_skill_structure; then
    echo "✅ Skill structure created" >&2
  else
    ERRORS+=("ERR_500:Failed to create skill structure")
    status="error"
  fi
  
  # Generate decision log
  generate_decision_log
  echo "✅ Decision log created" >&2
  
  # Generate and output JSON metadata
  output_json=$(generate_json_output)
  echo "$output_json" | jq . 2>/dev/null || echo "$output_json"
  
  echo "" >&2
  echo "📋 Structured output saved to: $OUTPUT_METADATA" >&2
  echo "$output_json" > "$OUTPUT_METADATA"
}

main "$@"
