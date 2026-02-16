# Common Patterns & Reference

This document captures shared patterns, tables, and troubleshooting guidance used across multiple agent skills.

## Coverage Metrics (C/C++test-ct)

The coverage tool provides these metrics:

| Metric | Name | What it measures |
|--------|------|------------------|
| LC | Line Coverage | % of executable lines run |
| SC | Statement Coverage | % of statements executed |
| BC | Branch Coverage | % of branch directions taken |
| DC | Decision Coverage | % of decisions evaluated |
| SCC | Structured Code Coverage | Coverage of block and branching structures |
| MCDC | Modified Condition/Decision Coverage | High-rigor metric for branch combinations |
| FC | Function Coverage | % of functions called |
| CC | Call Coverage | % of function calls made |

### Understanding Coverage Metrics

- **LC (Line Coverage)**: The most basic metric. A line is "covered" if it was executed during testing.
- **SC (Statement Coverage)**: Similar to LC but counts individual statements (useful in dense code).
- **BC (Branch Coverage)**: Tracks if both `true` and `false` paths were taken in conditional statements.
- **DC (Decision Coverage)**: Evaluates all possible outcomes of boolean decisions.
- **MCDC**: The most rigorous metric—requires all conditions independently affect the decision outcome.
- **FC (Function Coverage)**: Percentage of functions actually called by tests.

### Coverage Targets

- **Good coverage**: 80%+ line coverage for core functionality
- **Excellent coverage**: 90%+ line coverage + 80%+ MCDC coverage
- **Critical components**: Should aim for 100% LC and FC

## MISRA C++ 2023 Common Violations

| Violation | Issue | Fix |
|-----------|-------|-----|
| `MISRACPP2023-6_9_2-a` | Using `int` type without explicit size | Use sized types: `int32_t`, `uint16_t`, `uint8_t` |
| `MISRACPP2023-15_0_2-a` | Move constructor missing `noexcept` | Add `noexcept` specifier to move operations |
| `MISRACPP2023-21_6_2-a` | `new` operator usage | Use smart pointers (`std::unique_ptr`, `std::shared_ptr`) |
| `MISRACPP2023-8_2_2-b` | C-style casts | Use `static_cast`, `reinterpret_cast`, or `const_cast` |
| `MISRACPP2023-7_11_1-a` | Using `0` or `NULL` for null pointers | Use `nullptr` (C++11 and later) |
| `MISRACPP2023-2_7_1-a` | Unused function parameter | Remove unused parameter or add `[[maybe_unused]]` attribute |
| `MISRACPP2023-3_1_1-a` | Using directives at global scope | Avoid `using namespace` at global scope |

## General Troubleshooting

### License Errors

**Error**: `ERROR: Invalid license` or similar licensing message

**Solution**:
1. Verify the tool installation path is correct (e.g., `CPPTEST_HOME` or `CPPTEST_STD` env var)
2. Check that a valid license file exists in the installation directory
3. Ensure the license is not expired
4. Verify license permissions: `ls -la $CPPTEST_HOME` should be readable by current user

### Build Configuration Issues

**Error**: Instrumentation not applied or coverage/analysis shows 0% results

**Solution**:
1. Perform a **clean rebuild** from scratch:
   ```bash
   rm -rf build/
   mkdir build
   cd build
   cmake -DCPPTEST_COVERAGE=ON ..  # (for coverage)
   # OR for MISRA, ensure compile_commands.json is generated:
   cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
   ```
2. Verify the build includes the cpptest compiler wrapper in output
3. Check that source files are actually compiled with coverage/analysis enabled
4. Confirm `.coverage/` directory or `.cov` files are created

### Missing Data / No Coverage/Analysis Results

**Error**: Coverage or analysis shows 0% or no results collected

**Solution**:
1. Verify tests/analysis actually ran (check for PASSED/FAILED output or analysis log)
2. For coverage: Confirm the `.coverage/` workspace exists with index and `.cov` files
3. For analysis: Ensure the compilation database (`compile_commands.json`) was generated during build
4. Check file permissions: output directories should be writable
5. Review the full build log for any compiler wrapper errors

### Compiler or Dependency Not Found

**Error**: "Compiler not found", "missing include files", or "cannot find header"

**Solution**:
1. For coverage: Ensure C/C++test compiler wrapper (`cpptestcc`) is in `$PATH`
   ```bash
   export PATH="$CPPTEST_HOME/bin:$PATH"
   ```
2. For analysis: Detect available compilers:
   ```bash
   $CPPTEST_STD/cpptestcli -list-compilers
   $CPPTEST_STD/cpptestcli -detect-compiler gcc
   ```
3. Verify all required `-I` include paths are present in CMake configuration
4. Confirm system C++ compiler is installed (e.g., `g++`, `clang++`)

### Report Not Generated

**Error**: Output files (report.html, report.xml) missing or empty

**Solution**:
1. Verify write permissions on output directory:
   ```bash
   mkdir -p reports && chmod 755 reports
   ```
2. Check for earlier errors in the script output (license, missing compiler, etc.)
3. For analysis: Ensure the compilation database input was provided
4. Review the analysis/coverage log for failures (e.g., `misra_analysis.log`, `test_results.txt`)

## Environment Variables Reference

### Coverage Analysis

- `CPPTEST_HOME`: Path to C/C++test installation
- `CLEAN_COVERAGE=1`: Remove stale coverage data before rebuild
- `AUTO_REBUILD_ON_MISMATCH=1`: Retry clean rebuild if compute fails
- `WRITE_DELTA_SUMMARY=1`: Generate LC/MCDC by-file delta summary
- `REPORT_FILTER_PATHS=1`: Filter report to `src/` and `include/` only
- `REPORT_FILTER_REGEX="/src/|/include/"`: Custom filter pattern
- `OUTPUT_JSON=1`: Write structured JSON summary
- `JSON_OUTPUT_PATH`: Custom path for JSON output

### MISRA Analysis

- `CPPTEST_STD`: Path to C++test Standard installation
- `PROJECT_ROOT`: Project root directory (default: current directory)
- `COMPILER`: Compiler ID (e.g., `gcc_13-64`)
- `OUTPUT_DIR`: Output directory for reports (default: `reports`)
- `COMPILE_DB`: Path to compilation database (default: `build/compile_commands.json`)
- `TEST_CONFIG`: Test configuration to use (default: `builtin://MISRA C++ 2023`)
- `SUMMARY_DIR`: Output directory for summary files
- `SUMMARY_STDOUT=0`: Suppress summary output to console
