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

## Quick Start (Phase 1 - Recommended)

Use the automated helper for structured output:

```bash
./.github/skills/cpptest-coverage-analysis/run-coverage-phase1.sh /path/to/project
```

**Output includes:**
- ✅ Structured JSON with coverage percentage
- ✅ Execution ID for tracking
- ✅ Paths to all generated reports
- ✅ Audit trail with user and git branch

This outputs Phase 1 metadata while running the full analysis. Perfect for CI/CD pipelines and automation.

## Prerequisites

Before running coverage analysis:

1. Ensure CPPTEST_HOME environment variable is set:
   ```bash
   export CPPTEST_HOME=/home/gtrofimov/parasoft/2025.2/ct/cpptest-ct
   ```

2. Verify a valid C/C++test license is available

3. The project must be a CMake-based C++ project with GoogleTest integration

## Step-by-step process

### 1. Clean rebuild with coverage instrumentation

Clean the previous build and reconfigure CMake with coverage enabled:

```bash
cd /home/gtrofimov/parasoft/git/atm_cpp14
rm -rf build
mkdir build
cd build
CPPTEST_HOME=/home/gtrofimov/parasoft/2025.2/ct/cpptest-ct cmake -DCPPTEST_COVERAGE=ON ..
make clean all -j4
```

This will:
- Configure CMake with coverage instrumentation enabled
- Compile all source files with cpptestcc (C/C++test compiler wrapper)
- Generate coverage map files in `cpptest-coverage/` directory
- Instrument the test executable with coverage runtime

### 2. Run instrumented tests

Execute the test binary to collect coverage data:

```bash
cd /home/gtrofimov/parasoft/git/atm_cpp14/build
./atm_gtest
```

This will:
- Run all 13 unit tests
- Generate `.clog` (coverage log) files
- Generate `.cov` files in `.coverage/` directory with execution traces
- Report test pass/fail status

### 3. Compute coverage metrics

Process the raw coverage data into metrics:

```bash
cd /home/gtrofimov/parasoft/git/atm_cpp14/build
make cpptestcov-compute
```

This step:
- Reads coverage map files and logs
- Computes coverage for multiple metrics (LC, SC, BC, DC, MCDC, FC, CC)
- Creates coverage database indexed for fast queries
- Generates `.cov` index files

### 4. Generate coverage report

Create a human-readable coverage report:

```bash
cd /home/gtrofimov/parasoft/git/atm_cpp14/build
make cpptestcov-report
```

This will:
- Generate console output with coverage metrics by file and function
- Produce metrics/report XML files in the build directory
- Create formatted coverage statistics

## Understanding Coverage Metrics

The tool provides these coverage metrics:

- **LC (Line Coverage)**: Percentage of executable lines executed
- **SC (Statement Coverage)**: Percentage of statements executed
- **BC (Branch Coverage)**: Percentage of branch directions taken
- **DC (Decision Coverage)**: Percentage of boolean decisions evaluated
- **SCC (Structured Code Coverage)**: Coverage of block and branching structures
- **MCDC (Modified Condition/Decision Coverage)**: High-rigor coverage metric
- **FC (Function Coverage)**: Percentage of functions executed
- **CC (Call Coverage)**: Percentage of function calls made

## Interpreting Results

### File-level coverage

The report shows coverage for each source file:

```
> atm_cpp14/src/Bank.cxx           LC=100% 12/12  SC=100% 12/12  ...
> atm_cpp14/src/Account.cxx        LC=38% 8/21    SC=38% 8/21    ...
> atm_cpp14/src/ATM.cxx            LC=0% 0/22     SC=0% 0/25     ...
```

### Function-level coverage

Coverage is broken down by function:

```
Bank::addAccount()                 LC=100% 4/4    SC=100% 4/4    FC=100% 1/1
Account::deposit(double)           LC=100% 3/3    SC=100% 3/3    FC=100% 1/1
ATM::exampleFunction()             LC=0% 0/1      SC=0% 0/1      FC=0% 0/1
```

### Coverage gaps

Low coverage areas indicate:
- Functions not exercised by tests
- Decision branches not explored
- Conditions not all combinations tested

## Common coverage targets

- **Good coverage**: 80%+ line coverage for core functionality
- **Excellent coverage**: 90%+ line coverage + 80%+ MCDC coverage
- **Critical components**: Should aim for 100% LC and FC
- **Test code**: Not instrumented (filtered out automatically)

## Troubleshooting

### License errors

If you see "Invalid license" error:
```
ERROR: Invalid license
```

Solution: Verify CPPTEST_HOME points to correct installation and license is valid

### Coverage map errors

If you see "cannot find FunctionIds" errors:

Solution: Perform a clean rebuild with `-DCPPTEST_COVERAGE=ON` enabled from the start

### No coverage data collected

If coverage shows 0% after running tests:

1. Verify instrumentation occurred during build (look for cpptestcc in build output)
2. Ensure tests actually ran (check for PASSED/FAILED test output)
3. Confirm coverage workspace exists: `cpptest-coverage/${PROJECT_NAME}/`

## Example workflow

```bash
# 1. Setup
export CPPTEST_HOME=/home/gtrofimov/parasoft/2025.2/ct/cpptest-ct

# 2. Clean build with instrumentation
cd /home/gtrofimov/parasoft/git/atm_cpp14
rm -rf build && mkdir build && cd build
cmake -DCPPTEST_COVERAGE=ON ..
make -j4

# 3. Run tests
./atm_gtest

# 4. Generate reports
make cpptestcov-compute cpptestcov-report

# 5. Review output - look for coverage summary at end of report
```

## Output locations

- **Coverage database**: `/home/gtrofimov/parasoft/git/atm_cpp14/.coverage/`
- **Coverage maps**: `/home/gtrofimov/parasoft/git/atm_cpp14/build/cpptest-coverage/`
- **Console report**: Displayed when running `make cpptestcov-report`
- **XML metrics**: Generated in build directory

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
