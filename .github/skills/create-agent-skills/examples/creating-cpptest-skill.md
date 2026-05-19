# Example: Creating a Test Coverage Analysis Skill

This example shows how the `create-agent-skills` skill was used to create a real skill in this repository.

## Scenario

A team wants Copilot to help analyze code coverage for C++ projects using C/C++test.

## Using the create-agent-skills skill

### 1. Run the scaffolding script

```bash
cd /path/to/repository
.github/skills/create-agent-skills/scripts/create-skill.sh \
  cpptest-coverage-analysis \
  "Analyze code coverage using C/C++test. Use this for running unit tests with coverage instrumentation."
```

### 2. Output
```
Creating skill structure for: cpptest-coverage-analysis
✓ Created .github/skills/cpptest-coverage-analysis/SKILL.md
✓ Created scripts directory
✓ Created templates directory
✓ Created examples directory

✅ Skill 'cpptest-coverage-analysis' created successfully!
```

### 3. Edit SKILL.md with detailed instructions

Open `.github/skills/cpptest-coverage-analysis/SKILL.md` and fill in:
- When to use this skill
- Prerequisites (CPPTEST_HOME, license requirements, etc.)
- Step-by-step process (build, run tests, generate reports)
- Key considerations and troubleshooting

### 4. Add supporting scripts

Create helper scripts in `scripts/`:
- `run-coverage.sh` - Automates the coverage analysis process
- `setup.sh` - Sets up the environment

### 5. Add templates and examples

- `templates/` - CMake configuration snippets
- `examples/` - Sample coverage reports and expected outputs

## Result

The team now has a reusable skill that:
- Teaches Copilot how to run coverage analysis
- Can be triggered whenever coverage-related tasks are mentioned
- Provides step-by-step guidance for consistent results
- Is version-controlled and shareable with the team

## Key benefits

✅ **Consistency**: Same process every time
✅ **Knowledge transfer**: New team members learn from the skill
✅ **Automation**: Scripts can be run with a single Copilot request
✅ **Documentation**: Instructions live alongside code
✅ **Reusability**: Use the same skill across projects

## Tips from this example

1. **Be specific**: "C++test coverage analysis" not just "testing"
2. **Include environment setup**: Document CPPTEST_HOME and dependencies
3. **Provide scripts**: Automate repetitive steps
4. **Show examples**: Include sample output so Copilot knows what success looks like
5. **Document gotchas**: Mention common issues like license not found, path problems, etc.
