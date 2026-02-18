#!/bin/bash
# C++test MISRA C++ 2023 Analysis Helper Script
# This script automates running MISRA C++ 2023 static analysis using compilation database
# 
# IMPORTANT: This script converts all file paths to absolute paths to ensure
# C++test's git scope control properly matches the repository. Relative paths
# (like ".") cause C++test's scope control to fail silently with 0 files in scope.

set -e

# Configuration
PROJECT_ROOT="${PROJECT_ROOT:-.}"
CPPTEST_STD="${CPPTEST_STD:-/home/gtrofimov/parasoft/2025.2/std/cpptest}"
COMPILER="${COMPILER:-gcc_13-64}"
OUTPUT_DIR="${OUTPUT_DIR:-reports}"
COMPILE_DB="${COMPILE_DB:-build/compile_commands.json}"
TEST_CONFIG="${TEST_CONFIG:-builtin://MISRA C++ 2023}"
SUMMARY_DIR="${SUMMARY_DIR:-$PROJECT_ROOT/reports/summary}"
SUMMARY_STDOUT="${SUMMARY_STDOUT:-1}"
SCONTROL_MODE="${SCONTROL_MODE:-}"
SCONTROL_REF_BRANCH="${SCONTROL_REF_BRANCH:-origin/main}"
SCONTROL_GIT_WORKSPACE="${SCONTROL_GIT_WORKSPACE:-$PROJECT_ROOT}"
SCONTROL_GIT_URL="${SCONTROL_GIT_URL:-}"
SCONTROL_GIT_EXEC="${SCONTROL_GIT_EXEC:-git}"
NEW_VIOLATIONS_ONLY="${NEW_VIOLATIONS_ONLY:-0}"
BASELINE_REPORT="${BASELINE_REPORT:-}"

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

print_usage() {
    cat <<EOF
Usage: $0 [options]

Scope Options (default: full scan):
  --branch, --modified        Analyze only files modified vs ref branch
  --local                     Analyze only locally modified files (working tree)

Report Options (default: all violations):
  --new-violations            Show only new violations (exclude baseline findings)
  --ref-branch <name>         Reference branch for scope & baseline (default: origin/main)

Git Configuration:
  --git-workspace <path>       Git workspace path (default: PROJECT_ROOT)
  --git-url <url>              Git remote URL (auto-detected if not provided)
  --git-exec <path>            Git executable path (default: git)

Baseline Report:
  --baseline <path>            Path to baseline report (auto-extracted from ref branch if omitted)

Other:
  -h, --help                   Show this help

Examples:
  # Full scan
  $0

  # Modified files only
  $0 --branch

  # New violations only (full scan)
  $0 --new-violations

  # Modified files with only new violations
  $0 --branch --new-violations

  # Against different branch
  $0 --branch --ref-branch origin/develop --new-violations
EOF
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --modified|--branch)
                SCONTROL_MODE=branch
                ;;
            --local)
                SCONTROL_MODE=local
                ;;
            --new-violations)
                NEW_VIOLATIONS_ONLY=1
                ;;
            --ref-branch)
                SCONTROL_REF_BRANCH="$2"
                shift
                ;;
            --baseline)
                BASELINE_REPORT="$2"
                shift
                ;;
            --git-workspace)
                SCONTROL_GIT_WORKSPACE="$2"
                shift
                ;;
            --git-url)
                SCONTROL_GIT_URL="$2"
                shift
                ;;
            --git-exec)
                SCONTROL_GIT_EXEC="$2"
                shift
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
        shift
    done
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
    
    # CRITICAL: Convert PROJECT_ROOT and git workspace to absolute paths
    # C++test's scope.scontrol property requires absolute paths to properly match
    # the git repository. Relative paths (like ".") cause git scope control to fail
    # silently with "0 files checked", filtering out all modified files.
    # See: https://docs.parasoft.com/display/CPP/Scope+Control
    PROJECT_ROOT=$(cd "$PROJECT_ROOT" && pwd)
    SCONTROL_GIT_WORKSPACE=$(cd "$SCONTROL_GIT_WORKSPACE" && pwd)
    
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

ensure_baseline_report() {
    if [ "$NEW_VIOLATIONS_ONLY" -ne 1 ]; then
        return
    fi

    # If baseline path is provided, verify it exists
    if [ -n "$BASELINE_REPORT" ]; then
        if [ ! -f "$BASELINE_REPORT" ]; then
            print_error "Baseline report not found: $BASELINE_REPORT"
            exit 1
        fi
        print_success "Using baseline report: $BASELINE_REPORT"
        return
    fi

    # Auto-generate baseline from ref branch
    local baseline_dir="$PROJECT_ROOT/reports/baseline_${SCONTROL_REF_BRANCH##*/}"
    local baseline_file="$baseline_dir/report.xml"

    # Check if auto baseline already exists
    if [ -f "$baseline_file" ]; then
        print_success "Using existing baseline: $baseline_file"
        BASELINE_REPORT="$baseline_file"
        return
    fi

    print_step "Extracting baseline report from $SCONTROL_REF_BRANCH..."
    
    mkdir -p "$baseline_dir"
    
    # Try to extract from standard baseline path first
    local baseline_path="reports/misra_cpp_2023_baseline/report.xml"
    if git show "$SCONTROL_REF_BRANCH:$baseline_path" > "$baseline_file" 2>/dev/null; then
        print_success "Baseline extracted from $SCONTROL_REF_BRANCH:$baseline_path"
        BASELINE_REPORT="$baseline_file"
        return
    fi

    # Fallback: try alternate baseline paths
    for alt_path in "reports/baseline/report.xml" "reports/misra_report.xml"; do
        if git show "$SCONTROL_REF_BRANCH:$alt_path" > "$baseline_file" 2>/dev/null; then
            print_success "Baseline extracted from $SCONTROL_REF_BRANCH:$alt_path"
            BASELINE_REPORT="$baseline_file"
            return
        fi
    done

    print_error "Could not find baseline report in $SCONTROL_REF_BRANCH"
    print_step "Tried paths: $baseline_path, reports/baseline/report.xml, reports/misra_report.xml"
    exit 1
}
run_analysis() {
    local report_suffix=""
    
    # Determine report suffix based on analysis scope
    if [ "$SCONTROL_MODE" = "branch" ] && [ "$NEW_VIOLATIONS_ONLY" -eq 1 ]; then
        report_suffix="_branch_new"
    elif [ "$SCONTROL_MODE" = "branch" ]; then
        report_suffix="_branch"
    elif [ "$SCONTROL_MODE" = "local" ] && [ "$NEW_VIOLATIONS_ONLY" -eq 1 ]; then
        report_suffix="_local_new"
    elif [ "$SCONTROL_MODE" = "local" ]; then
        report_suffix="_local"
    elif [ "$NEW_VIOLATIONS_ONLY" -eq 1 ]; then
        report_suffix="_new_only"
    fi
    
    local report_dir="$OUTPUT_DIR/misra_cpp_2023${report_suffix}"
    mkdir -p "$report_dir"
    
    print_step "Running MISRA C++ 2023 analysis..."

    cd "$PROJECT_ROOT"

    local cpptest_cmd
    cpptest_cmd=("$CPPTEST_STD/cpptestcli" -config "$TEST_CONFIG" -compiler "$COMPILER" -module .)
    cpptest_cmd+=(-exclude '**/googletest/**' -exclude '**/googlemock/**' -exclude '**/tests/**')

    # Add scope control properties for branch or local analysis
    if [ "$SCONTROL_MODE" = "branch" ] || [ "$SCONTROL_MODE" = "local" ]; then
        cpptest_cmd+=(-property scope.scontrol=true)
        cpptest_cmd+=(-property scope.scontrol.files.filter.mode="$SCONTROL_MODE")
        cpptest_cmd+=(-property scontrol.rep1.type=git)
        cpptest_cmd+=(-property scontrol.rep1.git.workspace="$SCONTROL_GIT_WORKSPACE")
        cpptest_cmd+=(-property scontrol.git.exec="$SCONTROL_GIT_EXEC")
        
        # Auto-detect git URL if not provided
        if [ -z "$SCONTROL_GIT_URL" ]; then
            SCONTROL_GIT_URL=$(cd "$SCONTROL_GIT_WORKSPACE" && git remote get-url origin 2>/dev/null || echo "")
            if [ -n "$SCONTROL_GIT_URL" ]; then
                print_step "Auto-detected git URL: $SCONTROL_GIT_URL"
            fi
        fi
        
        if [ -n "$SCONTROL_GIT_URL" ]; then
            cpptest_cmd+=(-property scontrol.rep1.git.url="$SCONTROL_GIT_URL")
        fi
        
        if [ "$SCONTROL_MODE" = "branch" ]; then
            cpptest_cmd+=(-property scope.scontrol.ref.branch="$SCONTROL_REF_BRANCH")
            cpptest_cmd+=(-exclude 'build/_deps/**')
        fi
    fi

    # Add baseline report properties for new violations only
    if [ "$NEW_VIOLATIONS_ONLY" -eq 1 ]; then
        if [ -z "$BASELINE_REPORT" ]; then
            print_error "Baseline report required for --new-violations but not found"
            exit 1
        fi
        cpptest_cmd+=(-property goal.ref.report.file="$BASELINE_REPORT")
        cpptest_cmd+=(-property goal.ref.report.findings.exclude=true)
        print_step "Showing only new violations (baseline: $BASELINE_REPORT)"
    fi

    cpptest_cmd+=(-input "$COMPILE_DB" -report "$report_dir")
    "${cpptest_cmd[@]}" 2>&1 | tee misra_analysis.log
    
    # Store report dir for summary extraction
    LAST_REPORT_DIR="$report_dir"
    
    print_success "Analysis completed"
}

extract_summary() {
    print_step "Extracting analysis summary..."

    local report_dir
    if [ -n "$LAST_REPORT_DIR" ]; then
        report_dir="$LAST_REPORT_DIR"
    else
        report_dir="$OUTPUT_DIR/misra_cpp_2023"
    fi
    
    local report_xml="$report_dir/report.xml"
    if [ ! -f "$report_xml" ] && [ -f "$OUTPUT_DIR/report.xml" ]; then
        report_xml="$OUTPUT_DIR/report.xml"
        report_dir="$OUTPUT_DIR"
    fi

    if [ ! -f "$report_xml" ]; then
        print_error "Report not found: $report_xml"
        return
    fi

    echo ""
    echo -e "${YELLOW}Generated Reports:${NC}"
    echo "  HTML:  $report_dir/report.html"
    echo "  XML:   $report_dir/report.xml"
    echo ""
    echo -e "${BLUE}Summary Output (MCP):${NC}"
    echo "  Use Copilot MCP to parse: $report_dir/report.xml"
    echo "  Target summary: $SUMMARY_DIR/misra_summary.md"

    emit_mcp_summary_hint "$report_xml" "$report_dir"
}

emit_mcp_summary_hint() {
    local report_xml="$1"
    local report_dir="$2"
    local summary_path="$SUMMARY_DIR/misra_summary.md"

    mkdir -p "$SUMMARY_DIR"

    {
        echo "# MISRA C++ 2023 Summary"
        echo ""
        echo "Generated: $(date +%Y-%m-%d)"
        echo "Source: $report_xml"
        echo ""
        echo "## MCP Summary"
        echo ""
        echo "Use the MCP tool to parse violations and update this file."
        echo "Example prompt:" 
        echo "Parse violations from $report_xml and write a standard summary to $summary_path."
        echo ""
        echo "## Reports"
        echo ""
        echo "- $report_dir/report.html"
        echo "- $report_dir/report.xml"
    } > "$summary_path"

    if [ "$SUMMARY_STDOUT" -eq 1 ]; then
        echo ""
        cat "$summary_path"
    fi
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
    parse_args "$@"
    print_header "C++test MISRA C++ 2023 Static Analysis"
    echo ""
    echo "Configuration:"
    echo "  Project: $PROJECT_ROOT"
    echo "  C++test: $CPPTEST_STD"
    echo "  Compiler: $COMPILER"
    echo "  Test Config: $TEST_CONFIG"
    echo "  Compile DB: $COMPILE_DB"
    echo "  Output: $OUTPUT_DIR"
    if [ "$SCONTROL_MODE" = "branch" ]; then
        echo "  Mode: Branch scope (vs $SCONTROL_REF_BRANCH)"
    elif [ "$SCONTROL_MODE" = "local" ]; then
        echo "  Mode: Local scope"
    else
        echo "  Mode: Full scan"
    fi
    if [ "$NEW_VIOLATIONS_ONLY" -eq 1 ]; then
        echo "  Report: New violations only"
    fi
    echo ""
    
    check_prerequisites
    ensure_compile_db
    detect_compiler
    ensure_baseline_report
    run_analysis
    extract_summary
    
    print_header "Analysis Complete"
}

main "$@"
