---
title: Decision Log Template
description: Structured format for logging AI decision-making in skills and workflows
version: 1.0
---

# Decision Log Template

Use this template to document decisions made during skill execution. These logs provide transparency into the reasoning process and enable better auditing.

## Log Entry Header

```markdown
## DECISION LOG: [Operation Name]

timestamp: 2026-02-13T14:25:00Z
execution_id: dec_20260213_001
context: [Brief context for why this decision was needed]
impact: [How does this decision affect the outcome? High/Medium/Low]
reversibility: [Reversible / Limited Reversibility / Irreversible]
risk_level: [Low / Medium / High]
```

## Decision Entry Format

Use this structure for each decision point:

### Decision [N]: [Decision Title]

**Context:**
- What triggered this decision?
- What constraints apply?
- Who/what requested this?

**Options Considered:**

**Option A: [Description]** [SELECTED/REJECTED]
- Pros:
  - Advantage 1
  - Advantage 2
- Cons:
  - Disadvantage 1
  - Disadvantage 2
- Assumptions: [What must be true for this to work?]
- Dependencies: [What else must happen first?]

**Option B: [Description]** [SELECTED/REJECTED]
- Pros:
  - Advantage 1
- Cons:
  - Disadvantage 1
- Assumptions: [...]
- Dependencies: [...]

**Option C: [Description]** [REJECTED]
- Reason for rejection: [Why not this option?]

**Rationale for Selection:**
[Why was Option A chosen over alternatives? Include trade-offs and constraints that influenced decision.]

**Alternative if requirements change:**
[If the assumption no longer holds, which option becomes better?]

**Reversibility Assessment:**
- ✅ Reversible: Can be changed later if needed
- ⚠️ Limited reversibility: Can be changed but with some cost
- ❌ Irreversible: Cannot be undone without major rework

**Implementation Details:**
[Specific steps, file locations, commands, or code that implements this decision]

**Validation:**
[How will we know this decision was the right one? Measurable criteria]

---

## Complete Example

### Decision 1: Directory Structure for Project-Level Skill

**Context:**
- User requested creation of a new "test-automation" skill
- Skill should be usable by the entire team
- No prior skill for this purpose exists

**Options Considered:**

**Option A: Project-level in .github/skills/test-automation/** ✅ SELECTED
- Pros:
  - Version-controlled with repo
  - Shared with entire team via git
  - CI/CD can automatically use it
  - Clear discovery mechanism
- Cons:
  - Tied to this repository specifically
  - Requires repository access to modify
  - Not shareable across other projects without copy/paste
- Assumptions: Team wants centralized control; repo is source of truth
- Dependencies: Git repository is already set up

**Option B: Personal in ~/.copilot/skills/test-automation/** REJECTED
- Pros:
  - Personal ownership, fewer approval gates
  - Can be reused across projects
- Cons:
  - Not visible to other team members
  - Not version-controlled
  - Won't work in CI/CD easily
  - Each person must set up independently
- Reason for rejection: Doesn't meet team sharing requirement

**Option C: Standalone GitHub repository** REJECTED
- Reason for rejection: Premature for community adoption; not needed until skill is battle-tested

**Rationale for Selection:**
Default to project-level because:
1. Team collaboration is explicitly required
2. Version control is critical for reproducibility
3. CI/CD integration is likely needed
4. If needs change, can migrate to personal/community later with a script

**Alternative if requirements change:**
If the user later wants personal-only access, they can cp -r from .github/skills to ~/.copilot/skills/

**Reversibility Assessment:**
✅ Fully reversible: Moving between locations is a simple file move

**Implementation Details:**
```bash
mkdir -p .github/skills/test-automation
# Then create Skill.md and scripts in that directory
```

**Validation:**
- [ ] Directory exists at .github/skills/test-automation
- [ ] SKILL.md file present with valid frontmatter
- [ ] Can be loaded by Copilot from project context
- [ ] Git can track changes

---

### Decision 2: Include Scaffolding Script (create-skill.sh)

**Context:**
- Need to make skill-creation repeatable and error-free
- Team members should be able to create new skills without manual steps
- Errors in manual skill directory setup are common

**Options Considered:**

**Option A: Bash scaffolding script (create-skill.sh)** ✅ SELECTED
- Pros:
  - Portable; works in any Unix environment
  - No additional dependencies (bash is already available)
  - Integrates well with CI/CD pipelines
  - Simple to maintain and audit
- Cons:
  - Limited error handling compared to Python
  - Less readable complex logic
  - Platform-specific (Linux/Mac only)
- Assumptions: Team uses bash; Windows users have WSL
- Dependencies: bash 4.0+, standard Unix tools (mkdir, chmod)

**Option B: Python script** REJECTED
- Pros:
  - Better error handling and data structures
  - More readable
- Cons:
  - Adds Python dependency
  - Requires Python environment setup
  - Slower startup
- Reason for rejection: Current environment already has working bash; adding Python is unnecessary complexity

**Option C: No script; just document manual steps** REJECTED
- Reason for rejection: Manual steps lead to errors and inconsistency; defeats purpose of standardized skill structure

**Rationale for Selection:**
Bash selected for maximum portability in existing build environment. Users already run build scripts in bash; adding another scripting language introduces friction.

**Alternative if requirements change:**
If Windows native (non-WSL) support becomes critical, convert to Python/Go cross-platform script.

**Reversibility Assessment:**
✅ Fully reversible: Can be replaced or removed without affecting created skills

**Implementation Details:**
```bash
# Script location: .github/skills/create-agent-skills/scripts/create-skill.sh
# Usage: ./create-skill.sh <skill-name> <description> [license]
# Creates: .github/skills/<skill-name>/SKILL.md + directory structure
```

**Validation:**
- [ ] Script runs without errors
- [ ] Produces valid SKILL.md with correct frontmatter
- [ ] Directory structure matches specification
- [ ] All files have correct permissions

---

## Usage in Skills

When a skill makes a decision, include a decision log entry:

```markdown
# My Skill

[Regular SKILL.md content...]

## Implementation Decisions

[Decision Log entries explaining key choices]
```

## Why This Matters

- **Auditing**: Reviewers can understand reasoning, not just outcomes
- **Learning**: Team learns decision-making patterns
- **Reversibility**: Clear understanding of trade-offs helps with future changes
- **Reproducibility**: Documented assumptions help others replicate decisions
- **Safety**: High-risk decisions are flagged explicitly

## Decision Classification

### Risk Levels

- **Low**: Easily reversible, no external dependencies affected
  - Example: Choice between two equivalent script names
- **Medium**: Reversible with some effort, affects local structure
  - Example: Directory layout choice
- **High**: Significant effort to reverse, affects multiple systems
  - Example: Build system choice, dependency decisions

### Reversibility Tiers

- **✅ Reversible**: Can be changed at any time with minimal cost
- **⚠️ Limited**: Can be changed but requires migration work
- **❌ Irreversible**: Changing would require major rework or cause breaking changes

## Tools & Integration

To validate decision logs:

```bash
# Check all decision logs exist and are valid YAML
find .github/skills -name "DECISION_LOG.md" -exec \
  grep -l "^timestamp:" {} \;

# Extract decisions for high-risk operations
grep "risk_level: High" .github/skills/*/DECISION_LOG.md

# Generate decision audit report
./tools/generate-decision-audit.sh
```

## See Also

- [AI Skill Architecture Review](_ARCHITECTURE_REVIEW.md)
- [Skill Templates](templates/)
- [Validation Schemas](_schemas/)
