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
- `CPPTEST_HOME` should be set to the same value as `CPPTEST_STD`
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
  -property scontrol.rep1.git.workspace=/home/user/parasoft/git/atm_cpp14 \
  -property scontrol.rep1.git.url=https://github.com/example/repo.git \
  -property scontrol.git.exec=/usr/bin/git \
  -report reports/misra_cpp_2023_branch
```

**⚠️ CRITICAL:** Use absolute paths for `-property scontrol.rep1.git.workspace`. Relative paths like `.` cause silent failure with 0 files in scope.

For easier setup, use the helper script instead:

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
- If the user says "modified files", "changed files", "only diff", "on branch", or references a branch comparison, run branch-diff scope using `--branch`.
- If the user says "local changes" or "working tree", run local scope using `--local`.

### Violation filtering from plain language (Default: all violations)

When the user asks about violations, infer the desired filtering:

- If the user says "new violations", "new findings", "only new", "vs origin/main", or asks "how many are new", use `--new-violations` to show only violations not in the baseline.
- Default behavior shows all violations in scope. Only switch to "new violations only" when the user explicitly requests it.

### Combining scope and filtering (Branch + New Violations)

You can combine scope and filtering in a single run for precise analysis:

**Example scenarios:**
- "Run MISRA on modified files vs origin/main showing only new violations" → Use `--branch --new-violations`
- "Check which new violations I introduced on this branch" → Use `--branch --new-violations`
- "Show me all violations in my branch" → Use `--branch`
- "What new violations are in my working tree vs origin/main" → Use `--local --new-violations`

### Helper script usage

For branch-diff or local scope, ensure Git SCM properties are provided. If not available, the script will auto-detect the git repository URL. If needed, provide:
- `--git-workspace` - path to git repository (auto-converted to absolute path)
- `--git-url` - remote URL (auto-detected if not provided)
- `--git-exec` - git executable path (defaults to `git`)
- `--ref-branch` - reference branch (defaults to `origin/main`)

**Important:** Git workspace paths are automatically converted to absolute paths internally. This is required for C++test's scope control to correctly match the git repository. If you provide a relative path, it will be converted automatically.

For "new violations only" requests, the script will automatically:
1. Extract the baseline report from `--ref-branch` (default: `origin/main`)
2. Try standard baseline paths: `reports/misra_cpp_2023_baseline/report.xml`
3. Use `goal.ref.report.file` property to exclude existing findings

If you have a custom baseline path, provide it with `--baseline <path>`.

- Report output directories based on analysis scope and filtering

### Compiler flags

- Include all `-I` (include directory) flags needed for compilation
- Consider using `-Wall -Wextra` for additional warning detection
- Match the exact compilation environment of your project

### Report location

- HTML report: `<report-path>/report.html` (human-readable)
- XML report: `<report-path>/report.xml` (programmatic access)

### Common MISRA C++ 2023 violations

For a comprehensive table of typical violations and fixes, see [Common Patterns: MISRA Violations](../COMMON_PATTERNS.md#misra-c-2023-common-violations).

### Suppressing violations

When a violation cannot or should not be fixed, you can suppress it using a `parasoft.suppress` file in the source directory.

**Format:** Plain text with `suppression-begin` / `suppression-end` blocks

```plaintext
# Define suppressions to prevent reporting of selected rule violations
# Note: One suppression entry can affect more than one violation

suppression-begin
file: ATM.cxx
line: 70
rule-id: MISRACPP2023-7_11_1-b
message: Do not use the 'NULL' identifier
reason: Legacy NULL macro usage - pending migration to nullptr
author: developer
date: 2026-02-18
suppression-end

suppression-begin
file: BaseDisplay.cxx
rule-id: MISRACPP2023-6_0_3-a
reason: Global namespace required for C compatibility
author: developer
suppression-end
```

**Suppression fields:**
- `file:` - Filename relative to source root (required)
- `line:` - Specific line number (optional, omit to suppress all occurrences in file)
- `rule-id:` - C++test rule identifier (optional but recommended)
- `message:` - Expected violation message (optional)
- `reason:` - Justification for suppression (optional but strongly recommended)
- `author:` - Person who added the suppression (optional)
- `date:` - Date suppression was added (optional)

**In-code suppressions:**

You can also suppress violations directly in source code using comments:

```cpp
// Single line suppression
// parasoft-suppress MISRACPP2023-7_11_1-b "Approved exception"
myCurrentAccount = NULL;

// Block suppression
// parasoft-begin-suppress MISRACPP2023-8_2_8-b "Intentional pointer cast"
bool isActive = (bool)myCurrentAccount;
// parasoft-end-suppress MISRACPP2023-8_2_8-b
```

**Best practices:**
- Always provide a `reason:` explaining why the violation is acceptable
- Use specific `line:` numbers when possible to avoid over-suppression
- Prefer fixing violations over suppressing them when feasible
- Use in-code suppressions for isolated cases, file suppressions for systematic exceptions
- Review suppressions during code reviews to ensure they remain valid

## Examples

```bash
# Full project scan - all violations
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh

# Modified files only - all violations
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh --branch

# Full project - new violations only (vs origin/main)
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh --new-violations

# Modified files - new violations only (the ultimate check)
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh --branch --new-violations

# Against different branch
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh --branch --ref-branch origin/develop

# Local working tree changes only
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh --local

# Local changes with new violations only
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh --local --new-violations

# Custom baseline report
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh --branch --new-violations \
  --baseline /path/to/custom/baseline.xml

# Custom compiler and output
export COMPILER=clang_17_0-x86_64
export OUTPUT_DIR=my_reports
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh --branch --new-violations
```

## Troubleshooting

For general troubleshooting, see [Common Patterns: Troubleshooting](../COMMON_PATTERNS.md#general-troubleshooting).

### MISRA-specific issues

**Branch scope shows 0 files checked:**
- This occurs when the git workspace path doesn't match what C++test expects
- **Solution**: The helper script automatically converts all paths to absolute paths. If you're calling `cpptestcli` directly, ensure:
  - `-property scontrol.rep1.git.workspace=/absolute/path/to/repo` (not relative paths like `.`)
  - The workspace path exactly matches the git repository root
- Verify with: `cd /your/repo && pwd`

Example (❌ wrong - relative path):
```bash
-property scontrol.rep1.git.workspace=.
```

Example (✅ correct - absolute path):
```bash
-property scontrol.rep1.git.workspace=/home/user/parasoft/git/atm_cpp14
```

**Input scope contains no elements:**
- Ensure you provide the compilation command after `--` or use `-input` with compilation database
- For database method: verify `-input build/compile_commands.json` is correct path
- For branch scope: verify workspace path is absolute and matches git root

**Report not in expected location:**
- Check the specified `-report` directory path
- Verify directory permissions are writable

**Suppressions not working:**
- Verify `parasoft.suppress` file is in the same directory as the source file
- Check suppression format: use `suppression-begin` / `suppression-end` blocks (not XML)
- Ensure `file:` field uses relative path from source root (e.g., `ATM.cxx` not `src/ATM.cxx`)
- For in-code suppressions, use `// parasoft-suppress RULE-ID "reason"` format
- Verify rule ID matches exactly (case-sensitive)
- Check C++test can find the suppress file with `-suppress` property if needed
- Example correct format:
  ```plaintext
  suppression-begin
  file: ATM.cxx
  line: 70
  rule-id: MISRACPP2023-7_11_1-b
  reason: Approved by code review
  suppression-end
  ```

## Advanced Report Analysis with C++test MCP (Required)

C++test's MCP (Model Context Protocol) Server extension provides direct access to violation parsing, rule documentation, and fix suggestions. This skill leverages four MCP tools for comprehensive analysis:

### Available MCP Tools

1. **`mcp_cpptest-sa_get_violations_from_report_file`** - Extract violations from XML reports
   - Filter by rule ID, severity level, or source file
   - Returns structured violation data for analysis

2. **`mcp_cpptest-sa_get_rule_documentation`** - Get detailed rule explanations
   - Understand why a rule exists and its implications
   - Learn standard-compliant coding practices

3. **`mcp_cpptest-sa_get_relevant_rules`** - Search rules by natural language description
   - Find rules related to specific coding issues
   - Discover related compliance rules

4. **`mcp_cpptest-sa_search_documentation`** - Query C++test Standard documentation
   - Find configuration guidance and best practices
   - Troubleshoot analysis issues

### Automated Violation Parsing Workflow

After running analysis, use this workflow to parse and analyze results:

```bash
# 1. Run MISRA analysis (generates reports/misra_cpp_2023/report.xml)
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh

# 2. In Copilot Chat, request automated parsing:
# "Parse violations from reports/misra_cpp_2023/report.xml and provide:
#  - Violation count by severity
#  - Top 5 most frequent rules
#  - Detailed explanations for each rule
#  - Suggested fixes or suppressions for each violation"
```

Copilot will automatically:
- Extract violations using `mcp_cpptest-sa_get_violations_from_report_file`
- Get rule details via `mcp_cpptest-sa_get_rule_documentation`
- Categorize by severity
- Provide code fixes with before/after examples
- Generate suppression entries in correct `parasoft.suppress` format
- Recommend which violations to fix vs. suppress based on rule severity and complexity

### Using Copilot Chat for Report Analysis

In VS Code Copilot Chat, ask for comprehensive analysis:

```
@GitHub Copilot
Analyze the MISRA C++ 2023 violations in reports/misra_cpp_2023_new_only/report.xml:
1. Extract all violations with rule IDs and severity
2. For each rule, explain what it checks and why
3. Show the top 3 most critical issues
4. Provide specific code fixes for each violation
5. Suggest a remediation priority order
```

Copilot will use MCP tools to:
- Parse violations from the XML report
- Retrieve detailed documentation for each rule
- Explain compliance requirements
- Suggest code remediation patterns

### Single-Rule Deep Dives

Get detailed guidance on specific violations:

```
@GitHub Copilot
Explain the MISRACPP2023-7_11_1-a rule and show me exactly how to fix it 
in src/ATM.cxx line 70.
```

Copilot will:
- Use `mcp_cpptest-sa_get_rule_documentation` to fetch rule details
- Reference the exact code location
- Provide compliant code patterns
- Show before/after examples

### Requesting Fixes and Suppressions

Ask Copilot to suggest both fixes and suppressions for violations:

```
@GitHub Copilot
For new violations in modified files, suggest fixes or suppressions. 
Show parasoft.suppress format for suppressions.
```

Copilot will:
- Extract new violations from `reports/misra_cpp_2023_branch_new/report.xml`
- For each violation, provide:
  - Rule explanation from documentation
  - Recommended code fix with before/after comparison
  - Correct `parasoft.suppress` format if suppression is appropriate
  - Reasoning for whether to fix or suppress based on severity and complexity

Example output includes:
- **Fixes** with modernized code (e.g., `NULL` → `nullptr`)
- **Suppressions** in correct plain text format:
  ```plaintext
  suppression-begin
  file: ATM.cxx
  line: 70
  rule-id: MISRACPP2023-7_11_1-b
  reason: Approved deviation
  suppression-end
  ```

### Required tool usage

When parsing a C/C++test SA report, always use the MCP tools:
- `mcp_cpptest-sa_get_violations_from_report_file` for extraction
- `mcp_cpptest-sa_get_rule_documentation` for rule details
- `mcp_cpptest-sa_get_relevant_rules` for rule discovery
- `mcp_cpptest-sa_search_documentation` for configuration help

Do not fall back to Python or manual parsing without explicit user approval.

### Structured Violation Data

The MCP tools provide violations in structured format for easy analysis:

```json
{
  "rule_id": "MISRACPP2023-7_11_1-a",
  "message": "Prefer 'nullptr' to '0' as the null pointer value",
  "file": "src/ATM.cxx",
  "line": "70",
  "severity": "3",
  "location": "line 70, column 15"
}
```

### Common Analysis Patterns

**Get all violations by severity:**
```
@GitHub Copilot
Parse reports/misra_cpp_2023_new_only/report.xml and group violations by severity.
Show count for each severity level.
```

**Find violations in a specific file:**
```
@GitHub Copilot
Extract violations from reports/misra_cpp_2023/report.xml for src/ATM.cxx only.
Group by rule and show most frequent issues.
```

**Get remediation guidance for a rule:**
```
@GitHub Copilot
Get documentation for MISRACPP2023-8_2_2-b and show me how to fix C-style 
casts in src/ATM.cxx line 76.
```

### Benefits of MCP-Based Analysis

- **No Dependencies**: No Python or additional tools required
- **Native Integration**: Direct C++test integration
- **AI-Powered**: Leverage Copilot for intelligent analysis
- **Real-time**: Ask questions about violations in chat
- **Filtered Queries**: Filter by rule, severity, or file
- **Context-Aware**: Get explanations and fix suggestions
- **Complete Coverage**: Access all MCP tools for comprehensive analysis

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

1. **Parse Static Analysis Results**: Extract violations from XML reports with filtering
2. **Interpret Rules**: Query documentation for specific MISRA C++ rules and principles
3. **Discover Related Rules**: Search for rules related to coding issues
4. **Propose Fixes**: Generate context-aware remediation suggestions in Copilot Chat

### Complete Analysis Example

```
@GitHub Copilot
Perform complete analysis of reports/misra_cpp_2023_new_only/report.xml:
1. Parse all violations
2. For each top rule, get detailed documentation
3. Show severity breakdown
4. Suggest fixes for all critical violations
5. Provide a remediation roadmap with priority order
```

### Using with Copilot in VS Code

Ask Copilot questions like:
- "What does MISRACPP2023-7_11_1-a violation mean and how do I fix it?"
- "Parse violations from src/ATM.cxx and explain each rule"
- "Show me the critical violations in our MISRA analysis with suggested fixes"
- "Find all violations related to pointer casting"
- "Get documentation on how to configure C++test for stricter analysis"

Copilot will leverage MCP tools to:
- Extract violations with structured filtering
- Provide comprehensive rule explanations
- Generate code fixes aligned with MISRA standards
- Suggest configuration improvements

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
