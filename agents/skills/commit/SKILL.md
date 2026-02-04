---
name: commit
description: Generate conventional commit messages from git changes. Use when user asks to commit changes, create a commit message, or summarize git changes for a commit. Use when user wants to prepare a commit or needs help writing a commit message for their code changes.
---

# Commit Message Generation

Generate a commit message from the current git changes.

## Guidelines

- Don't commit or use git unless explicitly asked to do so
- Only output commit messages when a particular task is done
- Commit messages follow conventional commit format

## Commit Message Format

```
feat(<task>): <description>
```

**Examples:**
- `feat(compiler): add support for function declarations`
- `fix(parser): resolve tokenization error for multiline strings`
- `refactor(type-checker): simplify inference logic`

## Commit Descriptions

- Use bullet points only
- Keep them short and concise
- One bullet per logical change

## Commands to Run

To understand the changes, run these git commands:

```bash
git status
git diff
git diff --staged
```

## Workflow

1. Run the git commands to see current changes
2. Analyze what files were changed and why
3. Determine the appropriate commit type (feat, fix, refactor, etc.)
4. Identify the task/component scope
5. Write a concise description
6. Output the commit message in the format above
7. Wait for user confirmation before committing
