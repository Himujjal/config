---
description: Stage, commit and push changes with conventional commit format
agent: build
---

Run the git commit skill to stage, commit and push changes with a conventional commit format.

First, run `git status` to see all changes. Then run `git diff --staged` and `git diff` to understand what changed. Run `git log --oneline -5` for commit history context. Analyze the changes and determine the appropriate type and scope (feat, fix, refactor, style, chore, docs, test, perf).

Use commitlint-style format:
```
<type>(<scope>): <subject>

<body>
```

Steps:
1. Stage all changes: `git add -A`
2. Create commit with conventional format
3. Push to remote: `git push`

Rules:
- If there are no changes to commit, do not create an empty commit
- Do not commit secret files (.env, credentials.json, etc.)
- Write concise, descriptive messages that explain the "why" not the "what"
- Use present tense: "add" not "added"
