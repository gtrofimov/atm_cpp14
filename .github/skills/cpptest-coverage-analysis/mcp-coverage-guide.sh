#!/bin/bash
# C/C++test MCP Coverage Analysis Script
# Demonstrates how to use MCP tools for detailed coverage queries

set -e

PROJECT_ROOT="/home/gtrofimov/parasoft/git/atm_cpp14"
COVERAGE_DIR="${PROJECT_ROOT}/.coverage"
BUILD_DIR="${PROJECT_ROOT}/build"

# Colors
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${YELLOW}C/C++test MCP Coverage Analysis${NC}"
echo "=================================="
echo ""

if [ ! -d "$COVERAGE_DIR" ]; then
    echo -e "${YELLOW}No coverage data found. Run coverage first:${NC}"
    echo "  ./.github/skills/cpptest-coverage-analysis/run-coverage.sh"
    exit 1
fi

# Helper function to display MCP tool usage examples
show_mcp_examples() {
    echo -e "${YELLOW}=== MCP Tool Examples ===${NC}"
    echo ""
    
    echo -e "${BLUE}1. Query uncovered lines in ATM.cxx:${NC}"
    echo "   mcp_cpptest-ct_query_line_coverage("
    echo "     source_file: \"${PROJECT_ROOT}/src/ATM.cxx\","
    echo "     query_type: \"notcovered\","
    echo "     coverage_data_dir: \"${COVERAGE_DIR}\""
    echo "   )"
    echo ""
    
    echo -e "${BLUE}2. Query covered lines in Bank.cxx:${NC}"
    echo "   mcp_cpptest-ct_query_line_coverage("
    echo "     source_file: \"${PROJECT_ROOT}/src/Bank.cxx\","
    echo "     query_type: \"covered\","
    echo "     coverage_data_dir: \"${COVERAGE_DIR}\""
    echo "   )"
    echo ""
    
    echo -e "${BLUE}3. Search documentation for MCDC coverage:${NC}"
    echo "   mcp_cpptest-ct_search_documentation("
    echo "     user_query: \"modified condition decision coverage MCDC\""
    echo "   )"
    echo ""
    
    echo -e "${BLUE}4. Learn about coverage suppression:${NC}"
    echo "   mcp_cpptest-ct_how_to_suppress_coverage()"
    echo ""
    
    echo -e "${BLUE}5. Search for decision coverage best practices:${NC}"
    echo "   mcp_cpptest-ct_search_documentation("
    echo "     user_query: \"improve branch coverage decision coverage\""
    echo "   )"
    echo ""
}

# Display source files in project
show_source_files() {
    echo -e "${YELLOW}=== Source Files Available for Coverage Query ===${NC}"
    echo ""
    
    for file in "${PROJECT_ROOT}"/src/*.cxx; do
        filename=$(basename "$file")
        echo -e "  ${GREEN}${filename}${NC}"
        echo "    Path: $file"
        echo "    MCP Query: mcp_cpptest-ct_query_line_coverage("
        echo "                 source_file: \"$file\","
        echo "                 query_type: \"notcovered\","
        echo "                 coverage_data_dir: \"${COVERAGE_DIR}\")"
        echo ""
    done
}

# Display coverage analysis patterns
show_analysis_patterns() {
    echo -e "${YELLOW}=== Recommended Coverage Analysis Patterns ===${NC}"
    echo ""
    
    echo -e "${BLUE}Pattern 1: Find untested components${NC}"
    echo "  For each source file, query 'notcovered' lines"
    echo "  Identifies which functions/lines need test cases"
    echo ""
    
    echo -e "${BLUE}Pattern 2: Analyze test effectiveness${NC}"
    echo "  Query 'covered' lines across all files"
    echo "  Compute coverage percentage per file"
    echo "  Identify test gaps"
    echo ""
    
    echo -e "${BLUE}Pattern 3: Decision coverage analysis${NC}"
    echo "  Use 'query_line_coverage' with suppressed lines"
    echo "  Check for intentionally unexercised branches"
    echo "  Document reasons for coverage gaps"
    echo ""
    
    echo -e "${BLUE}Pattern 4: Document coverage suppressions${NC}"
    echo "  Query suppressed lines in each file"
    echo "  Review suppression annotations"
    echo "  Validate suppression reasons"
    echo ""
}

# Display prompts for Copilot
show_copilot_prompts() {
    echo -e "${YELLOW}=== Prompts to Use with Copilot + MCP ===${NC}"
    echo ""
    
    echo -e "${BLUE}For detailed line coverage:${NC}"
    echo "  \"Query all untested lines in Account.cxx using MCP coverage tools\""
    echo "  \"Which lines in ATM.cxx are not covered by tests?\""
    echo ""
    
    echo -e "${BLUE}For gap analysis:${NC}"
    echo "  \"Analyze coverage gaps and suggest test cases for uncovered code\""
    echo "  \"What functions have 0% coverage and need tests?\""
    echo ""
    
    echo -e "${BLUE}For decision coverage:${NC}"
    echo "  \"Explain decision coverage for Bank.cxx and help write tests for missing branches\""
    echo "  \"Show me all suppressed coverage in the project and why\""
    echo ""
    
    echo -e "${BLUE}For documentation:${NC}"
    echo "  \"Search cpptest documentation for MCDC coverage best practices\""
    echo "  \"How can I suppress coverage for deprecated code?\""
    echo ""
}

# Main menu
show_menu() {
    echo -e "${YELLOW}Select an option:${NC}"
    echo "  1) Show MCP tool usage examples"
    echo "  2) List source files for coverage queries"
    echo "  3) Show recommended analysis patterns"
    echo "  4) Show Copilot prompts"
    echo "  5) Show all"
    echo "  q) Quit"
    echo ""
}

# If no arguments, show menu
if [ $# -eq 0 ]; then
    while true; do
        show_menu
        read -p "Enter choice: " choice
        echo ""
        
        case $choice in
            1) show_mcp_examples ;;
            2) show_source_files ;;
            3) show_analysis_patterns ;;
            4) show_copilot_prompts ;;
            5) 
                show_mcp_examples
                echo ""
                show_source_files
                echo ""
                show_analysis_patterns
                echo ""
                show_copilot_prompts
                ;;
            q|Q) exit 0 ;;
            *) echo "Invalid option" ;;
        esac
    done
else
    # Handle command line arguments
    case $1 in
        examples) show_mcp_examples ;;
        files) show_source_files ;;
        patterns) show_analysis_patterns ;;
        prompts) show_copilot_prompts ;;
        all)
            show_mcp_examples
            echo ""
            show_source_files
            echo ""
            show_analysis_patterns
            echo ""
            show_copilot_prompts
            ;;
        *)
            echo "Usage: $0 [examples|files|patterns|prompts|all]"
            echo ""
            show_menu
            ;;
    esac
fi
