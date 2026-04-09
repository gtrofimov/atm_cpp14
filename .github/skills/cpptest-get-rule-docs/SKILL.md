---
name: cpptest-get-rule-docs
description: 'Primary workflow for obtaining Parasoft C++test rule documentation for violations. Always query cpptest-sa-get_rule_documentation first; if a rule is custom or missing there, fall back to local custom rule docs in /home/gtrofimov/parasoft/2025.2/std/cpptest/rules/user using bash/awk/sed parsing.'
argument-hint: 'Rule ID or report path to document violations'
---

# C++test Rule Documentation (MCP-First + Custom Fallback)

This skill is the primary method for obtaining rule documentation for all C++test static-analysis violations.

Decision policy:
- First choice: `mcp_cpptest-sa_get_rule_documentation` for every rule.
- Fallback: local custom-rule documentation parser for rules not available in the MCP rule catalog.

## When to use this skill

- You need rule documentation for one or more violations from a C++test report
- You want a consistent MCP-first rule lookup process
- You need fallback support for custom user rules under `/home/gtrofimov/parasoft/2025.2/std/cpptest/rules/user`

## Inputs

- Mode A (single rule): `--rule <rule_id>`
- Mode B (report routing): `--report <report.xml> --mcp-violations-json <violations.json>`

Exactly one mode must be selected.

## Workflow

1. Collect violation rule IDs.
   - If a report path is provided, use `mcp_cpptest-sa_get_violations_from_report_file` to get violations and extract distinct rule IDs.
   - If a single rule ID is provided, process that rule directly.
2. For each rule ID, call `mcp_cpptest-sa_get_rule_documentation` first.
3. If MCP documentation is returned, use it as the authoritative rule documentation.
4. If MCP documentation is unavailable (for example custom rule not present), fall back to local custom rule docs:
   - `/home/gtrofimov/parasoft/2025.2/std/cpptest/rules/user/<rule_id>.htm`
  - Parse fields with the bundled shell script (`bash`, `awk`, `sed`; no Python).
5. Return a consolidated output mapping each rule ID to its source:
   - `source: mcp_cpptest-sa_get_rule_documentation` or
   - `source: local-custom-rule-doc`
6. If neither source contains the rule, return `source: not-found` and include actionable next steps.

## Branching logic

- Rule exists in MCP docs:
  - Use MCP content only.
- Rule missing in MCP docs and local `.htm` exists:
  - Use local parsed documentation.
- Rule missing in both:
  - Report as unresolved and list available local custom rules.

## Command

Use the canonical helper script for both single-rule and report modes:

```bash
bash .github/skills/cpptest-get-rule-docs/get_rule_docs.sh --rule <rule_id>
```

List available local custom rules:

```bash
bash .github/skills/cpptest-get-rule-docs/get_rule_docs.sh --list-local-rules
```

Build a report-level rule routing worklist from MCP violations JSON:

```bash
bash .github/skills/cpptest-get-rule-docs/get_rule_docs.sh \
  --report reports/report.xml \
  --mcp-violations-json /path/to/violations.json
```

Optionally print full local docs for custom fallback candidates:

```bash
bash .github/skills/cpptest-get-rule-docs/get_rule_docs.sh \
  --report reports/report.xml \
  --mcp-violations-json /path/to/violations.json \
  --show-local-docs
```

Single-rule mode with local doc output:

```bash
bash .github/skills/cpptest-get-rule-docs/get_rule_docs.sh \
  --rule my_rule_1 \
  --show-local-docs
```

## Completion checks

- Every violation rule ID was routed with MCP as primary
- Any locally known custom rule is marked as a fallback candidate
- Output clearly states per-rule source hint and fallback note
- Local fallback output includes Rule ID, Header, Severity, and Description

## Notes

- This skill intentionally uses shell tools only (`bash`, `awk`, `sed`) and does not use Python.
- This skill defines `cpptest-sa-get_rule_documentation` as the default primary source for all rules.
- Local parsing is fallback-only for custom or missing MCP rule documentation.
- Reuse this policy text in other skills/instructions: [references/policy-snippet.md](./references/policy-snippet.md)
