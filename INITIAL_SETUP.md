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

4. Paste the content of `prompts/IMPLEMENT_WITH_CLAUDE_CODE.md` into Claude Code.

Do not add production AutoHotkey behavior to the Initial Commit. Let Claude Code
implement it through GitHub Issues.
