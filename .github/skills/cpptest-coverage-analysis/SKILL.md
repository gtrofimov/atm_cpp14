---
name: cpptest-coverage-analysis
description: Analyze code coverage using C/C++test (cpptest-ct). Use this skill to run unit tests with coverage instrumentation, compute coverage metrics, and generate coverage reports for the ATM C++ project.
license: MIT
---

# C/C++test Coverage Analysis Skill

This skill enables you to perform comprehensive code coverage analysis using C/C++test (cpptest-ct) for the ATM C++14 project. It guides the agent through setting up coverage instrumentation, running tests, and generating coverage reports.

## When to use this skill

Use this skill when you need to:
- Run unit tests with coverage instrumentation enabled
- Analyze code coverage metrics and identify untested areas
- Generate HTML coverage reports
- Evaluate test effectiveness
- Identify gaps in test coverage for specific functions or files
- Track coverage improvements over time

## Quick Start

Run: `./.github/skills/cpptest-coverage-analysis/run-coverage.sh` or `OUTPUT_JSON=1` for JSON output.

## Prerequisites

- `CPPTEST_HOME` environment variable set to C/C++test installation
- If `CPPTEST_CT` is set, treat it as the source of truth for `CPPTEST_HOME`
- Valid C/C++test license
- CMake-based C++ project with GoogleTest integration

## Step-by-step process

### 1. Clean rebuild with coverage

```bash
cd /home/gtrofimov/parasoft/git/atm_cpp14
rm -rf build && mkdir build && cd build
cmake -DCPPTEST_COVERAGE=ON .. && make clean all -j4
```

### 2. Run instrumented tests

```bash
./atm_gtest
```

GoogleTest sources live in `tests/gt`.

### 3. Compute coverage metrics

```bash
make cpptestcov-compute
```

### 4. Generate report

```bash
make cpptestcov-report
```

## Understanding Coverage Metrics

For detailed metric descriptions, see [Common Patterns: Coverage Metrics](../COMMON_PATTERNS.md#coverage-metrics-cctest-ct).

## Interpreting Results

Results show file-level and function-level coverage. Low coverage areas indicate untested code paths. See [Common Patterns: Coverage Metrics](../COMMON_PATTERNS.md#coverage-metrics-cctest-ct) for metric descriptions.

## Coverage targets

See [Common Patterns: Coverage Targets](../COMMON_PATTERNS.md#coverage-targets) for recommended coverage goals.

## Troubleshooting

For general troubleshooting (license errors, missing data, build configuration), see [Common Patterns: Troubleshooting](../COMMON_PATTERNS.md#general-troubleshooting).

### Coverage-specific issues

**Coverage maps not generated?**
- Ensure clean rebuild with `-DCPPTEST_COVERAGE=ON` enabled from start of configuration
- Verify `cpptest-coverage/${PROJECT_NAME}/` directory exists after build

**Instrumentation not detected?**
- Look for `cpptestcc` compiler wrapper in build output
- If missing, verify `CPPTEST_HOME` is correct and in PATH

## Example workflow

```bash
export CPPTEST_HOME=${CPPTEST_CT:-/home/gtrofimov/parasoft/2025.2/ct/cpptest-ct}
cd /home/gtrofimov/parasoft/git/atm_cpp14
rm -rf build && mkdir build && cd build
cmake -DCPPTEST_COVERAGE=ON .. && make -j4
./atm_gtest
make cpptestcov-compute cpptestcov-report
```

## Output locations

- **Coverage database**: `.coverage/`
- **Coverage maps**: `build/cpptest-coverage/`
- **Report**: `build/coverage_report.txt`
- **Summary**: `reports/summary/coverage_summary.md`

## Coverage script options

Environment variables:

- `CLEAN_COVERAGE=1` - Delete stale coverage data before rebuild
- `AUTO_REBUILD_ON_MISMATCH=1` - Retry clean rebuild if compute fails
- `WRITE_DELTA_SUMMARY=1` - Write LC/MCDC by-file summary
- `REPORT_FILTER_PATHS=1` - Filter report to `src/` and `include/`
- `OUTPUT_JSON=1` - Write JSON summary
- `SUMMARY_DIR=/path` - Customize summary output location

## Viewing coverage in VS Code

If you have the Parasoft C/C++test VS Code extension installed, you can view
coverage highlights directly in the editor once the `.coverage` folder contains
`coverage.index` and `.cov` files.

1. Open the project in VS Code.
2. Open the Command Palette and run `C/C++test: Show Coverage...`.
3. Select a coverage type (e.g., Line Coverage).
4. Open a source file such as `src/Account.cxx` and review highlights.

If your coverage data lives outside the workspace, set the folder in
`Extensions > C/C++test > Coverage Data Folder` and re-run `Show Coverage...`.

## Tips for improving coverage

1. **Write targeted tests** for functions with low coverage
2. **Test edge cases** to improve branch and decision coverage
3. **Mock external dependencies** to reach normally unreachable code
4. **Test error conditions** to exercise exception handling paths
5. **Iterate**: Re-run tests, review gaps, write more tests

## Advanced: Using C/C++test MCP Server

The C/C++test-ct Model Context Protocol (MCP) server provides powerful tools for programmatic access to coverage data and tools. These tools can be accessed through connected development tools.

### Available MCP Tools

The following MCP tools are available for deeper coverage analysis:

#### Query Line Coverage

Use `mcp_cpptest-ct_query_line_coverage` to query coverage information for specific source files:

```
Tool: mcp_cpptest-ct_query_line_coverage
Parameters:
  - source_file: Absolute path to the source file
  - query_type: 'coverable', 'covered', 'notcovered', or 'suppressed'
  - coverage_data_dir: Directory with .cov files (typically '.coverage')

Example:
  source_file: /home/gtrofimov/parasoft/git/atm_cpp14/src/Bank.cxx
  query_type: notcovered
  coverage_data_dir: /home/gtrofimov/parasoft/git/atm_cpp14/.coverage
```

This allows you to:
- Get all coverable lines in a file
- Find which lines were actually covered
- Identify untested lines
- Check for suppressed lines

#### Search C/C++test Documentation

Use `mcp_cpptest-ct_search_documentation` to find relevant documentation topics:

```
Tool: mcp_cpptest-ct_search_documentation
Parameters:
  - user_query: Natural language search query

Examples:
  - Query: "how to enable code coverage reporting"
  - Query: "HTML report generation settings"
  - Query: "coverage type instrumentation options"
```

#### Coverage Suppression

Use `mcp_cpptest-ct_how_to_suppress_coverage` to learn how to suppress coverage for specific code:

```
Tool: mcp_cpptest-ct_how_to_suppress_coverage

This returns instructions on:
- Suppressing coverage for entire files
- Suppressing coverage for specific lines
- Annotation syntax and pragmas
- Best practices for coverage suppressions
```

### Example MCP-based workflow

Here's how to use MCP tools for comprehensive coverage analysis:

```
1. Generate initial coverage report (as described above)

2. Query uncovered lines in ATM.cxx:
   mcp_cpptest-ct_query_line_coverage(
     source_file: "/home/gtrofimov/parasoft/git/atm_cpp14/src/ATM.cxx",
     query_type: "notcovered",
     coverage_data_dir: "/home/gtrofimov/parasoft/git/atm_cpp14/.coverage"
   )

3. Query covered lines in Account.cxx:
   mcp_cpptest-ct_query_line_coverage(
     source_file: "/home/gtrofimov/parasoft/git/atm_cpp14/src/Account.cxx",
     query_type: "covered",
     coverage_data_dir: "/home/gtrofimov/parasoft/git/atm_cpp14/.coverage"
   )

4. Search for documentation on improving coverage:
   mcp_cpptest-ct_search_documentation(
     user_query: "improve modified condition decision coverage MCDC"
   )

5. Learn how to suppress coverage for legacy code:
   mcp_cpptest-ct_how_to_suppress_coverage()
```

### Identifying test gaps with MCP

Using MCP tools, you can systematically identify where to write tests:

1. **Find untested files**:
   - Query each source file for coverable vs notcovered lines
   - Prioritize files with 0% coverage

2. **Analyze decision coverage gaps**:
   - Search documentation for MCDC metrics
   - Identify branches not taken
   - Plan test cases for all branch combinations

3. **Target high-value tests**:
   - Focus on functions called by many other functions
   - Test error handling paths (exception cases)
   - Test boundary conditions

4. **Document suppressions**:
   - Use suppression tool to understand when coverage can be suppressed
   - Document reasons for suppressions
   - Review suppressions during code review

### Integrating MCP into your workflow

To use MCP tools when asking Copilot for coverage analysis:

- "Query coverage for the ATM.cxx file using MCP"
- "Find all untested lines in Account.cxx using the coverage query tool"
- "Help me suppress coverage for deprecated code using MCP"
- "Search cpptest documentation for MCDC coverage best practices"

Copilot will use the appropriate MCP tools to provide accurate, detailed responses backed by your actual coverage data.

## References

- C/C++test coverage types: `cpptestcov -help` for detailed options
- CMake integration: See `cpptest-coverage.cmake` in project root
- Test suite: `/home/gtrofimov/parasoft/git/atm_cpp14/tests/gt/`
- MCP Server: C/C++test-ct MCP protocol server documentation
