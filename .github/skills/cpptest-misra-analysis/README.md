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

Typical issues found by MISRA C++ 2023:

- **Integer types**: Use of bare `int` type (use `int32_t`, `uint16_t`)
- **Move constructors**: Missing `noexcept` specifier
- **Dynamic allocation**: Use of `new` operator (prefer smart pointers)
- **Null pointers**: Using `0` or `NULL` (use `nullptr`)
- **Casting**: C-style casts (use `static_cast`, `reinterpret_cast`)
- **Using directives**: Global namespace `using` declarations
- **Switch statements**: Missing `default` labels

## Output Files

After running analysis:

```
reports/
├── report.html              # Human-readable report
├── report.xml               # Machine-parseable results
└── misra_cpp_2023.json      # Analysis metadata
```

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

**Error: "Input scope contains no elements"**
- Ensure you provide compilation command after `--`

**Error: "Compiler not found"**
- Run `$CPPTEST_STD/cpptestcli -list-compilers` to see available compilers

**No source files found**
- Verify include paths and source file patterns are correct
- Check that files exist: `ls -la src/*.cxx include/`

## Advanced: Report Analysis via Copilot Chat

Ask Copilot to analyze your MISRA report using the built-in C++test MCP integration:

**In Copilot Chat (VS Code):**

```
@GitHub Copilot
Parse the violations from reports/report.xml and:
1. Group by severity
2. Show top 10 most frequent violations
3. Highlight critical issues
4. Suggest fixes for high-priority violations
```

### MCP Capabilities

C++test's MCP Server enables:
- Direct XML report parsing
- Violation filtering by rule, severity, or file
- Rule documentation and explanations
- Context-aware remediation suggestions
- No additional tools or dependencies needed

### Benefits Over Custom Tools

✓ **Native Integration** - Uses C++test's built-in analysis system
✓ **AI-Powered** - Intelligent recommendations from Copilot
✓ **No Dependencies** - No Python or additional tools required
✓ **Real-time Queries** - Ask questions in Copilot Chat
✓ **Always Updated** - Leverages latest C++test features

## References

- [MISRA C++ 2023](https://www.misra.org.uk/)
- [Parasoft C++test Documentation](https://docs.parasoft.com/display/CPP)
- [C++test Standard User Guide](https://docs.parasoft.com/display/CPP/C%2B%2Btest+Standard)
