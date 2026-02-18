# MISRA C++ 2023 Static Analysis Skill

This agent skill provides automated MISRA C++ 2023 static analysis using Parasoft C++test Standard with:
- **MCP Integration**: Direct C++test report access for AI agents
- **GitHub Copilot Chat**: Ask questions and get intelligent analysis
- **No Extra Dependencies**: Leverages built-in C++test MCP capabilities
- **Severity Categorization**: AI-powered violation prioritization

## Quick Start

### Run analysis on ATM project

```bash
cd ~/.../atm_cpp14
$CPPTEST_STD/cpptestcli \
  -config "builtin://MISRA C++ 2023" \
  -compiler gcc_13-64 \
  -- gcc -Iinclude src/Account.cxx src/ATM.cxx src/Bank.cxx src/BaseDisplay.cxx \
  -report reports/misra_cpp_2023
```

### Using the helper script

```bash
cd /path/to/project

# Run with defaults
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh

# Or customize via environment variables
PROJECT_ROOT=. \
COMPILER=gcc_13-64 \
INCLUDE_DIRS="include" \
SOURCE_FILES="src/Account.cxx src/Bank.cxx" \
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh
```

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Complete skill documentation and instructions |
| `run-misra-analysis.sh` | Automated analysis script with compiler detection |
| `examples.json` | Command examples and violation reference |
| `README.md` | Quick reference (this file) |

## Key Features

- ✅ MISRA C++ 2023 compliance checking
- ✅ Automated compiler detection
- ✅ HTML and XML report generation
- ✅ CI/CD integration ready
- ✅ Comprehensive violation categorization
- ✅ Detailed rules documentation

## Common Violations

For a comprehensive table of typical MISRA violations and fixes, see [Common Patterns: MISRA Violations](../COMMON_PATTERNS.md#misra-c-2023-common-violations).

## Output Files

After running analysis:

```
reports/
├── report.html              # Human-readable report
├── report.xml               # Machine-parseable results
└── misra_cpp_2023.json      # Analysis metadata
```

The helper script also writes:

```
reports/misra_cpp_2023/summary.json
```

This file contains severity counts and the top violated rules.

## Environment Variables

- `CPPTEST_STD`: Path to C++test Standard installation (default: `/home/gtrofimov/parasoft/2025.2/std/cpptest`)
- `PROJECT_ROOT`: Project root directory (default: current directory)
- `COMPILER`: Compiler ID (default: `gcc_13-64`)
- `OUTPUT_DIR`: Output directory for reports (default: `reports`)
- `INCLUDE_DIRS`: Space-separated include directories (default: `include`)
- `SOURCE_FILES`: Source files to analyze (default: `src/*.cxx`)

## Integration Examples

### GitHub Actions

```yaml
- name: MISRA C++ 2023 Analysis
  run: |
    mkdir -p reports
    $CPPTEST_STD/cpptestcli \
      -config "builtin://MISRA C++ 2023" \
      -compiler gcc_13-64 \
      -- gcc -Iinclude src/*.cxx \
      -report reports/misra_cpp_2023
```

### Pre-commit hook

```bash
#!/bin/bash
$CPPTEST_STD/cpptestcli \
  -config "builtin://MISRA C++ 2023" \
  -compiler gcc_13-64 \
  -- gcc -Iinclude $(git diff --cached --name-only | grep '\.cxx$')
```

## Troubleshooting

For general troubleshooting (missing compiler, include paths, output permissions), see [Common Patterns: Troubleshooting](../COMMON_PATTERNS.md#general-troubleshooting).

**Missing compile_commands.json?**
- The helper script will regenerate it using CMake if it is missing
- Ensure CMake is available and the project configures successfully

## Advanced: Comprehensive Report Analysis via MCP Tools

The skill now provides integrated MCP tools for powerful violation parsing and remediation:

### Available MCP Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| `mcp_cpptest-sa_get_violations_from_report_file` | Extract violations from XML reports with filtering | Parse results, filter by severity/rule/file |
| `mcp_cpptest-sa_get_rule_documentation` | Get detailed rule explanations and guidelines | Understand why a rule exists, learn best practices |
| `mcp_cpptest-sa_get_relevant_rules` | Discover rules by natural language query | Find related compliance rules, understand scope |
| `mcp_cpptest-sa_search_documentation` | Query C++test Standard documentation | Configuration, troubleshooting, advanced topics |

### Ask Copilot in Chat

**Complete analysis with all MCP tools:**

```
@GitHub Copilot
Perform a comprehensive analysis of reports/misra_cpp_2023_new_only/report.xml:
1. Extract all violations
2. For each top rule, get detailed documentation
3. Explain severity breakdown
4. Suggest specific code fixes for critical violations
5. Provide remediation priority roadmap
```

**Single-file analysis:**

```
@GitHub Copilot
Parse violations from reports/misra_cpp_2023/report.xml for src/ATM.cxx.
Group by rule and explain each violation with fixes.
```

**Rule deep-dive:**

```
@GitHub Copilot
Get the documentation for MISRACPP2023-7_11_1-a and show how to fix it 
in src/ATM.cxx line 70. Include before/after code examples.
```

**Find related issues:**

```
@GitHub Copilot
Search the C++test documentation for rules related to pointer casting 
and null pointer handling.
```

### Real-World Example

After running analysis:

```bash
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh --modified \
  --ref-branch origin/main
```

Then in Copilot Chat:

```
@GitHub Copilot
The MISRA analysis found 5 new violations. 
Parse reports/misra_cpp_2023_new_only/report.xml and:
1. Show each violation with rule ID, file, and line number
2. Get documentation for each rule
3. Explain what needs to be fixed
4. Provide the corrected code for each violation
```

Copilot will automatically use MCP tools to provide:
- ✅ Structured violation data
- ✅ Rule explanations and rationale
- ✅ Before/after code examples
- ✅ Severity and priority ordering

### MCP Capabilities

C++test's MCP Server enables:
- **Direct XML Parsing** - No dependencies, native C++test integration
- **Flexible Filtering** - Query by rule ID, severity level, or source file
- **Rule Documentation** - Get comprehensive explanations for every violation
- **Fix Suggestions** - Context-aware remediation guidance
- **Related Rules Search** - Discover similar compliance requirements

### Benefits Over Custom Tools

✓ **Native Integration** - Uses C++test's built-in analysis system
✓ **AI-Powered** - Intelligent recommendations from Copilot
✓ **No Dependencies** - No Python or additional tools required
✓ **Real-time Queries** - Ask questions in Copilot Chat
✓ **Immediate Fixes** - Get actionable remediation guidance
✓ **Always Updated** - Leverages latest C++test features
✓ **Complete Coverage** - All four MCP tools work together

## References

- [MISRA C++ 2023](https://www.misra.org.uk/)
- [Parasoft C++test Documentation](https://docs.parasoft.com/display/CPP)
- [C++test Standard User Guide](https://docs.parasoft.com/display/CPP/C%2B%2Btest+Standard)

## VS Code extension tools

With the Parasoft C/C++test VS Code extension configured, Copilot Chat (Agent
mode) can use built-in tools to drive analysis directly from the IDE:

- `run_static_analysis` to run analysis using the selected test configuration.
- `get_violations_from_ide` to query currently loaded violations.

Example prompts:

- "Analyze src/ATM.cxx with C/C++test and summarize MISRA issues."
- "Show severity-1 violations from the IDE results."
