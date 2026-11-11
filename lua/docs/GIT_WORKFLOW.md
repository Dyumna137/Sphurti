# Git Command Handbook for Engineering Projects

A practical Git workflow for firmware, C/C++, PCB, CAD, simulation, documentation and team projects on Windows PowerShell.

The guiding loop is:

```text
Inspect -> edit -> build/test -> inspect diff -> stage deliberately -> inspect staged diff -> commit -> push
```

Run commands in PowerShell, Windows Terminal, or Neovim's persistent terminal (`Space tt`).

---

## 1. One-time setup on a new machine

Set the author identity used in commits:

```powershell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Useful defaults:

```powershell
git config --global init.defaultBranch main
git config --global core.autocrlf true
git config --global fetch.prune true
git config --global pull.ff only
git config --global merge.conflictstyle zdiff3
git config --global rerere.enabled true
```

Check configuration:

```powershell
git config --global --list
git --version
```

`core.autocrlf true` is a common Windows setting for text-file line endings. For mixed operating systems, also add a `.gitattributes` file and agree on line-ending rules as a team.

## 2. Start a repository

### Create a new local repository

```powershell
cd C:\path\to\your\project
git init
git status
```

Create a `.gitignore` before the first commit. Example for a C/C++ / embedded project:

```gitignore
# Build outputs
build/
cmake-build-*/
Debug/
Release/
*.o
*.obj
*.a
*.lib
*.elf
*.hex
*.bin
*.map
*.exe

# PlatformIO generated data
.pio/

# Editor / OS noise
.DS_Store
Thumbs.db
*.swp
*.swo

# Logs and temporary files
*.log
*.tmp
```

Do not blindly ignore configuration files such as `platformio.ini`, `CMakeLists.txt`, `Makefile`, linker scripts, board configuration, calibration constants, or project documentation. Decide deliberately whether generated files such as `compile_commands.json` belong in your repository.

### Connect to an existing remote

```powershell
git remote add origin https://github.com/USER/REPOSITORY.git
git remote -v
git branch -M main
git add .gitignore
git add README.md
git commit -m "chore: initialise project repository"
git push -u origin main
```

Replace the remote URL with your actual repository URL. Never paste a private access token into a remote URL or commit it to a file.

### Clone an existing repository

```powershell
git clone https://github.com/USER/REPOSITORY.git
cd REPOSITORY
git status
```

---

## 3. Daily workflow: inspect before changing

Start every session with:

```powershell
git status --short --branch
git branch --show-current
git log -5 --oneline --decorate
```

Inspect your working tree:

```powershell
git diff
git diff --stat
git diff --check
```

- `git diff` shows unstaged edits.
- `git diff --stat` gives a compact summary.
- `git diff --check` catches whitespace errors before committing.

See exactly which files are tracked or untracked:

```powershell
git status --short
```

The two status columns are meaningful: `M ` usually means staged modification, ` M` unstaged modification, `??` untracked, and `A ` staged addition.

---

## 4. Stage changes deliberately

### Stage one file

```powershell
git add -- src/sensors.cpp
```

### Stage several files

```powershell
git add -- src/sensors.cpp include/sensors.hpp tests/test_sensors.cpp
```

### Stage selected parts interactively (recommended)

```powershell
git add -p
```

Useful interactive choices in patch mode:

- `y`: stage this hunk
- `n`: do not stage this hunk
- `s`: split into smaller hunks when possible
- `e`: manually edit the patch
- `q`: quit

Then inspect what will actually enter the commit:

```powershell
git diff --staged
git diff --staged --stat
git diff --staged --check
```

Do not commit until the staged diff contains only the change you intend to record.

---

## 5. Commit with clear messages

Use a short action-oriented message. A useful pattern is:

```text
<type>(<area>): <specific change>
```

Examples for engineering work:

```powershell
git commit -m "feat(sensors): add BMP280 pressure acquisition"
git commit -m "fix(telemetry): reject packets with invalid length"
git commit -m "refactor(avionics): separate GPS parsing from UART driver"
git commit -m "test(sensors): add calibration conversion tests"
git commit -m "build(cmake): add host-side unit test target"
git commit -m "docs(osad): document payload power budget"
git commit -m "chore(ci): add formatting and build checks"
```

Common types:

| Type | Use |
|---|---|
| `feat` | New capability |
| `fix` | Bug correction |
| `refactor` | Internal restructuring without intended behavior change |
| `test` | Tests or test infrastructure |
| `build` | Build system and dependencies |
| `docs` | Documentation |
| `chore` | Maintenance/tooling |
| `perf` | Performance improvement |

A commit should ideally represent one coherent change. Avoid messages such as `updates`, `final`, `changes`, or `work`.

---

## 6. Push and synchronise with the remote

Push the current branch:

```powershell
git push
```

For a new branch the first time:

```powershell
git push -u origin HEAD
```

Fetch remote updates without changing your working files:

```powershell
git fetch --prune
git status -sb
git log --oneline --graph --decorate --all -20
```

Update the current branch using fast-forward only:

```powershell
git pull --ff-only
```

If Git says a fast-forward is not possible, stop and inspect the branch graph. Do not immediately reach for `reset --hard` or force push.

---

## 7. Use feature branches for project work

Start a branch for a feature, bug fix or experiment:

```powershell
git switch main
git pull --ff-only
git switch -c feat/spectral-logger
```

Examples:

```powershell
git switch -c feat/telemetry-crc
git switch -c fix/gps-timeout
git switch -c test/bmp280-calibration
```

Work, build, test, stage and commit on that branch. Push it:

```powershell
git push -u origin HEAD
```

After review/approval, integrate it. For a small local project:

```powershell
git switch main
git pull --ff-only
git merge --no-ff feat/spectral-logger
git push
```

For a team repository, normally open a Pull Request and merge through the repository host so the review and CI results remain visible.

---

## 8. Compare files, commits and branches

```powershell
# Current changes vs last commit
git diff

# Staged changes
git diff --staged

# Show one commit
git show --stat <commit>
git show <commit>

# Compare two branches
git diff main..feat/spectral-logger

# Compare one file between branches
git diff main..feat/spectral-logger -- src/sensors.cpp

# Recent history graph
git log --oneline --graph --decorate --all -25

# Who changed each line
git blame -- src/sensors.cpp
```

Use the full commit hash shown by `git log` or `git show`; do not guess it.

---

## 9. Undo mistakes safely

### Unstage a file, keeping its edits

```powershell
git restore --staged -- src/sensors.cpp
```

### Discard unstaged changes in one file

```powershell
git restore -- src/sensors.cpp
```

This permanently discards the unstaged edits in that file. Inspect `git diff` first.

### Interactively discard selected hunks

```powershell
git restore -p -- src/sensors.cpp
```

### Undo the latest local commit but keep all changes staged

```powershell
git reset --soft HEAD~1
```

### Undo the latest local commit but keep changes unstaged

```powershell
git reset --mixed HEAD~1
```

### Reverse a commit that has already been shared

```powershell
git revert <commit-hash>
```

`git revert` creates a new commit that reverses the selected commit. It is generally safer for shared branches than rewriting public history.

**Danger zone:** `git reset --hard`, `git clean -fd`, and force-push commands can destroy work or rewrite shared history. Do not use them as routine cleanup commands. Make a backup branch or copy before any destructive recovery operation.

---

## 10. Stash temporary work

Save unfinished changes temporarily:

```powershell
git stash push -m "wip: sensor calibration experiment"
git stash list
```

Restore the latest stash and remove it from the stash list:

```powershell
git stash pop
```

Apply without removing it:

```powershell
git stash apply "stash@{0}"
```

Inspect a stash before applying:

```powershell
git stash show --stat "stash@{0}"
git stash show -p "stash@{0}"
```

---

## 11. Resolve merge conflicts

When a merge reports conflicts:

```powershell
git status
git diff --name-only --diff-filter=U
```

Open each conflicted file, resolve the conflict markers, then:

```powershell
git add -- path/to/resolved-file
git diff --staged
git merge --continue
```

To abandon the merge before completing it:

```powershell
git merge --abort
```

Build and test after resolving conflicts. A conflict-free merge is not automatically a correct merge.

---

## 12. Tags for releases and milestones

Create an annotated release tag:

```powershell
git tag -a v0.1.0 -m "First integrated avionics prototype"
git show v0.1.0
git push origin v0.1.0
```

List tags:

```powershell
git tag --list
```

Use tags for stable milestones, not every ordinary commit.

---

## 13. A practical Neovim + Git routine

1. Open the project in Neovim.
2. `Space tt` opens the persistent terminal.
3. Run `git status --short --branch`.
4. Edit code, then use `Space mb` to build and `Space mt` to test.
5. Use `Space gd` to inspect unstaged changes.
6. In the terminal, run `git add -p` to stage selected changes.
7. Run `git diff --staged` to review the exact commit contents.
8. Commit with a specific message.
9. Run `git push`.

Useful Neovim Git mappings:

| Mapping | Action |
|---|---|
| `Space gs` | Status |
| `Space gd` | Working-tree diff |
| `Space gD` | Staged diff |
| `Space gl` | Recent log |
| `Space gb` | Blame current file |

The mappings intentionally focus on inspection. Use explicit Git CLI commands for staging, committing, pushing and undoing so you can see exactly what Git will do.
