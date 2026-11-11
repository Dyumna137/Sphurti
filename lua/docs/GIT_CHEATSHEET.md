# Git Quick Reference

Keep this beside your projects. The full explanations and safe undo procedures are in [`GIT_WORKFLOW.md`](GIT_WORKFLOW.md).

## Daily loop

```powershell
git status --short --branch
git diff
git diff --check
git add -p
git diff --staged
git commit -m "fix(sensor): handle missing pressure samples"
git push
```

## Start / clone / connect

```powershell
git init
git clone https://github.com/USER/REPO.git
git remote add origin https://github.com/USER/REPO.git
git remote -v
git branch -M main
git push -u origin main
```

## Stage

```powershell
git add -- src/sensors.cpp
git add -- include/sensors.hpp tests/test_sensors.cpp
git add -p
git restore --staged -- src/sensors.cpp
```

## Inspect

```powershell
git status -sb
git diff
git diff --staged
git diff --stat
git diff --check
git log --oneline --graph --decorate --all -20
git show --stat <commit>
git blame -- src/sensors.cpp
```

## Branches

```powershell
git switch main
git pull --ff-only
git switch -c feat/spectral-logger
git push -u origin HEAD
git switch main
git merge --no-ff feat/spectral-logger
git push
```

## Undo safely

```powershell
# Unstage, keep working edits
git restore --staged -- path/to/file

# Discard unstaged edits in one file (destructive)
git restore -- path/to/file

# Interactively discard selected hunks
git restore -p -- path/to/file

# Undo last local commit, keep changes staged
git reset --soft HEAD~1

# Reverse a shared commit with a new commit
git revert <commit-hash>
```

Avoid routine use of `git reset --hard`, `git clean -fd` and force-push. They can destroy work or rewrite shared history.

## Stash

```powershell
git stash push -m "wip: sensor calibration"
git stash list
git stash show -p "stash@{0}"
git stash apply "stash@{0}"
git stash pop
```

## Tags

```powershell
git tag -a v0.1.0 -m "First integrated avionics prototype"
git show v0.1.0
git push origin v0.1.0
```

## Neovim shortcuts in this update

| Mapping | Action |
|---|---|
| `Space gs` | Git status (Fugitive if installed, CLI fallback otherwise) |
| `Space gd` | Unstaged diff |
| `Space gD` | Staged diff |
| `Space gl` | Recent commit history |
| `Space gb` | Blame current file |
| `Space tt` | Open Neovim's persistent terminal |
