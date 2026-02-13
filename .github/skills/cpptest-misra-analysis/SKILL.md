---
name: cpptest-misra-analysis
description: Run MISRA C++ 2023 static analysis on C++ code using C++test Standard. Use this when performing code quality checks, identifying MISRA compliance violations, and generating static analysis reports.
license: MIT
---

# C++test MISRA C++ 2023 Static Analysis

This skill provides automated MISRA C++ 2023 static analysis using Parasoft C++test Standard. MISRA C++ is a set of guidelines for safely writing C++ code in safety-critical embedded systems and high-integrity applications.

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

### Step 1: Prepare your source files

Identify all C++ source files to be analyzed:

```bash
# List all C++ source files
find . -name "*.cpp" -o -name "*.cxx" -o -name "*.cc" -o -name "*.c++"

# Identify include directories
find . -type d -name "include" -o -name "inc"
```

### Step 2: Detect compiler configuration

Before running analysis, detect your compiler version:

```bash
# For GCC
$CPPTEST_STD/cpptestcli -detect-compiler gcc

# For Clang
$CPPTEST_STD/cpptestcli -detect-compiler clang

# Output will show the compiler ID (e.g., gcc_13-64, clang_17_0-x86_64)
```

### Step 3: Create output directories

```bash
# Create directory for reports
mkdir -p reports
```

### Step 4: Run MISRA C++ 2023 analysis

#### Option A: Direct file compilation command

Specify source files and compiler flags directly:

```bash
cd /path/to/project

# Single file analysis
$CPPTEST_STD/cpptestcli \
  -config "builtin://MISRA C++ 2023" \
  -compiler gcc_13-64 \
  -- gcc -Iinclude src/MyFile.cpp \
  -report reports/misra_cpp_2023
```

#### Option B: Multiple source files

```bash
$CPPTEST_STD/cpptestcli \
  -config "builtin://MISRA C++ 2023" \
  -compiler gcc_13-64 \
  -- gcc -Iinclude src/Account.cxx src/ATM.cxx src/Bank.cxx \
  -report reports/misra_cpp_2023
```

#### Option C: Build tracing

Capture analysis from your actual build command:

```bash
$CPPTEST_STD/cpptestcli \
  -config "builtin://MISRA C++ 2023" \
  -compiler gcc_13-64 \
  -trace "make clean all" \
  -report reports/misra_cpp_2023
```

### Step 5: Review analysis results

Reports are generated in multiple formats:

```bash
# View HTML report (requires browser)
open reports/report.html  # macOS
xdg-open reports/report.html  # Linux

# View XML report (for parsing/CI integration)
cat reports/report.xml

# Check command output for summary
tail -20 misra_analysis.log
```

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

### Example 1: Analyze C++ project with single header include path

```bash
cd /home/user/my_project

$CPPTEST_STD/cpptestcli \
  -config "builtin://MISRA C++ 2023" \
  -compiler gcc_13-64 \
  -- gcc -Iinclude src/main.cpp src/utils.cpp \
  -report reports/misra_cpp_2023
```

### Example 2: Complete analysis with Clang compiler

```bash
$CPPTEST_STD/cpptestcli \
  -config "builtin://MISRA C++ 2023" \
  -compiler clang_17_0-x86_64 \
  -- clang++ -std=c++14 -Iinclude -Ithird_party/include \
    src/Account.cxx src/Bank.cxx \
  -report reports/misra_analysis
```

### Example 3: Generate both HTML and XML reports

```bash
# Default behavior generates both formats
$CPPTEST_STD/cpptestcli \
  -config "builtin://MISRA C++ 2023" \
  -compiler gcc_13-64 \
  -- gcc -Iinclude src/*.cxx \
  -report reports/misra_cpp_2023

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
