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

1. Call `cpptest-sa-get_rule_documentation` with the rule ID to retrieve the official rule explanation before proposing a fix.
2. Optionally call `cpptest-sa-get_relevant_rules` to find related rules that may also apply.

Base all fix suggestions on the MCP-retrieved rule documentation, not on general knowledge alone.

## MCP Tool Parallelism

**Never** call `cpptest-ct` or `cpptest-sa` MCP tools in parallel. Always invoke them sequentially, waiting for each call to complete before making the next one.
