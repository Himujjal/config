---
name: clean-plan
description: Clean and summarize PLAN.md files in repositories. Use when the user wants to clean up their PLAN.md by summarizing what has been completed and leaving future work sections empty. This removes noise and keeps plans focused on remaining work.
---

# Clean Plan

Clean PLAN.md files by:
1. Summarizing completed phases/tasks into a brief "Completed Work" section
2. Leaving future work sections empty or with minimal placeholders
3. Removing detailed implementation notes, benchmarks, commit hashes, and noise

## Process

1. Read the existing PLAN.md (case-insensitive search: PLAN.md, plan.md, Plan.md)
2. Identify completed work (checked boxes ✅, "COMPLETE" status, done tasks)
3. Identify incomplete/future work (unchecked boxes, "TODO", "Future", "Next Steps")
4. Create cleaned version with:
   - Brief summary of what was completed (high-level only)
   - Empty or minimal placeholders for future work
   - Remove: detailed results, benchmarks, file lists, commit hashes, code snippets

## Output Format

```markdown
# Project Plan

## Completed

Brief summary of major completed phases/milestones (1-3 lines each max).

## In Progress / To Do

- [ ] Future task 1
- [ ] Future task 2
```

## Rules

- If no PLAN.md exists, create a minimal template
- Keep completed summaries under 20 lines total
- Remove all code blocks, benchmark results, and commit references
- Preserve only the high-level structure and future work items
- Use imperative mood for future tasks
