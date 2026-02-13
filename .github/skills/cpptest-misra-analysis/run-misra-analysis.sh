#!/bin/bash
# C++test MISRA C++ 2023 Analysis Helper Script
# This script automates running MISRA C++ 2023 static analysis

set -e

# Configuration
PROJECT_ROOT="${PROJECT_ROOT:-.}"
CPPTEST_STD="${CPPTEST_STD:-/home/gtrofimov/parasoft/2025.2/std/cpptest}"
COMPILER="${COMPILER:-gcc_13-64}"
OUTPUT_DIR="${OUTPUT_DIR:-reports}"
INCLUDE_DIRS="${INCLUDE_DIRS:-include}"
SOURCE_FILES="${SOURCE_FILES:-src/*.cxx}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_step() {
    echo -e "${YELLOW}[*] $1${NC}"
}

print_success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

print_error() {
    echo -e "${RED}[✗] $1${NC}"
}

check_prerequisites() {
    print_step "Checking prerequisites..."
    
    if [ ! -d "$CPPTEST_STD" ]; then
        print_error "CPPTEST_STD directory not found: $CPPTEST_STD"
        exit 1
    fi
    
    if [ ! -f "$CPPTEST_STD/cpptestcli" ]; then
        print_error "cpptestcli not found in $CPPTEST_STD"
        exit 1
    fi
    
    print_success "C++test Standard installation found"
}

detect_compiler() {
    print_step "Detecting C++ compiler..."
    
    DETECTED=$($CPPTEST_STD/cpptestcli -detect-compiler gcc 2>&1 | grep "gcc_" | head -1 | awk '{print $(NF)}' || echo "")
    
    if [ -z "$DETECTED" ]; then
        print_error "Could not detect compiler, using default: $COMPILER"
    else
        COMPILER=$DETECTED
        print_success "Detected compiler: $COMPILER"
    fi
}

prepare_output() {
    print_step "Preparing output directory..."
    mkdir -p "$OUTPUT_DIR"
    print_success "Output directory ready: $OUTPUT_DIR"
}

build_compiler_command() {
    print_step "Building compiler command..."
    
    local cmd="gcc"
    
    # Add include directories
    for inc in $INCLUDE_DIRS; do
        if [ -d "$inc" ]; then
            cmd="$cmd -I$inc"
        fi
    done
    
    # Add source files
    for src in $SOURCE_FILES; do
        if [ -f "$src" ]; then
            cmd="$cmd $src"
        fi
    done
    
    echo "$cmd"
}

run_analysis() {
    print_step "Running MISRA C++ 2023 analysis..."
    
    local compiler_cmd=$(build_compiler_command)
    
    cd "$PROJECT_ROOT"
    
    $CPPTEST_STD/cpptestcli \
        -config "builtin://MISRA C++ 2023" \
        -compiler "$COMPILER" \
        -- $compiler_cmd \
        -report "$OUTPUT_DIR/misra_cpp_2023" 2>&1 | tee misra_analysis.log
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        print_success "Analysis completed successfully"
    else
        print_error "Analysis failed"
        exit 1
    fi
}

extract_summary() {
    print_step "Extracting analysis summary..."
    
    # Extract total violations
    TOTAL_VIOLATIONS=$(grep -oE "Total violations: [0-9]+" "$OUTPUT_DIR"/report.xml 2>/dev/null || echo "0")
    
    echo ""
    echo -e "${YELLOW}Analysis Summary:${NC}"
    echo "  $TOTAL_VIOLATIONS"
    echo "  HTML Report: $OUTPUT_DIR/report.html"
    echo "  XML Report: $OUTPUT_DIR/report.xml"
    echo ""
}

main() {
    print_header "C++test MISRA C++ 2023 Static Analysis"
    echo ""
    echo "Configuration:"
    echo "  Project: $PROJECT_ROOT"
    echo "  C++test: $CPPTEST_STD"
    echo "  Compiler: $COMPILER"
    echo "  Output: $OUTPUT_DIR"
    echo "  Includes: $INCLUDE_DIRS"
    echo "  Sources: $SOURCE_FILES"
    echo ""
    
    check_prerequisites
    detect_compiler
    prepare_output
    run_analysis
    extract_summary
    
    print_header "Analysis Complete"
}

main "$@"
