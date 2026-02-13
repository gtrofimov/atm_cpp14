#!/bin/bash
# C/C++test Coverage Analysis Helper Script
# This script automates the coverage analysis workflow

set -e

PROJECT_ROOT="/home/gtrofimov/parasoft/git/atm_cpp14"
CPPTEST_HOME="${CPPTEST_HOME:-/home/gtrofimov/parasoft/2025.2/ct/cpptest-ct}"
BUILD_DIR="${PROJECT_ROOT}/build"
CLEAN_COVERAGE="${CLEAN_COVERAGE:-0}"
AUTO_REBUILD_ON_MISMATCH="${AUTO_REBUILD_ON_MISMATCH:-0}"
WRITE_DELTA_SUMMARY="${WRITE_DELTA_SUMMARY:-0}"
REPORT_FILTER_PATHS="${REPORT_FILTER_PATHS:-0}"
REPORT_FILTER_REGEX="${REPORT_FILTER_REGEX:-/src/|/include/}"
OUTPUT_JSON="${OUTPUT_JSON:-0}"
JSON_OUTPUT_PATH="${JSON_OUTPUT_PATH:-$BUILD_DIR/coverage_summary.json}"
JSON_OUTPUT_STDOUT="${JSON_OUTPUT_STDOUT:-0}"
EXEC_ID="$(date +%s)-$$"
STATUS="success"
EXIT_CODE=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}C/C++test Coverage Analysis${NC}"
echo "================================"
echo "Project: $PROJECT_ROOT"
echo "CPPTEST_HOME: $CPPTEST_HOME"
echo "CLEAN_COVERAGE: $CLEAN_COVERAGE"
echo "AUTO_REBUILD_ON_MISMATCH: $AUTO_REBUILD_ON_MISMATCH"
echo "WRITE_DELTA_SUMMARY: $WRITE_DELTA_SUMMARY"
echo "REPORT_FILTER_PATHS: $REPORT_FILTER_PATHS"
echo "OUTPUT_JSON: $OUTPUT_JSON"
echo ""

clean_coverage_artifacts() {
    rm -rf "$PROJECT_ROOT/.coverage"
    rm -rf "$BUILD_DIR/cpptest-coverage"
    if [ -d "$BUILD_DIR" ]; then
        find "$BUILD_DIR" -name "*.clog" -type f -delete 2>/dev/null || true
    fi
}

build_with_instrumentation() {
    cd "$PROJECT_ROOT"
    rm -rf "$BUILD_DIR"
    mkdir "$BUILD_DIR"
    cd "$BUILD_DIR"
    CPPTEST_HOME="$CPPTEST_HOME" cmake -DCPPTEST_COVERAGE=ON .. > /dev/null
    make clean all -j4 > /dev/null
}

run_tests() {
    ./atm_gtest 2>&1 | tee test_results.txt
    return ${PIPESTATUS[0]}
}

compute_coverage() {
    if make cpptestcov-compute > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

generate_report() {
    make cpptestcov-report 2>&1 | tee coverage_report.txt
}

write_filtered_report() {
    if [ "$REPORT_FILTER_PATHS" -eq 1 ] && [ -f "$BUILD_DIR/coverage_report.txt" ]; then
        {
            grep "^> TOTAL" "$BUILD_DIR/coverage_report.txt" || true
            grep "^> " "$BUILD_DIR/coverage_report.txt" | grep -E "$REPORT_FILTER_REGEX" || true
        } > "$BUILD_DIR/coverage_report.filtered.txt"
    fi
}

write_delta_summary() {
    if [ "$WRITE_DELTA_SUMMARY" -ne 1 ] || [ ! -f "$BUILD_DIR/coverage_report.txt" ]; then
        return
    fi

    local html_dir=""
    if [ -f "$BUILD_DIR/report.html" ]; then
        html_dir="$BUILD_DIR"
    elif [ -f "$PROJECT_ROOT/reports/report.html" ]; then
        html_dir="$PROJECT_ROOT/reports"
    else
        html_dir="$BUILD_DIR"
    fi

    local summary_path="$html_dir/coverage_delta_summary.txt"
    awk -v filter="$REPORT_FILTER_PATHS" -v regex="$REPORT_FILTER_REGEX" '
        $1 == ">" && $0 ~ /LC=/ {
            file=$2
            lc=""
            mcdc=""
            for (i=1;i<=NF;i++) {
                if ($i ~ /^LC=/) lc=$i
                if ($i ~ /^MCDC=/) mcdc=$i
            }
            if (lc == "") lc="LC=NA"
            if (mcdc == "") mcdc="MCDC=NA"
            if (filter == 1 && file !~ regex) next
            printf "%s %s %s\n", file, lc, mcdc
        }
    ' "$BUILD_DIR/coverage_report.txt" > "$summary_path"
}

write_json_summary() {
        if [ "$OUTPUT_JSON" -ne 1 ]; then
                return
        fi

        set +e

        local coverage_pct="0"
        local coverage_report="$BUILD_DIR/coverage_report.txt"
        local filtered_report="$BUILD_DIR/coverage_report.filtered.txt"
        local delta_summary_build="$BUILD_DIR/coverage_delta_summary.txt"
        local delta_summary_reports="$PROJECT_ROOT/reports/coverage_delta_summary.txt"
        local delta_summary="$delta_summary_build"

        if [ -f "$delta_summary_reports" ]; then
                delta_summary="$delta_summary_reports"
        fi

        if [ -f "$coverage_report" ]; then
                coverage_pct=$(grep "^> TOTAL" "$coverage_report" | awk '{print $NF}' | sed 's/%//' || echo "0")
        fi

        local json_dir
        json_dir=$(dirname "$JSON_OUTPUT_PATH")
        mkdir -p "$json_dir"

        cat <<EOF > "$JSON_OUTPUT_PATH"
{
    "status": "$STATUS",
    "operation": "run-coverage-analysis",
    "timestamp": "$(date -Iseconds)",
    "execution_id": "$EXEC_ID",
    "inputs": {
        "project_root": "$PROJECT_ROOT"
    },
    "outputs": {
        "primary_artifact": "$coverage_report",
        "coverage_percentage": $coverage_pct,
        "files": {
            "coverage_database": "$PROJECT_ROOT/.coverage/",
            "test_results": "$BUILD_DIR/test_results.txt",
            "coverage_report": "$coverage_report",
            "coverage_report_filtered": "$filtered_report",
            "coverage_delta_summary": "$delta_summary"
        }
    },
    "audit_trail": {
        "user": "$USER",
        "git_branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
        "execution_id": "$EXEC_ID"
    }
}
EOF

        if [ "$JSON_OUTPUT_STDOUT" -eq 1 ]; then
                cat "$JSON_OUTPUT_PATH"
        fi
}

on_error() {
        EXIT_CODE=$?
        STATUS="error"
        write_json_summary
        exit $EXIT_CODE
}

trap on_error ERR

# Step 1: Clean and configure
echo -e "${YELLOW}[1/4] Cleaning and configuring with coverage instrumentation...${NC}"
if [ "$CLEAN_COVERAGE" -eq 1 ]; then
    echo -e "${YELLOW}Cleaning coverage artifacts...${NC}"
    clean_coverage_artifacts
fi
build_with_instrumentation
echo -e "${GREEN}✓ Build complete${NC}"
echo ""

# Step 2: Run tests
echo -e "${YELLOW}[2/4] Running unit tests with instrumentation...${NC}"
if run_tests; then
    TEST_RESULT=0
else
    TEST_RESULT=$?
fi
echo ""

# Step 3: Compute coverage
echo -e "${YELLOW}[3/4] Computing coverage metrics...${NC}"
if compute_coverage; then
    echo -e "${GREEN}✓ Coverage computed${NC}"
else
    echo -e "${RED}✗ Coverage computation failed${NC}"
    if [ "$AUTO_REBUILD_ON_MISMATCH" -eq 1 ]; then
        echo -e "${YELLOW}Retrying with clean coverage rebuild...${NC}"
        clean_coverage_artifacts
        build_with_instrumentation
        if run_tests; then
            TEST_RESULT=0
        else
            TEST_RESULT=$?
        fi
        if compute_coverage; then
            echo -e "${GREEN}✓ Coverage computed after clean rebuild${NC}"
        else
            echo -e "${RED}✗ Coverage computation failed after clean rebuild${NC}"
            exit 1
        fi
    else
        exit 1
    fi
fi
echo ""

# Step 4: Generate report
echo -e "${YELLOW}[4/4] Generating coverage report...${NC}"
generate_report
write_filtered_report
write_delta_summary
echo ""

# Summary
echo -e "${YELLOW}================================${NC}"
echo -e "${YELLOW}Coverage Analysis Complete${NC}"
echo -e "${YELLOW}================================${NC}"
echo ""
echo "Results:"
echo "  Coverage Database: $PROJECT_ROOT/.coverage/"
echo "  Test Results: $BUILD_DIR/test_results.txt"
echo "  Coverage Report: $BUILD_DIR/coverage_report.txt"
if [ -f "$BUILD_DIR/coverage_report.filtered.txt" ]; then
    echo "  Coverage Report (filtered): $BUILD_DIR/coverage_report.filtered.txt"
fi
if [ -f "$BUILD_DIR/coverage_delta_summary.txt" ]; then
    echo "  Coverage Delta Summary: $BUILD_DIR/coverage_delta_summary.txt"
elif [ -f "$PROJECT_ROOT/reports/coverage_delta_summary.txt" ]; then
    echo "  Coverage Delta Summary: $PROJECT_ROOT/reports/coverage_delta_summary.txt"
fi
echo ""

# Extract coverage summary
echo -e "${YELLOW}Coverage Summary:${NC}"
grep "^> TOTAL" coverage_report.txt || echo "Summary not found - check coverage_report.txt"

echo ""
if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}All tests passed${NC}"
else
    echo -e "${RED}Some tests failed (see test_results.txt)${NC}"
fi

write_json_summary

exit $EXIT_CODE
