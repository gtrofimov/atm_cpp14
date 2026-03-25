# C/C++test Coverage Analysis Skill

This Agent Skill enables GitHub Copilot to perform comprehensive code coverage analysis using C/C++test (cpptest-ct) on the ATM C++14 project.

## Files in this skill

- **SKILL.md** - Main skill definition with instructions and MCP tool integration
- **run-coverage.sh** - Automated helper script to run the full coverage workflow
- **mcp-coverage-guide.sh** - Interactive guide for using MCP tools for advanced queries
- **mcp-examples.json** - Reference guide with MCP tool examples and patterns
- **README.md** - This file

## Quick start

### Option 1: Let Copilot use the skill automatically

Simply ask Copilot to analyze code coverage or run tests with coverage instrumentation. For example:

- "Analyze code coverage for this project"
- "Run tests and collect coverage metrics using cpptest-ct"
- "Which parts of the code are not covered by tests?"
- "Generate a coverage report"

### Option 2: Use the advanced MCP tools

Ask Copilot to use MCP tools for detailed coverage queries:

- "Find all untested lines in Account.cxx using MCP"
- "What functions have 0% coverage? Query using MCP coverage tools"
- "Search cpptest documentation for MCDC coverage best practices"
- "Show me how to suppress coverage for deprecated code"

### Option 3: Run the automation scripts directly

Basic coverage:
```bash
.cursor/skills/cpptest-coverage-analysis/run-coverage.sh
```

MCP coverage guide:
```bash
.cursor/skills/cpptest-coverage-analysis/mcp-coverage-guide.sh
```

## What Copilot can do with this skill

The skill teaches Copilot to:

✓ Set up C/C++test coverage instrumentation in CMake builds  
✓ Run unit tests with coverage tracking enabled  
✓ Interpret coverage metrics (LC, SC, BC, DC, MCDC, FC, CC)  
✓ Identify untested code and functions  
✓ Suggest which areas need more test coverage  
✓ Generate and explain coverage reports  
✓ Help write tests for uncovered code paths  

### MCP-Enhanced Capabilities

With MCP tools, Copilot can also:

✓ Query specific uncovered/covered lines using `mcp_cpptest-ct_query_line_coverage`  
✓ Search C/C++test documentation using `mcp_cpptest-ct_search_documentation`  
✓ Learn coverage suppression techniques using `mcp_cpptest-ct_how_to_suppress_coverage`  
✓ Perform detailed gap analysis on actual coverage data  
✓ Generate targeted test recommendations based on uncovered lines  
✓ Help improve MCDC and branch coverage metrics  

## Coverage metrics explained

For detailed metric descriptions and coverage targets, see [Common Patterns: Coverage Metrics](../COMMON_PATTERNS.md#coverage-metrics-cctest-ct).

## Current project coverage

Latest results:

```
Overall Coverage:
- Line Coverage (LC): 26% (42/160 lines)
- Statement Coverage (SC): 25% (42/166 statements)
- Function Coverage (FC): 26% (16/62 functions)
- MCDC: 33% (6/18)

By component:
- Bank.cxx: 100% LC (Excellent!)
- Account.cxx: 38% LC (Needs work)
- BaseDisplay.cxx: 6% LC (Critical gap)
- ATM.cxx: 0% LC (No tests)
```

## Requirements

- C/C++test version 2025.2 or later installed at `/home/gtrofimov/parasoft/2025.2/ct/cpptest-ct`
- Valid C/C++test license
- CMake 3.11+
- GoogleTest framework (included in project)
- Linux/Unix environment

## Environment setup

Set the CPPTEST_HOME variable before running coverage analysis:

```bash
export CPPTEST_HOME=/home/gtrofimov/parasoft/2025.2/ct/cpptest-ct
```

## Troubleshooting

For general troubleshooting guidance, see [Common Patterns: Troubleshooting](../COMMON_PATTERNS.md#general-troubleshooting).

**Coverage-specific issues?** Check SKILL.md for coverage map errors and instrumentation detection.

## Learn more

- See SKILL.md for detailed step-by-step instructions
- Run `cpptestcov -help` for advanced options
- Check project README.md for general setup instructions

## VS Code coverage highlights

If you use the Parasoft C/C++test VS Code extension, you can enable in-editor
coverage highlights after running the coverage workflow:

1. Ensure `.coverage/coverage.index` and `.cov` files exist.
2. Run `C/C++test: Show Coverage...` from the Command Palette.
3. Pick a coverage type (e.g., Line Coverage) and open a source file.

If coverage data is stored elsewhere, configure `Extensions > C/C++test >
Coverage Data Folder` to point to that location.

## Coverage script options

You can enable additional behavior by setting environment variables before
running `run-coverage.sh`:

- `CLEAN_COVERAGE=1` removes stale `.clog` and `.coverage` data before rebuild.
- `AUTO_REBUILD_ON_MISMATCH=1` retries a clean rebuild if compute fails.
- `WRITE_DELTA_SUMMARY=1` writes a short LC/MCDC by-file summary.
- `REPORT_FILTER_PATHS=1` generates a filtered report for `src/` and `include/`.
- `REPORT_FILTER_REGEX="/src/|/include/"` customizes the filter pattern.
- `OUTPUT_JSON=1` writes a structured JSON summary.
- `JSON_OUTPUT_PATH=/path/to/file.json` customizes the JSON output path.
- `JSON_OUTPUT_STDOUT=1` also prints the JSON to stdout.
