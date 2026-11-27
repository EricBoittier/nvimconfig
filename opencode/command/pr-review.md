---
description: Risk-ranked PR diff review that writes a Neovim quickfix file for <leader>gt.
---

Review the current branch's PR diff against `$ARGUMENTS` (if empty, detect the PR base via `gh pr view --json baseRefName -q .baseRefName` and use `upstream/<base>` or `origin/<base>`, falling back to `origin/main`):

1. Inspect `git log --oneline <base>..HEAD` and `git diff <base>...HEAD`.
2. Rank risky hunks (bugs, ABI/API mismatches, lifetime/memory/autograd issues, missing edge cases, untested paths) ahead of mechanical changes.
3. Write a Neovim quickfix file to `$(git rev-parse --git-path review-triage.qf)` with one entry per finding in `path:line:col: [HIGH|MED|LOW] concise reason` format so `<leader>gt` in Neovim jumps straight to each hunk.
4. Print a short bulleted brief of the top findings and which files are safe to skim.
