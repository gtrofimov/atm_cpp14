#!/bin/bash
# C/C++test Coverage Analysis Helper Script
# This script automates the coverage analysis workflow

set -e

PROJECT_ROOT="/home/gtrofimov/parasoft/git/atm_cpp14"
CPPTEST_HOME="${CPPTEST_HOME:-/home/gtrofimov/parasoft/2025.2/ct/cpptest-ct}"
BUILD_DIR="${PROJECT_ROOT}/build"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}C/C++test Coverage Analysis${NC}"
echo "================================"
echo "Project: $PROJECT_ROOT"
echo "CPPTEST_HOME: $CPPTEST_HOME"
echo ""

# Step 1: Clean and configure
echo -e "${YELLOW}[1/4] Cleaning and configuring with coverage instrumentation...${NC}"
cd "$PROJECT_ROOT"
rm -rf "$BUILD_DIR"
mkdir "$BUILD_DIR"
cd "$BUILD_DIR"
CPPTEST_HOME="$CPPTEST_HOME" cmake -DCPPTEST_COVERAGE=ON .. > /dev/null
make clean all -j4 > /dev/null
echo -e "${GREEN}✓ Build complete${NC}"
echo ""

# Step 2: Run tests
echo -e "${YELLOW}[2/4] Running unit tests with instrumentation...${NC}"
./atm_gtest 2>&1 | tee test_results.txt
TEST_RESULT=$?
echo ""

# Step 3: Compute coverage
echo -e "${YELLOW}[3/4] Computing coverage metrics...${NC}"
if make cpptestcov-compute > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Coverage computed${NC}"
else
    echo -e "${RED}✗ Coverage computation failed${NC}"
    exit 1
fi
echo ""

# Step 4: Generate report
echo -e "${YELLOW}[4/4] Generating coverage report...${NC}"
make cpptestcov-report 2>&1 | tee coverage_report.txt
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
