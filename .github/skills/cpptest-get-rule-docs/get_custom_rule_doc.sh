#!/usr/bin/env bash
# get_custom_rule_doc.sh — Display documentation for a custom C++test rule
# Usage: ./get_custom_rule_doc.sh [rule_id]

RULES_DIR="/home/gtrofimov/parasoft/2025.2/std/cpptest/rules/user"

declare -a INDEX_RULE_IDS=()
declare -a INDEX_HEADERS=()
declare -A INDEX_RULE_TO_FILE=()

build_rule_index() {
    local f base header
    for f in "$RULES_DIR"/*.htm; do
        base=$(basename "$f" .htm)
        [[ "$base" == index_* || "$base" == frame ]] && continue
        header=$(awk '
            /<PRE>Header<\/PRE>/ { found=1; next }
            found && match($0, /<PRE>([^<]+)<\/PRE>/, a) { print a[1]; exit }
        ' "$f")
        INDEX_RULE_IDS+=("$base")
        INDEX_HEADERS+=("$header")
        INDEX_RULE_TO_FILE["$base"]="$f"
    done
}

list_rules() {
    echo "Available custom rules:"
    for i in "${!INDEX_RULE_IDS[@]}"; do
        printf "  %-20s %s\n" "${INDEX_RULE_IDS[$i]}" "${INDEX_HEADERS[$i]}"
    done
}

extract_field() {
    local file="$1"
    local label="$2"
    awk -v label="$label" '
        BEGIN { state=0; buf="" }
        {
            # Check if this line contains the label inside a <PRE> tag
            if (state==0) {
                match($0, /<PRE>([^<]+)<\/PRE>/, a)
                if (a[1] == label) { state=1; next }
            }
            # Next <PRE> after label is the value
            if (state==1 && /<PRE>/) {
                # Strip everything before <PRE>
                line=$0; sub(/.*<PRE>/, "", line)
                if (line ~ /<\/PRE>/) {
                    # Value is on a single line
                    sub(/<\/PRE>.*/, "", line)
                    print line
                    state=0
                } else {
                    # Value spans multiple lines
                    buf=line
                    state=2
                }
                next
            }
            if (state==2) {
                if (/<\/PRE>/) {
                    line=$0; sub(/<\/PRE>.*/, "", line)
                    buf=buf"\n"line
                    print buf
                    buf=""
                    state=0
                } else {
                    buf=buf"\n"$0
                }
            }
        }
    ' "$file" | sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g; s/&quot;/"/g'
}

if [[ -z "${1:-}" ]]; then
    build_rule_index
    echo "Usage: $0 <rule_id>"
    echo ""
    list_rules
    exit 0
fi

RULE_ID="$1"
build_rule_index
HTM_FILE="${INDEX_RULE_TO_FILE[$RULE_ID]:-}"

if [[ -z "$HTM_FILE" || ! -f "$HTM_FILE" ]]; then
    echo "Error: No documentation found for rule '${RULE_ID}'" >&2
    echo ""
    list_rules >&2
    exit 1
fi

echo "========================================"
echo " Custom Rule Documentation: ${RULE_ID}"
echo "========================================"
echo ""
echo "Rule ID:    $(extract_field "$HTM_FILE" "Rule ID")"
echo "Name:       $(extract_field "$HTM_FILE" "Header")"
echo "Severity:   $(extract_field "$HTM_FILE" "Severity")"
echo "Author:     $(extract_field "$HTM_FILE" "Author")"
echo "Languages:  $(extract_field "$HTM_FILE" "Language Selections")"
echo ""
echo "--- Description ---"
extract_field "$HTM_FILE" "Description"
echo ""
echo "--- Violation Message ---"
extract_field "$HTM_FILE" "Output"
