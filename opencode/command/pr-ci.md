---
description: Inspect GitHub PR CI checks and diagnose the first failing job log.
---

Check CI status for PR `$ARGUMENTS` (or the current branch's PR if no argument is given):

1. Run `gh pr checks $ARGUMENTS` to list passing, pending, and failing checks.
2. For each failing check, fetch its failed log with `gh run view <run-id> --log-failed` (or the check URL's run ID).
3. Summarize:
   - Overall count (pass / fail / pending).
   - Root cause of each failure with exact file and line numbers.
   - Whether the failure is due to the PR branch being behind its base branch vs a bug in the PR.
   - A concrete next step (do not edit files yet unless asked).
