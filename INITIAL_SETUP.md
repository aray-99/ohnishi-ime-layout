# Initial Commit setup

1. Replace `REPLACE_WITH_COPYRIGHT_HOLDER` in `LICENSE`.
2. Create the repository and copy these files to its root.
3. Run:

```powershell
git init
git add .
git commit -m "chore: establish requirements and issue-driven workflow"
git branch -M main
git remote add origin <GITHUB_REPOSITORY_URL>
git push -u origin main
./scripts/create-issues.ps1
claude --model opus
```

4. Point Claude Code at `CLAUDE.md` and work through the GitHub Issues.

Do not add production AutoHotkey behavior to the Initial Commit. Let Claude Code
implement it through GitHub Issues.

> Note: this file documents the one-time bootstrap. The `LICENSE` copyright
> holder has since been set. For ongoing work see `CONTRIBUTING.md`.
