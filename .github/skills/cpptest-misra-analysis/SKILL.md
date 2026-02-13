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

### Environment setup
- **C++test Standard installed**: Available via `$CPPTEST_STD` environment variable
- **C++ compiler**: GCC, Clang, or other compatible compiler installed and available in PATH
- **Linux/macOS/Windows**: Compatible with all major platforms
- **Python 3** (optional): For enhanced report parsing and analysis

### Verify installation

```bash
# Check CPPTEST_STD variable is set
echo $CPPTEST_STD

# Verify cpptestcli is available
$CPPTEST_STD/cpptestcli -help

# List available MISRA configurations
$CPPTEST_STD/cpptestcli -list-configs | grep MISRA
```

### Detect compiler configuration

```bash
# Auto-detect your C++ compiler
$CPPTEST_STD/cpptestcli -detect-compiler gcc

# List all available compilers
$CPPTEST_STD/cpptestcli -list-compilers
```

## Step-by-step process

### Step 1: Generate compilation database with CMake

First, create a compilation database to provide exact compiler flags:

```bash
# Create build directory
cmake -B build

# Build project (generates compile_commands.json)
cmake --build build
```

This creates `build/compile_commands.json` containing all compiler invocations.

If `compile_commands.json` is missing, the helper script will regenerate it
automatically using:

```bash
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
```

### Step 2: Verify CPPTEST_STD and detect compiler

```bash
# Verify C++test Standard is installed
echo $CPPTEST_STD
$CPPTEST_STD/cpptestcli -help

# Auto-detect your compiler
$CPPTEST_STD/cpptestcli -detect-compiler gcc
# Output: gcc_13-64 (or similar)
```

### Step 3: Run MISRA analysis using compilation database

The recommended approach uses the compilation database for accurate analysis:

```bash
cd /path/to/project

$CPPTEST_STD/cpptestcli \
  -config "builtin://MISRA C++ 2023" \
  -compiler gcc_13-64 \
  -module . \
  -exclude '**/googletest/**' \
  -exclude '**/googlemock/**' \
  -exclude '**/tests/**' \
  -input build/compile_commands.json \
  -report reports/misra_cpp_2023
```

**Parameters explained:**
- `-config "builtin://MISRA C++ 2023"`: MISRA ruleset
- `-compiler gcc_13-64`: Detected compiler ID
- `-module .`: Analyze current module/project
- `-exclude '**/googletest/**'`: Skip test framework
- `-exclude '**/googlemock/**'`: Skip mock framework  
- `-exclude '**/tests/**'`: Skip test code
- `-input build/compile_commands.json`: Use compilation database
- `-report reports/misra_cpp_2023`: Output report location

### Step 4: Review reports

```bash
# Check violation summary in log
tail -50 misra_analysis.log

# View HTML report
xdg-open reports/report.html  # Linux
open reports/report.html      # macOS

# Analyze XML with Copilot Chat
# Ask: "Parse violations from reports/report.xml and show critical issues"

The helper script also writes a machine-readable summary to:
`reports/misra_cpp_2023/summary.json` with severity counts and top rules.
```

### Automated approach: Use the provided script

For convenience, use the automation script:

```bash
# Run with defaults
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh

# Or with custom settings
export COMPILER=clang_17_0-x86_64
export COMPILE_DB=build/compile_commands.json
export OUTPUT_DIR=reports
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh
```

### Legacy approach: Direct file compilation (not recommended)

If compilation database is unavailable, specify files directly:

```bash
$CPPTEST_STD/cpptestcli \
  -config "builtin://MISRA C++ 2023" \
  -compiler gcc_13-64 \
  -- gcc -Iinclude -std=c++14 src/Account.cxx src/ATM.cxx \
  -report reports/misra_cpp_2023
```

⚠️ **Note:** This approach requires manually specifying all include paths and files, which is error-prone. The compilation database method (-input) is strongly preferred.

## Key considerations

### Compiler flags

- Include all `-I` (include directory) flags needed for compilation
- Consider using `-Wall -Wextra` for additional warning detection
- Match the exact compilation environment of your project

### Report location

- HTML report: `<report-path>/report.html` (human-readable)
- XML report: `<report-path>/report.xml` (programmatic access)

### Common MISRA C++ 2023 violations

| Violation | Issue | Fix |
|-----------|-------|-----|
| `MISRACPP2023-6_9_2-a` | Using `int` type | Use sized types: `int32_t`, `uint16_t` |
| `MISRACPP2023-15_0_2-a` | Move constructor missing `noexcept` | Add `noexcept` specifier |
| `MISRACPP2023-21_6_2-a` | `new` operator usage | Use smart pointers (`std::unique_ptr`) |
| `MISRACPP2023-8_2_2-b` | C-style casts | Use `static_cast`, `reinterpret_cast` |
| `MISRACPP2023-7_11_1-a` | Using `0` or `NULL` for null pointers | Use `nullptr` |

## Examples

### Example 1: Analyze C++ project using compilation database

```bash
cd /home/user/my_project

# Build with CMake (generates compile_commands.json)
cmake -B build && cmake --build build

# Run MISRA analysis
$CPPTEST_STD/cpptestcli \
  -config "builtin://MISRA C++ 2023" \
  -compiler gcc_13-64 \
  -module . \
  -exclude '**/googletest/**' \
  -exclude '**/tests/**' \
  -input build/compile_commands.json \
  -report reports/misra_cpp_2023
```

### Example 2: Using the automation script

```bash
# Run with default settings
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh

# Or with custom environment
export PROJECT_ROOT=/path/to/project
export COMPILER=clang_17_0-x86_64
export COMPILE_DB=build/compile_commands.json
export OUTPUT_DIR=my_reports
./.github/skills/cpptest-misra-analysis/run-misra-analysis.sh
```

### Example 3: Complete analysis with multi-level exclusions

```bash
$CPPTEST_STD/cpptestcli \
  -config "builtin://MISRA C++ 2023" \
  -compiler gcc_13-64 \
  -module . \
  -exclude '**/googletest/**' \
  -exclude '**/googlemock/**' \
  -exclude '**/tests/**' \
  -exclude '**/third_party/**' \
  -exclude '**/vendor/**' \
  -input build/compile_commands.json \
  -report reports/misra_cpp_2023
```

### Example 4: Custom configuration with different MISRA rules

```bash
# Using a custom MISRA configuration
$CPPTEST_STD/cpptestcli \
  -config "user://my-misra-config" \
  -compiler gcc_13-64 \
  -module . \
  -exclude '**/tests/**' \
  -input build/compile_commands.json \
  -report reports/custom_analysis
```

# Review HTML in browser
open reports/report.html

# Parse XML for CI/CD integration
grep -o "violations-suppressed=\"[0-9]*\"" reports/report.xml
```

## Troubleshooting

### Issue: "Input scope contains no elements - nothing to test"

**Solution**: Ensure you provide the compilation command after `--`:

```bash
# Wrong
$CPPTEST_STD/cpptestcli -config "builtin://MISRA C++ 2023" -module .

# Correct
$CPPTEST_STD/cpptestcli -config "builtin://MISRA C++ 2023" \
  -compiler gcc_13-64 \
  -- gcc -Iinclude src/file.cpp
```

### Issue: Compiler not found

**Solution**: Use `-detect-compiler` to find available compilers:

```bash
$CPPTEST_STD/cpptestcli -detect-compiler gcc
$CPPTEST_STD/cpptestcli -list-compilers | grep gcc
```

### Issue: Missing include files during analysis

**Solution**: Add all required `-I` flags to the compilation command:

```bash
# Include multiple paths
-- gcc -Iinclude -Iinclude/subsystem -Ithird_party/boost src/file.cpp
```

### Issue: Reports not generated

**Solution**: Verify write permissions and output directory:

```bash
mkdir -p reports
chmod 755 reports

# Run with verbose output
$CPPTEST_STD/cpptestcli ... -report reports/misra -verbose
```

## Advanced Report Analysis with C++test MCP

C++test's MCP (Model Context Protocol) Server extension provides direct access to violation parsing without additional scripts.

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
