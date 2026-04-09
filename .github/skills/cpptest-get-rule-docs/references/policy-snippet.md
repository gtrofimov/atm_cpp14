# cpptest-get-rule-docs Policy Snippet

Use this snippet in skills/instructions that require rule documentation before proposing fixes.

```markdown
Rule documentation policy:
1. Use the cpptest-get-rule-docs skill as the primary method for every violation rule.
2. The skill must call mcp_cpptest-sa_get_rule_documentation first.
3. If the rule is missing in MCP (custom/user-defined), fall back to local custom docs in /home/gtrofimov/parasoft/2025.2/std/cpptest/rules/user using shell parsing only (bash/awk/sed, no Python).
4. Base fix suggestions on retrieved rule documentation, not on general assumptions.
```
