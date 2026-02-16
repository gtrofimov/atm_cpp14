---
name: cpptest-misra-analysis
description: Run MISRA C++ 2023 static analysis on C++ code using C++test Standard. Use this when performing code quality checks, identifying MISRA compliance violations, and generating static analysis reports.
license: MIT
---

# C++test MISRA C++ 2023 Static Analysis

This skill provides automated MISRA C++ 2023 static analysis using Parasoft C++test Standard with integrated AI-powered insights from MCP (Model Context Protocol) capabilities.

**Key Enhancement:** This skill now leverages C++test's MCP Server extension to enable seamless integration with AI agents like GitHub Copilot, providing context-aware analysis, rule interpretation, and automated remediation suggestions.

## When to use this skill

- Running static code quality checks on C++ projects
- Checking MISRA C++ 2023 compliance violations
- Identifying unsafe coding patterns and memory management issues
- Generating HTML and XML analysis reports
- Enforcing coding standards in CI/CD pipelines
- Detecting common C++ anti-patterns

## Prerequisites

- `CPPTEST_STD` environment variable set to C++test Standard installation
- C++ compiler installed (GCC, Clang, or compatible)
- CMake 3.11+ (optional, for `compile_commands.json`)

## Step-by-step process

### 1. Generate compilation database

```bash
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build
```

### 2. Run MISRA analysis

```bash
$CPPTEST_STD/cpptestcli -config "builtin://MISRA C++ 2023" -compiler gcc_13-64 \
  -module . -exclude '**/googletest/**' -exclude '**/tests/**' \
  -input build/compile_commands.json -report reports/misra_cpp_2023
```

### 2a. Run MISRA analysis on files modified vs a reference branch

Use Git SCM properties so C++test can compute the branch diff scope.

```bash
$CPPTEST_STD/cpptestcli -config "builtin://MISRA C++ 2023" -compiler gcc_13-64 \
  -module . -exclude '**/googletest/**' -exclude '**/tests/**' -exclude 'build/_deps/**' \
  -input build/compile_commands.json \
  -property scope.scontrol=true \
  -property scope.scontrol.files.filter.mode=branch \
  -property scope.scontrol.ref.branch=origin/main \
  -property scontrol.rep1.type=git \
  -property scontrol.rep1.git.workspace=/path/to/repo \
  -property scontrol.rep1.git.url=https://example.com/org/repo.git \
  -property scontrol.git.exec=/usr/bin/git \
  -report reports/misra_cpp_2023_branch
```

You can also use the helper script with environment variables:

```bash
SCONTROL_MODE=branch \
SCONTROL_REF_BRANCH=origin/main \
SCONTROL_GIT_WORKSPACE=/path/to/repo \
SCONTROL_GIT_URL=https://example.com/org/repo.git \
SCONTROL_GIT_EXEC=/usr/bin/git \
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh
```

Or use the helper script flags:

```bash
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh --modified \
  --ref-branch origin/main \
  --git-workspace /path/to/repo \
  --git-url https://example.com/org/repo.git \
  --git-exec /usr/bin/git
```

```bash
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh --local \
  --git-workspace /path/to/repo
```

Notes:
- `scope.scontrol.files.filter.mode=branch` compares the current branch to `scope.scontrol.ref.branch`.
- Git SCM properties are required; otherwise branch scope resolves to zero files.

Or use the helper script:

```bash
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh

### 2b. Report only new violations vs a baseline report (default ref branch: origin/main)

Use a baseline report.xml to mark only new findings. When the user asks for
"only new violations" or "new findings vs <branch>" in natural language,
default the ref branch to origin/main and set the baseline report with the
following steps.

1) Extract the baseline report from the ref branch (default path in this repo):

```bash
mkdir -p reports/baseline_origin_main
git show origin/main:reports/misra_cpp_2023_baseline/report.xml > \
  reports/baseline_origin_main/report.xml
```

2) Run MISRA and exclude existing findings using the baseline:

```bash
$CPPTEST_STD/cpptestcli -config "builtin://MISRA C++ 2023" -compiler gcc_13-64 \
  -module . -exclude '**/googletest/**' -exclude '**/tests/**' \
  -input build/compile_commands.json \
  -property goal.ref.report.file=reports/baseline_origin_main/report.xml \
  -property goal.ref.report.findings.exclude=true \
  -report reports/misra_cpp_2023_new_only
```

Notes:
- `goal.ref.report.file` points to the baseline report.xml.
- `goal.ref.report.findings.exclude=true` limits the report to only new findings.
- If the baseline path differs, locate it in origin/main and update the `git show` path.
```

### 3. Review reports

- **HTML**: `reports/misra_cpp_2023/report.html`
- **XML**: `reports/misra_cpp_2023/report.xml`
- **JSON Summary**: `reports/misra_cpp_2023/summary.json`

## Key considerations

### Scope selection from plain language (Default: full scan)

When the user asks to run MISRA analysis, infer the desired scope:

- If the user says "full", "entire project", "all files", or does not specify scope, run the full scan.
- If the user says "modified files", "changed files", "only diff", or references a branch comparison, run branch-diff scope.
- If the user says "local changes" or "working tree", run local scope.

Default behavior is full analysis that reports all violations. Only switch to
"new violations only" when the user explicitly asks for it.

For branch-diff or local scope, ensure Git SCM properties are provided (see section 2a). If not available, ask for the repo workspace path, git executable path, and (for branch scope) reference branch; default to `origin/main` when unspecified.

For "new violations only" requests, use section 2b. If the user does not
specify a ref branch, default to `origin/main` and generate the baseline report
from that branch before running analysis.

### Compiler flags

- Include all `-I` (include directory) flags needed for compilation
- Consider using `-Wall -Wextra` for additional warning detection
- Match the exact compilation environment of your project

### Report location

- HTML report: `<report-path>/report.html` (human-readable)
- XML report: `<report-path>/report.xml` (programmatic access)

### Common MISRA C++ 2023 violations

For a comprehensive table of typical violations and fixes, see [Common Patterns: MISRA Violations](../COMMON_PATTERNS.md#misra-c-2023-common-violations).

## Examples

```bash
# Quick start
export CPPTEST_STD=/path/to/std/cpptest
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh

# Custom compiler
export COMPILER=clang_17_0-x86_64
export OUTPUT_DIR=my_reports
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh
```

## Troubleshooting

For general troubleshooting, see [Common Patterns: Troubleshooting](../COMMON_PATTERNS.md#general-troubleshooting).

### MISRA-specific issues

**Input scope contains no elements:**
- Ensure you provide the compilation command after `--` or use `-input` with compilation database
- For database method: verify `-input build/compile_commands.json` is correct path

**Report not in expected location:**
- Check the specified `-report` directory path
- Verify directory permissions are writable

## Advanced Report Analysis with C++test MCP (Required)

C++test's MCP (Model Context Protocol) Server extension provides direct access to violation parsing without additional scripts. This skill must always use the MCP tool to parse C/C++test SA reports.

### Using Copilot Chat for Report Analysis

In VS Code Copilot Chat, you can ask:

```
@GitHub Copilot
I have a MISRA C++ 2023 analysis report at reports/report.xml. 
Can you:
1. Parse the violations
2. Group by severity  
3. Show top 10 most frequent violations
4. Suggest fixes for critical issues
```

Copilot will automatically:
- Access the report via C++test MCP integration
- Extract and categorize all violations
- Provide severity-based prioritization
- Suggest remediation strategies

### Required tool usage

When parsing a C/C++test SA report, always use the MCP tool:
- `mcp_cpptest-sa_get_violations_from_report_file`

If the MCP tool is unavailable or fails, ask the user whether using Python to parse the report is acceptable. Do not fall back to Python without explicit user approval.

### Programmatic Report Access

The MCP integration allows AI agents to query violations directly:

```python
# Example: What the MCP tool provides
violations = [
  {
    "rule_id": "MISRACPP2023-6_9_2-a",
    "message": "Do not use the 'int' standard integer type",
    "file": "src/Account.cxx",
    "line": "42",
    "severity": "4"
  },
  ...
]
```

### Benefits of MCP-Based Analysis

- **No Dependencies**: No Python or additional tools required
- **Native Integration**: Direct C++test integration
- **AI-Powered**: Leverage Copilot for intelligent analysis
- **Real-time**: Ask questions about violations in chat
- **Filtered Queries**: Filter by rule, severity, or file
- **Context-Aware**: Get explanations and fix suggestions

## VS Code extension tools (Agent mode)

If the Parasoft C/C++test VS Code extension is installed and configured, you can
use its built-in tools in Copilot Chat (Agent mode) for fast analysis without
shell commands:

- `run_static_analysis` to analyze a file or project using the currently
  selected test configuration.
- `get_violations_from_ide` to retrieve violations already loaded in VS Code,
  optionally filtered by file, severity, or rule.

Example prompts:

- "Analyze the active file with C/C++test and summarize MISRA C++ 2023 issues."
- "List severity-1 violations in the IDE for src/Account.cxx."
- "Run static analysis on the project and show top 5 rules with most violations."

## MCP Server Integration (GitHub Copilot & AI Agents)

C++test's MCP Server extension enables AI agents to:

1. **Access Static Analysis Results**: Get violations and categorize by priority
2. **Interpret Rules**: Ask Copilot about specific MISRA C++ rules and get explanations
3. **Propose Fixes**: Get context-aware remediation suggestions in Copilot Chat

### Using with Copilot in VS Code

Ask Copilot questions like:
- "What does MISRACPP2023-6_9_2-a violation mean?"
- "How do I fix the unused return value violations in Account.cxx?"
- "Show me the critical violations in our MISRA analysis"

Copilot can then:
- Query the C++test analysis results via MCP
- Provide targeted guidance for violations
- Generate code fixes aligned with MISRA standards

## Integration with CI/CD

### GitHub Actions example

```yaml
- name: Run MISRA C++ 2023 Analysis
  run: |
    mkdir -p reports
    $CPPTEST_STD/cpptestcli \
      -config "builtin://MISRA C++ 2023" \
      -compiler gcc_13-64 \
      -- gcc -Iinclude src/Account.cxx src/Bank.cxx \
      -report reports/misra_cpp_2023
    
    # Extract violation count
    VIOLATIONS=$(grep -o 'violations="[0-9]*"' reports/report.xml | head -1)
    echo "Static analysis complete: $VIOLATIONS"
```

## References

- [MISRA C++ 2023 Official Guidelines](https://www.misra.org.uk/)
- [Parasoft C++test Documentation](https://docs.parasoft.com/display/CPP)
- [MISRA C++ Rule Compliance](https://www.misra.org.uk/standards-and-community/publications/)
