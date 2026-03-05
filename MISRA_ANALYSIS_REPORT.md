# MISRA C++ 2023 Static Analysis Report
**ATM C++14 Project**  
**Date:** February 16, 2026  
**Analysis Tool:** Parasoft C/C++test Standard 2025.2.0  
**Configuration:** `builtin://MISRA C++ 2023`

---

## Executive Summary

A comprehensive MISRA C++ 2023 static analysis was performed on the ATM C++14 project codebase. The analysis identified **56 active violations** across 8 source files, with 3 additional violations that have been suppressed.

### Key Statistics
- **Total Violations:** 56 (3 suppressed)
- **Urgent Violations:** 50 (89% of total)
- **Files Analyzed:** 8 (391 lines of code)
- **Severity Distribution:**
  - 🟠 High (Severity 2): 26 violations (46%)
  - 🔵 Low (Severity 4): 30 violations (54%)

---

## Violations by Severity

| Severity | Count | Percentage | Description |
|----------|-------|------------|-------------|
| 🟠 High (2) | 26 | 46% | Issues requiring prompt attention |
| 🔵 Low (4) | 30 | 54% | Advisory issues for code quality |

---

## Top 10 MISRA Rules Violated

### 1. MISRACPP2023-6_0_3-a (12 violations)
**Rule:** The global namespace shall only contain main() and namespace declarations

**Impact:** Using directives and declarations in the global namespace pollute the global scope and can lead to naming conflicts.

**Locations:**
- ATM.cxx:5, Account.cxx:5, Bank.cxx:5
- BaseDisplay.cxx:5, BaseDisplay.hxx:5
- Account.hxx:6, ATM.hxx:5, Bank.hxx:5
- And 4 more...

**Recommendation:** Move `using` directives inside function or class scope, or use fully qualified names.

---

### 2. MISRACPP2023-6_9_2-a (10 violations)
**Rule:** The names of the standard signed integer types and standard unsigned integer types should not be used

**Impact:** Use of `int` without explicit size can lead to portability issues across platforms.

**Locations:**
- Account.cxx:42, 44
- Account.hxx:43, 45, 63, 65
- ATM.cxx:13, 30
- ATM.hxx:19, 27

**Recommendation:** Use fixed-width integer types from `<cstdint>` (e.g., `std::int32_t`, `std::int64_t`).

---

### 3. MISRACPP2023-15_0_1-a (5 violations)
**Rule:** Special member functions shall be provided appropriately

**Impact:** Classes with resource management need proper copy/move semantics to avoid undefined behavior.

**Locations:**
- BaseDisplay.hxx:8 (missing copy constructor)
- BaseDisplay.hxx:8 (missing copy assignment operator)
- BaseDisplay.hxx:8 (missing move constructor)
- BaseDisplay.hxx:8 (missing move assignment operator)
- Bank.hxx:8 (missing copy constructor)

**Recommendation:** Implement Rule of Five for classes managing resources, or explicitly delete copy/move operations.

---

### 4. MISRACPP2023-8_2_8-b (3 violations)
**Rule:** A conversion should not be performed from a pointer type to an arithmetic type

**Impact:** Implicit pointer-to-bool conversions can mask null pointer issues and reduce code clarity.

**Locations:**
- ATM.cxx:15 (`Account *` to `bool`)
- ATM.cxx:23 (`Account *` to `bool`)
- BaseDisplay.cxx:9 (`const char *` to `bool`)

**Recommendation:** Use explicit null pointer checks: `if (ptr != nullptr)` instead of `if (ptr)`.

---

### 5. MISRACPP2023-18_4_1-a (2 violations)
**Rule:** Exception-unfriendly functions shall be noexcept

**Impact:** Move constructors without `noexcept` prevent standard containers from using move semantics efficiently.

**Locations:**
- Account.cxx:8 (move constructor)
- Account.hxx:21 (move constructor declaration)

**Recommendation:** Add `noexcept` specifier to move constructor: `Account(Account&&) noexcept`.

---

### 6. MISRACPP2023-15_0_2-a (2 violations)
**Rule:** User-declared, non-deleted copy and move member functions should have appropriate signatures

**Impact:** Related to rule 18_4_1-a above - move operations should be noexcept for optimal performance.

**Locations:**
- Account.cxx:8, Account.hxx:21

**Recommendation:** Same as above - add `noexcept` to move constructor.

---

### 7. MISRACPP2023-0_1_2-a (2 violations)
**Rule:** The value returned by a function having a non-void return type shall always be used

**Impact:** Ignoring return values can miss important information or errors.

**Locations:**
- Account.cxx:58 (`for_each` return value)
- Account.hxx:60 (`for_each` return value)

**Recommendation:** Either use the return value or cast to `(void)` to explicitly indicate it's intentionally ignored.

---

### 8. MISRACPP2023-15_1_4-a (2 violations)
**Rule:** All direct, non-static data members of a non-aggregate class should be initialized at the top of a constructor body

**Impact:** Uninitialized member variables can lead to undefined behavior.

**Locations:**
- ATM.cxx:7 (myBank, myCurrentAccount, myDisplay not in initializer list)
- Bank.cxx:4 (myCurrentAccountNumber not in initializer list)

**Recommendation:** Use member initializer lists in constructors.

---

### 9. MISRACPP2023-9_4_2-a (2 violations)
**Rule:** The first or last label of a switch statement should be the 'default' label unless all enumeration values are tested

**Impact:** Missing default case can lead to unhandled values and unexpected behavior.

**Locations:**
- ATM.cxx:24
- BaseDisplay.cxx:25

**Recommendation:** Add `default:` case to all switch statements.

---

### 10. MISRACPP2023-15_0_1-b (2 violations)
**Rule:** Destructor shall have a non-empty body

**Impact:** Empty destructors marked with "// TODO: NYI" suggest incomplete resource cleanup.

**Locations:**
- Bank.cxx:9
- BaseDisplay.hxx:16

**Recommendation:** Implement proper cleanup or use `= default` if no cleanup is needed.

---

## Violations by File

| File | Violations | Percentage |
|------|-----------|------------|
| Bank.cxx | 11 | 20% |
| ATM.cxx | 9 | 16% |
| Account.hxx | 8 | 14% |
| Bank.hxx | 7 | 13% |
| ATM.hxx | 6 | 11% |
| Account.cxx | 5 | 9% |
| BaseDisplay.cxx | 5 | 9% |
| BaseDisplay.hxx | 5 | 9% |

---

## High Priority Issues

The following high-severity (Severity 2) urgent issues should be addressed first:

### 1. Move Constructor Safety (MISRACPP2023-18_4_1-a)
- **Files:** Account.cxx:8, Account.hxx:21
- **Fix:** Add `noexcept` specifier to move constructor

### 2. Unused Return Values (MISRACPP2023-0_1_2-a)
- **Files:** Account.cxx:58, Account.hxx:60
- **Fix:** Use or explicitly ignore the return value from `for_each`

### 3. Pointer-to-Bool Conversions (MISRACPP2023-8_2_8-b)
- **Files:** ATM.cxx:15, ATM.cxx:23, BaseDisplay.cxx:9
- **Fix:** Use explicit `!= nullptr` checks

### 4. Missing Default Cases (MISRACPP2023-9_4_2-a)
- **Files:** ATM.cxx:24, BaseDisplay.cxx:25
- **Fix:** Add `default:` cases to switch statements

### 5. Fall-through Switch Cases (MISRACPP2023-9_4_2-b)
- **File:** ATM.cxx:32
- **Fix:** Add explicit `break` or `[[fallthrough]]` attribute

### 6. Empty Destructors (MISRACPP2023-15_0_1-b)
- **Files:** Bank.cxx:9, BaseDisplay.hxx:16
- **Fix:** Implement cleanup or use `= default`

---

## Suppressed Violations

The following 3 violations have been suppressed (marked with `supp="true"`):

1. **MISRACPP2023-7_0_2-a** at Account.cxx:19
   - Do not convert type 'double' to type 'bool'

2. **MISRACPP2023-8_2_7-c** at ATM.cxx:15
   - Pointer type to arithmetic type conversion

3. **MISRACPP2023-8_2_7-c** at ATM.cxx:23
   - Pointer type to arithmetic type conversion

---

## Recommendations

### Immediate Actions (High Priority)
1. ✅ Add `noexcept` to move constructors
2. ✅ Fix unused return values from `for_each` calls
3. ✅ Replace implicit pointer-to-bool with explicit null checks
4. ✅ Add default cases to all switch statements
5. ✅ Fix or document empty destructors

### Short-term Improvements (Medium Priority)
6. Replace `int` with fixed-width types (`std::int32_t`)
7. Move `using` directives out of global namespace
8. Implement missing special member functions for resource-managing classes
9. Initialize all member variables in constructor initializer lists

### Long-term Enhancements (Low Priority)
10. Review and address all remaining Advisory-level violations
11. Consider enabling additional MISRA rules for stricter compliance
12. Integrate MISRA checking into CI/CD pipeline

---

## Testing and Validation

After addressing violations:
1. Re-run MISRA analysis to verify fixes
2. Run full test suite: `ctest` or `./build/atm_gtest`
3. Verify no new violations introduced
4. Update suppression file if needed

---

## Resources

- **Report Files:**
  - HTML: `reports/misra_cpp_2023_baseline/report.html`
  - XML: `reports/misra_cpp_2023_baseline/report.xml`
  - SARIF: `reports/misra_cpp_2023_baseline/report.sarif`

- **MISRA C++ 2023 Guidelines:** https://www.misra.org.uk/
- **C++test Documentation:** https://docs.parasoft.com/display/CPP

---

## Conclusion

The ATM C++14 project has **56 active MISRA C++ 2023 violations** that should be addressed to improve code quality, safety, and maintainability. Most violations (89%) are marked as urgent, indicating they represent real quality or safety concerns.

The most common issues are:
1. Global namespace pollution (12 violations)
2. Use of platform-dependent `int` type (10 violations)
3. Missing special member functions (5 violations)

Addressing the high-priority issues first will significantly improve the codebase's MISRA compliance and overall quality.

---

**Analysis performed by:** Parasoft C/C++test Standard 2025.2.0  
**Report generated:** 2026-02-16
