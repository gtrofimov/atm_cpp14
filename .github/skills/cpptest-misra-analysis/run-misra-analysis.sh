#!/bin/bash
# C++test MISRA C++ 2023 Analysis Helper Script
# This script automates running MISRA C++ 2023 static analysis using compilation database

set -e

# Configuration
PROJECT_ROOT="${PROJECT_ROOT:-.}"
CPPTEST_STD="${CPPTEST_STD:-/home/gtrofimov/parasoft/2025.2/std/cpptest}"
COMPILER="${COMPILER:-gcc_13-64}"
OUTPUT_DIR="${OUTPUT_DIR:-reports}"
COMPILE_DB="${COMPILE_DB:-build/compile_commands.json}"
TEST_CONFIG="${TEST_CONFIG:-builtin://MISRA C++ 2023}"

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

ensure_compile_db() {
    local compile_db_path="$COMPILE_DB"
    if [[ "$COMPILE_DB" != /* ]]; then
        compile_db_path="$PROJECT_ROOT/$COMPILE_DB"
    fi
    local compile_db_dir
    compile_db_dir=$(dirname "$compile_db_path")

    if [ -f "$compile_db_path" ]; then
        print_success "Compilation database found at $COMPILE_DB"
        return
    fi

    print_step "Compilation database not found. Regenerating..."
    cd "$PROJECT_ROOT"
    cmake -B "$compile_db_dir" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    cmake --build "$compile_db_dir"

    if [ ! -f "$compile_db_path" ]; then
        print_error "Compilation database still missing after regeneration: $COMPILE_DB"
        exit 1
    fi

    print_success "Compilation database generated at $COMPILE_DB"
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

build_cpptestcli_command() {
    print_step "Building cpptestcli command..."
    
    echo "$CPPTEST_STD/cpptestcli -config '$TEST_CONFIG' -compiler $COMPILER -module . -exclude '**/googletest/**' -exclude '**/googlemock/**' -exclude '**/tests/**' -input $COMPILE_DB -report $OUTPUT_DIR/misra_cpp_2023"
}

run_analysis() {
    print_step "Running MISRA C++ 2023 analysis..."
    print_step "Using compilation database: $COMPILE_DB"
    print_step "Excluding: **/googletest/**, **/googlemock/**, **/tests/**"
    
    cd "$PROJECT_ROOT"
    
    # Execute cpptestcli with compilation database
    $CPPTEST_STD/cpptestcli \
        -config "$TEST_CONFIG" \
        -compiler "$COMPILER" \
        -module . \
        -exclude '**/googletest/**' \
        -exclude '**/googlemock/**' \
        -exclude '**/tests/**' \
        -input "$COMPILE_DB" \
        -report "$OUTPUT_DIR/misra_cpp_2023" 2>&1 | tee misra_analysis.log
    
    # cpptestcli may exit with non-zero on warnings, so we don't strict check here
    print_success "Analysis completed"
}

extract_summary() {
    print_step "Extracting analysis summary..."

    local report_dir="$OUTPUT_DIR/misra_cpp_2023"
    local report_xml="$report_dir/report.xml"
    if [ ! -f "$report_xml" ] && [ -f "$OUTPUT_DIR/report.xml" ]; then
        report_dir="$OUTPUT_DIR"
        report_xml="$OUTPUT_DIR/report.xml"
    fi

    if [ ! -f "$report_xml" ]; then
        print_error "Report not found: $report_xml"
        return
    fi

    # Extract violation count and stats from XML
    TOTAL_VIOLATIONS=$(grep -o 'violations="[0-9]*"' "$report_xml" 2>/dev/null | head -1 | grep -o '[0-9]*' || echo "0")
    
    echo ""
    echo -e "${YELLOW}Analysis Summary:${NC}"
    echo "  Total Violations: $TOTAL_VIOLATIONS"
    echo ""
    echo -e "${YELLOW}Generated Reports:${NC}"
    echo "  HTML:  $report_dir/report.html"
    echo "  XML:   $report_dir/report.xml"
    echo ""
    echo -e "${YELLOW}Top Violations by Rule:${NC}"
    grep -o "MISRACPP2023-[^:]*" "$report_xml" 2>/dev/null | sed 's/-.*$//' | sort | uniq -c | sort -rn | head -5 | awk '{print "  "$2": "$1" occurrence(s)"}' || echo "  No violations found"
    echo ""
    echo -e "${BLUE}Use GitHub Copilot to analyze violations:${NC}"
    echo "  Ask: 'Parse violations from $report_dir/report.xml and show critical issues'"

    write_summary_json "$report_xml" "$report_dir"
}

write_summary_json() {
    local report_xml="$1"
    local report_dir="$2"
    local summary_path="$report_dir/summary.json"

    local sev1=0
    local sev2=0
    local sev3=0
    local sev4=0
    local sev5=0

    local sev_counts
    sev_counts=$(grep -E '<(Std|Flow|Func|Dup|Exec)Viol' "$report_xml" 2>/dev/null | grep -o 'sev="[0-9]"' | awk -F'"' '{print $2}' | sort | uniq -c || true)

    while read -r count sev; do
        case "$sev" in
            1) sev1=$count ;;
            2) sev2=$count ;;
            3) sev3=$count ;;
            4) sev4=$count ;;
            5) sev5=$count ;;
        esac
    done <<< "$sev_counts"

    local top_rules
    top_rules=$(grep -E '<(Std|Flow|Func|Dup|Exec)Viol' "$report_xml" 2>/dev/null | grep -o 'rule="[^"]*"' | awk -F'"' '{print $2}' | sort | uniq -c | sort -rn | head -5)

    {
        echo "{" 
        echo "  \"report_xml\": \"$report_xml\"," 
        echo "  \"generated_at\": \"$(date -Iseconds)\"," 
        echo "  \"severity_counts\": {"
        echo "    \"1\": $sev1,"
        echo "    \"2\": $sev2,"
        echo "    \"3\": $sev3,"
        echo "    \"4\": $sev4,"
        echo "    \"5\": $sev5"
        echo "  },"
        echo "  \"top_rules\": ["

        local first=1
        if [ -n "$top_rules" ]; then
            while read -r count rule; do
                if [ -z "$rule" ]; then
                    continue
                fi
                if [ $first -eq 0 ]; then
                    echo ","
                fi
                first=0
                printf "    {\"rule\": \"%s\", \"count\": %s}" "$rule" "$count"
            done <<< "$top_rules"
            echo ""
        fi

        echo "  ]"
        echo "}"
    } > "$summary_path"
    print_success "Summary written: $summary_path"
}

main() {
    print_header "C++test MISRA C++ 2023 Static Analysis"
    echo ""
    echo "Configuration:"
    echo "  Project: $PROJECT_ROOT"
    echo "  C++test: $CPPTEST_STD"
    echo "  Compiler: $COMPILER"
    echo "  Test Config: $TEST_CONFIG"
    echo "  Compile DB: $COMPILE_DB"
    echo "  Output: $OUTPUT_DIR"
    echo ""
    
    check_prerequisites
    ensure_compile_db
    detect_compiler
    prepare_output
    run_analysis
    extract_summary
    
    print_header "Analysis Complete"
}

main "$@"
