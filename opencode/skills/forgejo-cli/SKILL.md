---
name: forgejo-cli
description: Use ONLY when in a Forgejo repo using fj forgejo-cli for repos, issues, PRs, actions, users, orgs. Do not use for GitHub, GitLab, Gitea-only workflows.
---

# Forgejo CLI (fj)

Up-to-date with `forgejo-cli 0.5.0`.

> Installation and authentication are pre-configured for you. Do not reinstall or re-authenticate. Assume `fj` is installed and authenticated.

## Activation Gate

Use this skill ONLY if ALL of these hold, otherwise ignore it completely:

1. Current directory is inside a git repo (`git rev-parse --show-toplevel` succeeds), AND
2. At least one is true:
   - `git remote -v` shows a Forgejo host (e.g. `codeberg.org`, `code.forgejo.org`, `*.next.forgejo.org`, self-hosted Forgejo, or any remote where `fj` works), OR
   - `.forgejo/` config exists, OR
   - `fj repo view` succeeds in the current repo without `--repo` / explicit URL
3. `fj` binary is available.

If not in a Forgejo repo, do NOT use `fj` commands. Use normal `git` / `gh` / other tools instead.

To view a wiki page on the terminal, use:

```
fj wiki view --repo codeberg.org/forgejo-contrib/forgejo-cli "<PAGE>"
```

Wiki source: `https://codeberg.org/forgejo-contrib/forgejo-cli/wiki`
Wiki edit repo: `Cyborus/forgejo-cli-wiki` (push-mirrored to wiki tab).

Host override (when needed): `fj -H, --host`. Auto-detects host from git remote if in a git repo.

---

## 1. Repositories

### Creating, Forking, and Deleting

Creating a new repo can be done with `fj repo create`. Set its description with the `--description` flag, and make it private with the `--private` flag. If your current directory is a git repo, you can use the `--remote` flag to set the new repo as a remote locally, and use the `--push` flag to push the local repo. Using `--push` without `--remote` will add an `origin` remote.

You can fork a repo with `fj repo fork`. By default, the fork will have the same name as the original. You can change it with the `--name` flag.

Migrating a repository from another git provider is done with `fj repo migrate <URL> <NAME>`. If you only specify the repo name, it will migrate it into your account. You can migrate into an organization by specify the full name for the new repo, i.e. `demo-org/demo-repo` instead of just `demo-repo`.

By default, this will only migrate git data. A specific hosting service and be chosen with the `--service` flag, and migration items can be picked with the `--include` flag, which takes a comma-separated list of any of the following items:

- `lfs`
- `wiki`
- `issues`
- `prs`
- `milestones`
- `labels`
- `releases`

Migrating anything other than `lfs` or `wiki` requires setting authentication with `--token` or `--login`. These flags read from stdin and do not take command line values. If LFS files live on a diffent url, that can be set with `--lfs-endpoint`.

A migration can be made a pull mirror with `--mirror`, and made private with `--private`.

Note, that migration is only supported **to** a Forgejo instance. If you want to migrate a repository from a Forgejo instance to Gitlab, Github etc you will need to their tools.

Deleting a repo is done with `fj repo delete`. Be careful, this cannot be undone!

Examples:

```
fj repo create example-repo --description "This is an example!"
fj repo create example-repo-2 --push --remote codeberg
fj repo fork forgejo/forgejo --name forgejo-changes
fj repo delete Cyborus/example-repo
fj repo migrate https://codeberg.org/forgejo-contrib/forgejo-cli forgejo-cli --include wiki,releases --token
```

### Editing a repo

Repo settings, such as whether it's private or archived, or its description, can be changed with `fj repo edit`. It takes various flag arguments for the various settings that can be changed.

Repo units, such as the issue tracker or the wiki, can be managed with `fj repo units`. Each unit has its own subcommand under it, such as `fj repo units wiki`. They take flag arguments to update their settings, similar to `fj repo edit`.

### View a repo

`fj repo view` will show basic info about a repository, i.e. name, description, primary language, issues, etc.

`fj repo readme` will print out the repo's `README.md` or `README.txt`

`fj repo browse` opens the repo in your web browser.

`fj repo clone` will clone the repo to your machine, much like `git clone`. The new directory defaults to the repository's name, but can be specified with the `[PATH]` argument

Examples:

```
$ fj repo view forgejo-contrib/forgejo-cli
forgejo-contrib/forgejo-cli
> CLI application for interacting with Forgejo

Primary language is Rust
25 stars - 4 watching - 2 forks
6 issues - 0 PRs - 6 releases
```

```
fj repo browse forgejo/forgejo
fj repo clone Cyborus/forgejo-api # Clones into ./forgejo-api
fj repo clone codeberg.org/forgejo-contrib/forgejo-cli fj # Clones into ./fj
```

### Stars

You can add and remove stars from a repo with `fj repo star` and `fj repo unstar`

Examples:

```
fj repo star forgejo-contrib/forgejo-cli # yay!
fj repo unstar forgejo-contrib/forgejo-cli # aww :(
```

---

## 2. Issues

### Issue IDs

An issues ID can either be its number, i.e. issue `42`, or it can include the repo name, i.e. `forgejo-contrib/forgejo-cli#42`. All mentions of an "issue id" follow this format unless specified otherwise.

### Creating an issue

Create an issue with `fj issue create`. The title of the issue is a required argument. The text content can be set with the `--body` flag, but if that isn't used, your editor will be opened.

If you prefer to create an issue in the web browser, you can use `fj issue create --web`.

#### Templates

If the repository uses issue templates, you will have to pick one to use when creating an issue. This is done with the `--template` flag. It takes the file name of the template you want, which you can list with `fj issue templates`.

Content-based templates will pre-populate the body text with the template before opening your text editor. Form-based templates will be opened as a markdown-based form in your editor. For example, text boxes will be a markdown codeblock. Editing outside of the entry fields will cause the creation to fail.

If the repository has it enabled, you can use `--no-template` to create a default blank-slate issue.

### Editing an issue

Need to change what you wrote? Use `fj issue edit` to change an issue's text. `fj issue edit <id> title` and `fj issue edit <id> body` will modify the respective part of the issue. You can write the new contents on the command line, or leave it blank to write it in your editor.

Labels can be added to issues with `fj issue edit labels`, using the `--add` and `--remove` flags.

### Closing an issue

Closing an issue is done with `fj issue close`. A comment can be added before closing with the `--with-msg` flag. You can write the message on the command line, or leave it blank to write it in your editor.

### Examples

```
fj issue create "Replace chocoearly with vanilla" --repo Bakery/recipes
# Whoops! It's choco-LATE not choco-EARLY
fj issue edit Bakery/recipes#16 title "Replace chocolate with vanilla"
fj issue close Bakery/recipes#16 --with-msg "Let's instead add a new vanilla version"
```

### Comments

`fj issue comment` is for leaving a comment on an issue, `fj edit comment` is for editing one. Same behavior for writing its contents as issues, same way of specifying the issue.

Examples:

```
fj issue comment 16 "but I like chocolate!"
fj issue edit 16 comment 1 # opens the message contents in your editor
```

### Assigning users

`fj issue assign` can be used to assign users to an issue. The first argument is the issue's number, then followed by a list of users to assign. `fj issue unassign` is the same, but to remove assignments.

`fj pr assign` and `fj pr unassign` do the same for pull requests, though the PR number is provided as a flag rather than a positional argument. If the number is not provided, it will be guessed.

### Viewing issues

`fj issue view` displays the issue in the terminal. `fj issue view <id> comments` displays all the comments on an issue. `fj issue view <id> comment <idx>` displays a specific comment

To list all issues on a repo, use `fj issue search`.

`fj issue browse` opens the issue in your browser.

Examples:

```
fj issue view 16
fj issue view 16 comments
fj issue browse Barkey/recipes#16
```

---

## 3. PRs

### PR Ids

Pull request IDs follow the same format as Issue IDs, except in many cases they can be omitted when the current branch is tracking a PR.

### Creating a pull request

Pull requests are created using `fj pr create`. The title of the PR is taken as a positional argument, and the body can be provided as an argument with the `--body` flag, read from a file with the `--body-from-file` flag, or your `$EDITOR` will be opened for you to write it if neither of those flags are set.

Pull request templates work the same way issue templates do, except there is no `--template` flag as repositories can only have one pull request template.

By default, the base branch will be the primary branch of the repo, and the head will be the local branch's remote tracking branch. These can be overridden with the `--base` and `--head` flags. If the base is prefixed with `^` and your repository is a fork the PR will be filed against the upstream repo.

If you'd rather create the PR in the browser, you can use `fj pr create --web` to open the comparison page.

#### AGit

Normally, you have to `git push` your commits before you can create a pull request. If you don't want to, or cannot, create a fork, the `--agit` flag is available. It functions as a wrapper around Forgejo's AGit support, creating the pull request directly from your local commits.

#### Autofill

The `--autofill` flag will automatically populate the title and body of the pull request from your commits, like the web UI. If only as single commit is present, the commit's summary line and body text will be used for the title and body, respectively. If there are multiple commits, the PR's title will be the name of your branch, and the body will include the messages of every included commit.

The title and body can still be provided as command line arguments, which will take precedence over the automatic contents.

#### Examples

Standard workflow

```
git switch -c feature-branch
git commit -m "Example pr!"
# The --set-upstream is required if that branch doesn't already exist in the remote
git push --set-upstream origin feature-branch
fj pr create "This is a PR!"
```

Filing a PR against upstream

```
git switch -c feature-branch
git commit -m "Example pr!"
# The --set-upstream is required if that branch doesn't already exist in the remote
git push --set-upstream origin feature-branch
fj pr create --base ^ "This is a PR for upstream"
```

AGit workflow

```
git switch -c feature-branch
git commit -m "A new feature"
fj pr create "Add a new feature" --agit
```

`--agit` and `--autofill` are compatible.

```
git switch -c update-dep
git commit -m "chore: update `foo` dependency"
fj pr create -aA # this is short for "--autofill --agit"
```

### Editing a pull request

`fj pr edit` is largely the same as `fj issue edit`, except for `edit labels`. Add a label with the `--add` flag and remove with the `--remove` flag

Examples:

```
fj pr edit labels \
    --add "Priority/High" \
    --add "Release Blocker" \
    --remove "Priority/Medium"
```

### Viewing a pull request

`fj pr view` displays the text body, title, changed lines, etc. of a pull request.

`fj pr status` displays the mergeability and CI status of a pull request. Use the `--wait` flag to only exit once every check has completed.

`fj pr checkout` checks out a pull request in a new local branch. The ID is required in this case. Prefix the ID with `^` to access a PR from the parent repo.

Examples:

```
fj pr view forgejo-contrib/forgejo-cli#42
fj pr browse codeberg.org/forgejo-contrib/forgejo-cli#42
fj pr checkout ^16
```

### Comments

The `fj pr comment` and `fj pr edit comment` commands are the same as the corresponding issue commands. See the issues section for more.

### Merging and closing

Merge a PR with `fj pr merge`. Uses the repo's main merge style by default, but that can be changed with the `--method` flag. If a commit title and message are needed, they can be set with the `--title` and `--message` flags. Set `--delete` to delete the PR's remote branch.

`fj pr close` is the same as `fj issue close`.

Examples:

```
fj pr merge --delete --method rebase
fj pr close 42 --with-msg "Thanks, but this change is outdated now"
```

---

## 4. Actions

All current or past tasks can be listed with `fj actions tasks`.

Dispatch a new task with `fj actions dispatch <NAME> <REF> [--inputs <KEY>=<VALUE>]`. For example, `fj actions dispatch publish.yaml main --inputs version=10`.

### Variables & Secrets

Actions variables can be listed `fj actions variables list`, created with `fj actions variables create <NAME> <VALUE> [--force]`, and deleted with `fj actions variables delete <NAME>`.

When creating a variable, omit the value from the command to use your editor to write it.

Secrets are managed in much the same way, except with `fj actions secrets` instead of `variables`. The value of a secret cannot be set with your editor.

---

## 5. Users

### Viewing a user's profile

You can view a user's profile with `fj user view`. It will print their username, full name, pronouns, follower count, website, email, bio, and join date, if that information is available to you.

You can view someone's repositories with `fj user repos`, the organizations they are a member of with `fj user orgs`, their followers with `fj user followers`, the people they follow with `fj user following`, and their public activity with `fj user activity`.

For all of the above commands, the username of the person to view is taken as a command line argument. If none is given, it shows your own profile info.

### Following and blocking

You can follow & unfollow other users with `fj user follow` and `fj user unfollow`, and block & unblock other users with `fj user block` and `fj user unblock`.

### SSH & GPG Keys

SSH can be managed with the `fj user key` commands. Given a path to an SSH public key file, `fj user key upload` will upload that key to your account. Any commits you sign with the matching private key will then show as "verified" on Forgejo.

**Note!**: Currently forgejo-cli will fail, if the SSH key of the host is unknown to the local machine. This typically happens if you are connecting to a host for the first time. If you see an error message like `Preparing...Error: invalid or unknown remote ssh hostkey; class=Ssh (23); code=Certificate (-17)` this is an indication of that problem. To resolve this you need to add the SSH keys of the host to your list of known hosts. This can be done by using git to connect to the host. It will them prompt you to accept the SSH key of the host. Alternatively, you can directly add the host keys to the list of trusted keys by following the steps below:

```
# If the .ssh directory doesn't already exist on your system
mkdir -p $HOME/.ssh
# Scan the intended host for SSH keys and add them to the known_hosts file.
# If that file already exists make sure to use >> instead of >
# Otherwise that file will be overwritten and you need to
# confirm the keys of other hosts again when you connect to them
ssh-keyscan -H [name of the host to connect to] >> $HOME/.ssh/known_hosts
```

`fj user key list` lets you see the keys you've uploaded, `fj user key view` shows information on a specific public key, and `fj user key delete` lets you disconnect a public key from your account. It does _not_ delete the key from your local machine.

GPG keys can be managed in much the same way with the `fj user gpg` commands. Instead of taking a path to a key file, it takes the email associated with the key, or the ID of the key. By default, it will verify your ownership of the key. If you do not want it to, use `--no-verify`. `fj user gpg verify` can be used to verify later on, if you wish.

Uploading and verify GPG keys requires the `gpg` binary to be present on your `PATH`.

---

## 6. Organizations

### Creating an organization

A new organization is created with `fj org create <NAME>`. The name can only contain alphanumeric characters, `_`, or `-`, and can only start and end with alphanumeric characters. If you'd like to set a name that has special characters, you can set a display name with the `--full-name` option.

Contact and miscellanous information can be included with the `--email`, `--location`, and `--website` options.

The organization can be made private, limited-visibility, or public with the `--visibility` command. See the Visibility section for more.

To add users to the organization, you must add them to a team within the organization. See the Teams section for more info.

#### Editing your organization

All of the above options can be changed afterwards with `fj org edit`, except for renaming it. That must be done via the web interface.

### Viewing organizations

You can use `fj org view` to see info on an organization, `fj org list` to see a list of all organizations, and with `--only-member-of` to only list the organizations you are a member of, `fj org activity` to see everything going on in an organization, and `fj org members` to see who all is a member of an organization,

### Repositories

An organization's repos can be listed with `fj org repo list`. A new repository can be created with `fj org repo create <ORG> <REPO>`, which takes the same arguments as `fj repo create`, so see its documentation for more info.

#### Issue labels

An organization can have a set of issue labels that are included in all of its repositories.

A new label can be created with `fj org label add`. It takes a name, an color (in the form of a hex code), optionally a description, and can be set to be exclusive with other issues of the same scope, if the issue name is of the form `{scope}/{name}`. These can all be changed afterwards with `fj org label edit`.

Labels can be listed with `fj org label list` and removed with `fj org label delete`.

### Visibility

Organizations have three privacy options: private, limited, or public. Private organizations can only be seen by its members, limited organizations can be viewed by any signed-in user, and public organizations can be viewed by anyone.

In addition to this, your own membership in an organization can be set to private or public. By default your membership is private, so that only other members of the organization can see you are a member. You can view and change your membership privacy with `fj org visibility`.

### Teams

Teams are the method of assigning members' permissions to the organization's repositories. By default, the only team is the `Owners` team who has complete access to the organization. More teams can be created with finer-grain access.

#### Creating a team

A new team can be added to an organization with `fj org team create <ORG> <TEAM>`.

Read-only and read-write permissions can be set with `--read-permissions` and `--write-permissions` respectively, both taking a comma-separated list of the following permissions:

- `wiki`
- `ext_wiki`
- `issues`
- `ext_issues`
- `pulls`
- `projects`
- `actions`
- `code`
- `releases`
- `packages`

Permission to create repositories is set with the `--can-create-repos` flag. Access to the organization's repos is set with `fj org team repo add` and `fj org team repo rm`, or access to every repo can be granted with `--include-all-repos`

A team can be given admin permissions with the `--admin` flag.

All of the above options can be changed afterwards with `fj org team edit`.

#### Team members

`fj org team member list` shows all the members of a team. Users can be added and removed from a team with `fj org team member add` and `fj org team member rm`.

#### Viewing a team

You can list all teams with `fj org team list`, and view a specific team with `fj org team view`, and its permissions with `--list-permissions`. All the repos a team has access to can be viewed with `fj org team repo list`.

#### Deleting a team

Teams can be deleted with `fj org team delete`
