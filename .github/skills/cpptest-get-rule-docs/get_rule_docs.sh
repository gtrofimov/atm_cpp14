#!/usr/bin/env bash
# get_rule_docs.sh - Canonical helper for cpptest-get-rule-docs skill.
#
# This script is shell-only and focuses on local custom-rule fallback docs
# plus MCP-first source routing hints.

set -euo pipefail

RULES_DIR="/home/gtrofimov/parasoft/2025.2/std/cpptest/rules/user"

declare -a INDEX_RULE_IDS=()
declare -a INDEX_HEADERS=()
declare -A INDEX_RULE_TO_FILE=()

usage() {
    cat <<'EOF'
Usage:
  get_rule_docs.sh --rule <rule_id> [--show-local-docs]
  get_rule_docs.sh --report <report.xml> --mcp-violations-json <violations.json> [--show-local-docs]
  get_rule_docs.sh --list-local-rules

Required inputs (choose one mode):
  --rule <rule_id>                Single-rule mode
  --report <path>                 Report mode (traceability label)
  --mcp-violations-json <path>    JSON output from mcp_cpptest-sa_get_violations_from_report_file

Optional:
  --show-local-docs               Print parsed local custom docs for fallback candidates
  --list-local-rules              Print available local custom rules and exit

Policy:
  - MCP rule docs are primary for all rules.
  - Local docs under /home/gtrofimov/parasoft/2025.2/std/cpptest/rules/user are fallback-only.

Examples:
  bash .github/skills/cpptest-get-rule-docs/get_rule_docs.sh --rule my_rule_1 --show-local-docs

  bash .github/skills/cpptest-get-rule-docs/get_rule_docs.sh \
    --report reports/report.xml \
    --mcp-violations-json /tmp/violations.json
EOF
}

decode_html_entities() {
    sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g; s/&quot;/"/g'
}

build_rule_index() {
    local f base header

    if [[ ! -d "$RULES_DIR" ]]; then
        echo "Error: custom rules directory not found: $RULES_DIR" >&2
        exit 1
    fi

    shopt -s nullglob
    for f in "$RULES_DIR"/*.htm; do
        base=$(basename "$f" .htm)
        [[ "$base" == index_* || "$base" == frame ]] && continue

        header=$(awk '
            /<PRE>Header<\/PRE>/ { found=1; next }
            found && match($0, /<PRE>([^<]+)<\/PRE>/, a) { print a[1]; exit }
        ' "$f")
        header=$(printf '%s' "$header" | decode_html_entities)

        INDEX_RULE_IDS+=("$base")
        INDEX_HEADERS+=("$header")
        INDEX_RULE_TO_FILE["$base"]="$f"
    done
    shopt -u nullglob
}

list_local_rules() {
    local i

    if [[ ${#INDEX_RULE_IDS[@]} -eq 0 ]]; then
        echo "No local custom rules were found in $RULES_DIR"
        return
    fi

    echo "Available local custom rules:"
    for i in "${!INDEX_RULE_IDS[@]}"; do
        printf '  %-24s %s\n' "${INDEX_RULE_IDS[$i]}" "${INDEX_HEADERS[$i]:-N/A}"
    done
}

extract_field() {
    local file="$1"
    local label="$2"

    awk -v label="$label" '
        BEGIN { state=0; buf="" }
        {
            if (state==0) {
                match($0, /<PRE>([^<]+)<\/PRE>/, a)
                if (a[1] == label) { state=1; next }
            }
            if (state==1 && /<PRE>/) {
                line=$0
                sub(/.*<PRE>/, "", line)
                if (line ~ /<\/PRE>/) {
                    sub(/<\/PRE>.*/, "", line)
                    print line
                    state=0
                } else {
                    buf=line
                    state=2
                }
                next
            }
            if (state==2) {
                if (/<\/PRE>/) {
                    line=$0
                    sub(/<\/PRE>.*/, "", line)
                    buf=buf"\n"line
                    print buf
                    buf=""
                    state=0
                } else {
                    buf=buf"\n"$0
                }
            }
        }
    ' "$file" | decode_html_entities
}

field_or_na() {
    local value="$1"
    if [[ -n "$value" ]]; then
        printf '%s' "$value"
    else
        printf 'N/A'
    fi
}

print_local_doc() {
    local rule_id="$1"
    local htm_file="${INDEX_RULE_TO_FILE[$rule_id]:-}"

    echo "----------------------------------------"
    echo "Local Custom Rule Documentation: $rule_id"
    echo "----------------------------------------"

    if [[ -z "$htm_file" || ! -f "$htm_file" ]]; then
        echo "Status: not-found"
        echo "Note: no local fallback documentation file found"
        return
    fi

    local rule_name severity author languages description output_msg
    rule_name=$(extract_field "$htm_file" "Header")
    severity=$(extract_field "$htm_file" "Severity")
    author=$(extract_field "$htm_file" "Author")
    languages=$(extract_field "$htm_file" "Language Selections")
    description=$(extract_field "$htm_file" "Description")
    output_msg=$(extract_field "$htm_file" "Output")

    printf 'Rule ID:    %s\n' "$(field_or_na "$rule_id")"
    printf 'Name:       %s\n' "$(field_or_na "$rule_name")"
    printf 'Severity:   %s\n' "$(field_or_na "$severity")"
    printf 'Author:     %s\n' "$(field_or_na "$author")"
    printf 'Languages:  %s\n' "$(field_or_na "$languages")"
    echo ""
    echo "Description:"
    if [[ -n "$description" ]]; then
        echo "$description"
    else
        echo "N/A"
    fi
    echo ""
    echo "Violation Message:"
    if [[ -n "$output_msg" ]]; then
        echo "$output_msg"
    else
        echo "N/A"
    fi
}

extract_unique_rule_ids() {
    local mcp_json="$1"
    grep -oE '"rule_id"[[:space:]]*:[[:space:]]*"[^"]+"' "$mcp_json" \
        | sed -E 's/^.*"([^"]+)"$/\1/' \
        | awk 'NF' \
        | sort -u
}

route_rule_source() {
    local rule_id="$1"
    if [[ -n "${INDEX_RULE_TO_FILE[$rule_id]:-}" ]]; then
        printf 'local-custom-rule-doc'
    else
        printf 'mcp_cpptest-sa_get_rule_documentation'
    fi
}

MODE=""
RULE_ID=""
REPORT_PATH=""
MCP_VIOLATIONS_JSON=""
SHOW_LOCAL_DOCS=0
LIST_LOCAL_RULES=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --rule)
            RULE_ID="${2:-}"
            MODE="rule"
            shift 2
            ;;
        --report)
            REPORT_PATH="${2:-}"
            MODE="report"
            shift 2
            ;;
        --mcp-violations-json)
            MCP_VIOLATIONS_JSON="${2:-}"
            shift 2
            ;;
        --show-local-docs)
            SHOW_LOCAL_DOCS=1
            shift
            ;;
        --list-local-rules)
            LIST_LOCAL_RULES=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

build_rule_index

if [[ $LIST_LOCAL_RULES -eq 1 ]]; then
    list_local_rules
    exit 0
fi

if [[ "$MODE" == "rule" && -n "$RULE_ID" && -n "$REPORT_PATH" ]]; then
    echo "Error: use either --rule or --report mode, not both" >&2
    usage >&2
    exit 1
fi

declare -a RULE_IDS=()

if [[ "$MODE" == "rule" ]]; then
    if [[ -z "$RULE_ID" ]]; then
        echo "Error: --rule requires a rule ID" >&2
        usage >&2
        exit 1
    fi
    RULE_IDS=("$RULE_ID")
elif [[ "$MODE" == "report" ]]; then
    if [[ -z "$REPORT_PATH" || -z "$MCP_VIOLATIONS_JSON" ]]; then
        echo "Error: report mode requires both --report and --mcp-violations-json" >&2
        usage >&2
        exit 1
    fi
    if [[ ! -f "$MCP_VIOLATIONS_JSON" ]]; then
        echo "Error: MCP violations JSON not found: $MCP_VIOLATIONS_JSON" >&2
        exit 1
    fi
    mapfile -t RULE_IDS < <(extract_unique_rule_ids "$MCP_VIOLATIONS_JSON")
    if [[ ${#RULE_IDS[@]} -eq 0 ]]; then
        echo "Error: no rule IDs found in MCP violations JSON: $MCP_VIOLATIONS_JSON" >&2
        exit 1
    fi
else
    echo "Error: choose one mode: --rule or --report ... --mcp-violations-json" >&2
    usage >&2
    exit 1
fi

echo "========================================"
echo "C++test Rule Documentation Router"
echo "========================================"
echo "Mode: $MODE"
if [[ "$MODE" == "report" ]]; then
    echo "Report: $REPORT_PATH"
    echo "MCP violations JSON: $MCP_VIOLATIONS_JSON"
fi
echo "Rules discovered: ${#RULE_IDS[@]}"
echo "Policy: MCP-first; local docs are fallback-only for custom/missing MCP rules"
echo ""

printf '%-36s %-38s %s\n' "Rule ID" "Source" "Note"
printf '%-36s %-38s %s\n' "-------" "------" "----"

declare -a LOCAL_CANDIDATES=()
for rule_id in "${RULE_IDS[@]}"; do
    source_hint=$(route_rule_source "$rule_id")
    if [[ "$source_hint" == "local-custom-rule-doc" ]]; then
        LOCAL_CANDIDATES+=("$rule_id")
        printf '%-36s %-38s %s\n' "$rule_id" "$source_hint" "Attempt MCP first; use local fallback if MCP is unavailable"
    else
        printf '%-36s %-38s %s\n' "$rule_id" "$source_hint" "MCP primary path"
    fi
done

echo ""
echo "Summary:"
echo "  Total rules: ${#RULE_IDS[@]}"
echo "  Local fallback candidates: ${#LOCAL_CANDIDATES[@]}"
echo "  MCP-only candidates: $((${#RULE_IDS[@]} - ${#LOCAL_CANDIDATES[@]}))"

if [[ ${#LOCAL_CANDIDATES[@]} -gt 0 ]]; then
    echo ""
    echo "Local fallback candidates:"
    for rule_id in "${LOCAL_CANDIDATES[@]}"; do
        echo "  - $rule_id"
    done
fi

if [[ $SHOW_LOCAL_DOCS -eq 1 ]]; then
    echo ""
    if [[ ${#LOCAL_CANDIDATES[@]} -eq 0 ]]; then
        echo "No local fallback candidates to display."
    else
        echo "Local fallback documentation output:"
        for rule_id in "${LOCAL_CANDIDATES[@]}"; do
            echo ""
            print_local_doc "$rule_id"
        done
    fi
fi
