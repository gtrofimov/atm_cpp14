---
name: cpptest-coverage-analysis
description: Analyze code coverage in CMake-based C/C++ projects using C/C++test (cpptest-ct). Use this skill to run focused tests with coverage instrumentation, compute metrics, diagnose coverage failures, and generate reports.
license: MIT
---

# C/C++test Coverage Analysis Skill

This skill enables coverage analysis for CMake-based C/C++ projects using C/C++test (cpptest-ct). It guides the agent through project discovery, coverage instrumentation, focused test execution, data validation, and report generation.

## When to use this skill

Use this skill when you need to:
- Run unit tests with coverage instrumentation enabled
- Analyze code coverage metrics and identify untested areas
- Generate HTML coverage reports
- Evaluate test effectiveness
- Identify gaps in test coverage for specific functions or files
- Track coverage improvements over time

## Quick Start

Run the project's coverage script when one exists. Otherwise use the generic
workflow below. Set `OUTPUT_JSON=1` when the project script supports JSON.

## Prerequisites

- `CPPTEST_HOME` environment variable set to C/C++test installation
- If `CPPTEST_CT` is set, treat it as the source of truth for `CPPTEST_HOME`
- Valid C/C++test license
- CMake-based C or C++ project
- A project test executable or test runner

## Project configuration

Discover these values before running commands. Do not assume target names,
source paths, test frameworks, or repository layout:

```bash
SOURCE_FILE="${SOURCE_FILE:-path/to/source.cxx}"
BUILD_DIR="${BUILD_DIR:-build}"
TEST_TARGET="${TEST_TARGET:-test-target}"
TEST_COMMAND="${TEST_COMMAND:-${BUILD_DIR}/test-runner}"
TEST_ARGS="${TEST_ARGS:-}"
```

Use the project's existing CMake test target and test runner. For CTest,
prefer `ctest --test-dir "$BUILD_DIR"`. For GoogleTest, pass
For GoogleTest, set `TEST_ARGS` to its native filter option. For other
frameworks, set `TEST_ARGS` to their native focused-test option. If no focused option exists,
run the narrowest available test target and state that limitation.

## Step-by-step process

### 1. Preflight and clean coverage state

Run from repository root. Resolve `CPPTEST_HOME` from `CPPTEST_CT` first, then
verify C/C++test tools and Java prerequisites before starting a build.

Remove coverage state when maps, binaries, or logs may come from different
builds. Preserve ordinary build artifacts unless a clean rebuild is needed:

```bash
rm -rf .coverage "$BUILD_DIR/cpptest-coverage" "$BUILD_DIR/cpptest-runtime"
cmake -S . -B "$BUILD_DIR" -DCPPTEST_COVERAGE=ON
```

Do not mix an old `.clog` with newly generated coverage maps.

### 2. Build and verify instrumentation

```bash
cmake --build "$BUILD_DIR" --target "$TEST_TARGET" -j4 \
  > /tmp/coverage-build.log 2>&1
tail -60 /tmp/coverage-build.log
```

Verify `compile_commands.json` contains `cpptestcc` and the coverage workspace
contains maps for source files under test. If either check fails, stop and
reconfigure instead of running coverage.

### 3. Run focused tests first

```bash
${TEST_COMMAND} ${TEST_ARGS} \
  > /tmp/coverage-tests.log 2>&1
test_status=$?
tail -40 /tmp/coverage-tests.log
exit $test_status
```

Use the test framework's native command and focused filter. Run the full suite
separately; an unrelated failure must not hide coverage for passing focused
tests.

### 4. Compute coverage metrics

```bash
cmake --build "$BUILD_DIR" --target cpptestcov-compute > /tmp/coverage.log 2>&1
coverage_status=$?
tail -60 /tmp/coverage.log
exit $coverage_status
```

Run this stage only after focused tests pass. Never use
`-ignore-clog-integrity-error`; a map/log mismatch makes results unreliable.

### 5. Query and generate reports

```bash
cmake --build "$BUILD_DIR" --target cpptestcov-report > /tmp/coverage-report.log 2>&1
report_status=$?
tail -40 /tmp/coverage-report.log
exit $report_status
```

Query requested files with C/C++test MCP tools after computation. Claim a
coverage percentage only when the query uses fresh `.coverage` data and the
compute step completed without integrity errors.

### Focused file coverage

For a requested source file, use this sequence:

1. Build with `CPPTEST_COVERAGE=ON`.
2. Run the narrowest test target or filter covering the requested file.
3. Compute coverage.
4. Query the requested source file with `query_type: notcovered`.
5. Report 100% only when the not-covered result is empty.
6. Run the full suite separately and report unrelated failures separately.

If compute reports `cannot find FunctionIds` or another map/log integrity
error, delete `.coverage`, `<build-dir>/cpptest-coverage`, and
`<build-dir>/cpptest-runtime`, then repeat the clean workflow once. Stop after
the retry and report the exact error if it fails again.

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

**`make` reports `Error 2`?**
- Treat it as a wrapper status from a failed recipe, not the root cause
- Find the first C/C++test or compiler error in the captured log
- Do not repeat parent `make` failures in the final report

**`cannot find FunctionIds` or map/log mismatch?**
- Treat coverage as invalid
- Remove all coverage state and rebuild maps, runtime, and instrumented binary
- Never suppress the integrity error to obtain a percentage

**Full suite has unrelated failures?**
- Record focused test status and full-suite status independently
- Compute focused coverage when focused tests pass
- Name failing tests separately; do not call focused coverage a full-suite result

## Example workflow

```bash
export CPPTEST_HOME=${CPPTEST_CT:-/opt/parasoft/cpptest-ct}
cd $(git rev-parse --show-toplevel)
BUILD_DIR="${BUILD_DIR:-build}"
rm -rf .coverage "$BUILD_DIR/cpptest-coverage" "$BUILD_DIR/cpptest-runtime"
TEST_TARGET="${TEST_TARGET:-test-target}"
TEST_COMMAND="${TEST_COMMAND:-${BUILD_DIR}/test-runner}"
TEST_ARGS="${TEST_ARGS:-}"
cmake -S . -B "$BUILD_DIR" -DCPPTEST_COVERAGE=ON
cmake --build "$BUILD_DIR" --target "$TEST_TARGET" -j4 \
  > /tmp/coverage-build.log 2>&1
${TEST_COMMAND} ${TEST_FILTER:+--gtest_filter="$TEST_FILTER"} \
  > /tmp/coverage-tests.log 2>&1
test_status=$?
tail -40 /tmp/coverage-tests.log
if [[ $test_status -ne 0 ]]; then exit $test_status; fi
cmake --build "$BUILD_DIR" --target cpptestcov-compute \
  > /tmp/coverage.log 2>&1
coverage_status=$?
tail -60 /tmp/coverage.log
if [[ $coverage_status -ne 0 ]]; then exit $coverage_status; fi
cmake --build "$BUILD_DIR" --target cpptestcov-report \
  > /tmp/coverage-report.log 2>&1
tail -40 /tmp/coverage-report.log
```

## Output locations

- **Coverage database**: `.coverage/`
- **Coverage maps**: `<build-dir>/cpptest-coverage/`
- **Coverage database and reports**: `.coverage/`

## Coverage script options

Environment variables:

- `CLEAN_COVERAGE=1` - Delete stale coverage data before rebuild
- `AUTO_REBUILD_ON_MISMATCH=1` - Retry clean rebuild if compute fails
- `WRITE_DELTA_SUMMARY=1` - Write LC/MCDC by-file summary
- `REPORT_FILTER_PATHS=1` - Filter report to project source/include paths
- `OUTPUT_JSON=1` - Write JSON summary
- `SUMMARY_DIR=/path` - Customize summary output location

## Output and token discipline

- Capture build and report output in temporary log files.
- Show only exit status, failed test names, and the final 40-60 log lines.
- Do not enable verbose make output unless the normal build fails.
- Query only requested source files through MCP.
- Skip HTML, Markdown, suppression, and unrelated source reports unless asked.
- Never infer success from an existing report; verify fresh compute output first.

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

**Required:** When querying coverage data from `.coverage/` directory files, you **MUST** use `cpptest-ct` MCP tools. Do **not** parse coverage files manually with Python, bash, or grep.

The C/C++test-ct Model Context Protocol (MCP) server provides powerful tools for programmatic access to coverage data and tools. These tools can be accessed through connected development tools.

### Available MCP Tools

The following MCP tools are **required** for coverage data access:

#### Query Line Coverage

Use `mcp_cpptest-ct_query_line_coverage` to query coverage information for specific source files:

```
Tool: mcp_cpptest-ct_query_line_coverage
Parameters:
  - source_file: Absolute path to the source file
  - query_type: 'coverable', 'covered', 'notcovered', or 'suppressed'
  - coverage_data_dir: Directory with .cov files (typically '.coverage')

Example:
  source_file: /path/to/repo/src/Bank.cxx
  query_type: notcovered
  coverage_data_dir: /path/to/repo/.coverage
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

2. Query uncovered lines in the requested source file:
   mcp_cpptest-ct_query_line_coverage(
  source_file: "/path/to/repo/src/source.cxx",
     query_type: "notcovered",
     coverage_data_dir: "/path/to/repo/.coverage"
   )

3. Query covered lines in another requested source file:
   mcp_cpptest-ct_query_line_coverage(
  source_file: "/path/to/repo/src/other-source.cxx",
     query_type: "covered",
     coverage_data_dir: "/path/to/repo/.coverage"
   )

4. Search for documentation on improving coverage:
   mcp_cpptest-ct_search_documentation(
     user_query: "improve modified condition decision coverage MCDC"
   )

5. Learn how to suppress coverage for legacy code:
   mcp_cpptest-ct_how_to_suppress_coverage()
```

### Integrating MCP into your workflow

To use MCP tools when asking Copilot for coverage analysis:

- "Query coverage for source.cxx using MCP"
- "Find all untested lines in source.cxx using the coverage query tool"
- "Help me suppress coverage for deprecated code using MCP"
- "Search cpptest documentation for MCDC coverage best practices"

Copilot will use the appropriate MCP tools to provide accurate, detailed responses backed by your actual coverage data.

## References

- C/C++test coverage types: `cpptestcov -help` for detailed options
- CMake integration: See `cpptest-coverage.cmake` in project root
- Test suite: project-defined test directory or CTest configuration
- MCP Server: C/C++test-ct MCP protocol server documentation
