```yaml
change_contract:
  goal: ""
  acceptance_criteria:
    - ""
  constraints:
    - "Follow docs/ai/AI_RULES.md"
    - "Prefer modifying existing code before creating new files"
  touch:
    modify:
      - path: ""
        reason: ""
    create:
      - path: ""
        reason: ""
  no_touch:
    - ""
  must_pass:
    - "tools/check-fast.sh"
    - "tools/check.sh"
```
