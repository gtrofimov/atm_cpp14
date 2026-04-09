# Copilot Instructions for atm_cpp14

## MCP Server Warm-up

At the start of each session, call `cpptest-ct-search_documentation` with query `"coverage metrics"` and `cpptest-sa-search_documentation` with query `"MISRA C++ 2023"` to ensure both MCP servers are connected before any analysis work begins.

## Parasoft Report Parsing

When parsing any Parasoft C/C++test report (XML files in `reports/`), you **MUST** use the appropriate MCP tool:

- **Static analysis reports** (`report.xml` from MISRA or SA runs) → use `cpptest-sa-get_violations_from_report_file`
- **Coverage data** (`.coverage/` directory) → use `cpptest-ct` MCP tools

Do **not** parse report XML manually with Python, bash, or grep. Always invoke the MCP tool first.

## Static Analysis Fix Suggestions

When suggesting fixes for any static analysis violation, you **MUST**:

1. Use the `cpptest-get-rule-docs` skill as the primary method to retrieve rule documentation for each violation.
2. The skill must call `cpptest-sa-get_rule_documentation` first, and for custom/missing rules must fall back to `/home/gtrofimov/parasoft/2025.2/std/cpptest/rules/user` using shell parsing logic (no Python).
3. Optionally call `cpptest-sa-get_relevant_rules` to find related rules that may also apply.

Base all fix suggestions on the MCP-retrieved rule documentation, not on general knowledge alone.

Canonical reusable wording for this policy is stored at:
- `.github/skills/cpptest-get-rule-docs/references/policy-snippet.md`

## MCP Tool Parallelism

**Never** call `cpptest-ct` or `cpptest-sa` MCP tools in parallel. Always invoke them sequentially, waiting for each call to complete before making the next one.

## Tool Selection Policy

This repository is C/C++ only. Use **only** Parasoft C/C++test tools and related `cpptest-*` workflows for analysis, reporting, and remediation.

- Do **not** invoke Jtest or Java-focused analysis tools.
- Do **not** use Java-oriented workflows for C/C++ tasks.
- If a generic static-analysis tool is available, prefer the repository C/C++test scripts and `cpptest-*` MCP tools instead.
