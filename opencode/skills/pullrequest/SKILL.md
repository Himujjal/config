---
name: pullrequest
description: "Create or update a pull request using gh (GitHub CLI) or fj (Forgejo CLI), including WIP/draft support. Use when you need to open/update a PR from the current branch, compose PR descriptions from commits/diffs, manage PR metadata (title, body, base, labels, reviewers), or work with draft/WIP PRs."
---

# PR Skill (`/pullrequest`)

Creates or updates pull requests using the appropriate CLI (`gh` for GitHub, `fj` for Forgejo) based on the repository context.

## Prerequisites Check

```bash
# Check if we are in a git repo
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "Not inside a git repository."
  exit 1
fi

# Determine which CLI to use
if command -v fj >/dev/null 2>&1 && (git remote -v | grep -iE 'forgejo|codeberg' >/dev/null 2>&1 || [ -f ".forgejo/config" ]); then
  USE_FJ=1
elif command -v gh >/dev/null 2>&1; then
  USE_GH=1
else
  echo "Neither gh nor fj is available."
  exit 1
fi
```

## Workflow

### 1. Analyze Current Branch and Changes

```bash
git branch --show-current
git status
# Commits ahead of base
git log --oneline --graph --decorate --left-right $(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "HEAD")..HEAD 2>/dev/null || git log --oneline HEAD~5..HEAD
# Diff summary
git diff --stat HEAD~$(git rev-list --count HEAD...$(git branch --show-current 2>/dev/null || echo "origin/main" 2>/dev/null || echo "origin/master") 2>/dev/null || echo 1)..HEAD 2>/dev/null || git diff --stat HEAD~1..HEAD
```

### 2. Push Unpushed Changes (if needed)

```bash
# Check unpushed commits
git log --oneline @{u}..HEAD 2>/dev/null || echo "No upstream tracking"
```

If unpushed commits exist:
```bash
git push -u origin $(git branch --show-current)
```

### 3. Compose PR Metadata

Determine:
- **Type**: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `style`
- **Title**: Conventional commit style (e.g. `feat: add login endpoint`)
- **Body**: Summary + Changes + Testing + Breaking Changes
- **Base branch**: `main` or `master` (detect from remote)

### 4. Create or Update the PR

**Using `gh` (GitHub):**

```bash
# Create PR
gh pr create \
  --title "feat: add user authentication" \
  --body-file - \
  --base main \
  --label "enhancement" \
  --reviewer "user1,user2"

# Update existing PR (title/body/labels)
gh pr edit <pr-number> --title "Updated title" --body "Updated body"
gh pr edit <pr-number> --add-label "bug" --remove-label "wip"
```

**Using `fj` (Forgejo):**

```bash
# Create PR (with autofill or manual title/body)
fj pr create "feat: add login endpoint" --body "Changes..."
# Or with autofill from commits
fj pr create -aA  # --autofill --agit

# Update PR
fj pr edit <pr-id> title "Updated title"
fj pr edit <pr-id> body "Updated body"
fj pr edit <pr-id> labels --add "bug" --remove "wip"
```

### 5. Verify After Creation/Update

```bash
# For gh
gh pr view --web  # or print URL
gh pr list --head $(git branch --show-current)

# For fj
fj pr view
fj pr status
```

### WIP / Draft mode

If the title starts with `WIP:` or the user says WIP/draft, create as a draft:

**Using `gh` (GitHub):** `gh` supports drafts natively.

```bash
# Create as draft
gh pr create --draft \
  --title "feat: add user authentication" \
  --body-file - \
  --base main

# Mark an existing draft PR as ready for review
gh pr ready <pr-number>
```

**Using `fj` (Forgejo):** `fj` has no draft flag, so emulate drafts with a `[WIP]` title prefix + `wip` label and a body note.

```bash
# Create as WIP (fj has no --draft flag)
fj pr create "[WIP] feat: add login endpoint" --body "**Status: WIP — do not merge**

Changes..."

# Optionally ensure the wip label is set
fj pr edit <pr-id> labels --add "wip"

# Mark ready: drop the WIP prefix + remove the wip label
fj pr edit <pr-id> title "feat: add login endpoint"
fj pr edit <pr-id> labels --remove "wip"
```

## Best Practices

- Keep PRs focused (<500 lines when possible).
- Include testing notes and screenshots for UI changes.
- Link related issues: `Fixes #123`, `Relates to #456`.
- Use conventional commit style for titles.

## References

- For detailed PR best practices: `references/pullrequest-best-practices.md` (see gist concept).
- `skills/commit` for commit message conventions.
- `skills/forgejo-cli` for full `fj` command reference.
