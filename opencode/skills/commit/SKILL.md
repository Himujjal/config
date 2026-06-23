---
name: commit
description: "Use when committing code: Stages all changes, writes conventional commit message with H1/bullet description, pushes to current branch origin."
---

# Commit & Push Skill

Stages all changes, creates a conventional commit, and pushes to the current branch's origin.

## Usage

```
/commit
```

This will:
1. Stage all changes (staged + unstaged)
2. Analyze changes to generate a conventional commit message
3. Create commit with H1 or bullet-point description
4. Push to origin of current branch

## Conventional Commit Format

```
<type>(<scope>): <subject>

# <description>

## Details
- <detail 1>
- <detail 2>
```

### Types (commitlint default)
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting, etc.)
- `refactor` - Code refactoring
- `perf` - Performance improvements
- `test` - Adding/updating tests
- `chore` - Maintenance tasks
- `build` - Build system changes
- `ci` - CI/CD changes
- `revert` - Reverting changes

### Description Format
**Option 1: H1 Markdown**
```
# Added user authentication flow

## Details
- Implemented JWT token generation
- Added login/logout endpoints
- Created auth middleware
```

**Option 2: Bullet Points**
```
# Changes
- Implemented JWT token generation
- Added login/logout endpoints
- Created auth middleware
```

## Implementation

The skill runs this workflow:

```bash
# 1. Get current branch
BRANCH=$(git branch --show-current)

# 2. Stage all changes
git add -A

# 3. Generate commit message from diff
# (analyzes staged changes to determine type, scope, subject, description)

# 4. Commit
git commit -m "<type>(<scope>): <subject>" -m "<description>"

# 5. Push to origin
git push origin "$BRANCH"
```

## Commit Message Generation Logic

Analyzes `git diff --cached` to determine:
- **Type**: Based on file patterns and change nature
- **Scope**: From directory structure (e.g., `src/auth/` → `auth`)
- **Subject**: Imperative summary of primary change
- **Description**: H1 or bullets summarizing all changes