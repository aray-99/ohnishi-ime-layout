# Contributing

This repository uses **git-flow** branching and **Conventional Commits**.

## Branches

| Branch | Purpose |
|---|---|
| `main` | Release-only. Every commit is a tagged release. Never commit directly. |
| `develop` | Integration branch for completed work. |
| `feature/issue-<n>-<short-name>` | One GitHub issue. Branches off `develop`, merges back into `develop`. |
| `release/<version>` | Stabilize a release. Branches off `develop`, merges into `main` (tagged) and back into `develop`. |
| `hotfix/<version>` | Urgent fix. Branches off `main`, merges into `main` (tagged) and `develop`. |

All implementation, behavior, fixes, and material documentation changes must be
tied to a GitHub issue (see `CLAUDE.md` §4).

## Merges

- Merge feature branches into `develop` with `--no-ff` (preserve branch context).
- Do not rewrite published history (`main`, `develop`) unless the owner asks.

## Commits

Conventional Commit subjects:

```
feat: ...      new product functionality
fix: ...       bug fix
docs: ...      documentation only
test: ...      manual/automated verification
refactor: ...  behavior-preserving change
chore: ...     tooling, workflow, housekeeping
```

Use a scope where it helps, e.g. `feat(ime): ...`. The final issue-closing
commit or PR body must contain `Closes #<n>`.

## Releases

1. `release/<version>` off `develop`; finalize docs, changelog, version.
2. PR into `main`, merge `--no-ff`, tag `v<version>`.
3. Merge `main` back into `develop`.

## Static check

AutoHotkey v2 scripts are syntax-checked by loading them with `/ErrorStdOut`;
resident scripts support a `--selfcheck` argument that loads then exits 0.

```powershell
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut src\ime.ahk
```
