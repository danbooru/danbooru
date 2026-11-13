---
name: security-audit
description: "Audit commits that haven't been deployed yet for security vulnerabilities. Use when the user asks for a security audit, a pre-deploy security check, or to review undeployed commits for vulnerabilities."
argument-hint: "--commits=<latest production tag>..master"
---

# Security audit

Review every commit since the last deploy for vulnerabilities, using the bugs we've fixed before as a checklist.

## When to use

- The user asks for a security audit or a pre-deploy security review.
- The user asks whether undeployed commits introduce vulnerabilities.

## Procedure

1. Find the commit range.
   - Run `git fetch --tags origin` (continue with local tags if it fails).
   - The latest deploy is the newest `production-*` tag: `git tag --list 'production-*' --sort=-creatordate | head -1`.
   - Default range is `<tag>..master`. Use the range the user gives if there is one.
2. List the commits with `git log --reverse --format='%h %s' <range>`.
   - Skip merge commits and test-only or docs-only commits, but list what you skipped.
   - Don't read dependency bumps (`chore(deps)`) in full, but check them for known vulnerabilities instead of skipping
     them silently: `npm audit` for JS, and the changelog or `bundle-audit` for gems.
   - Don't skip CI, Dockerfile, or build changes. See "Build and CI" in the patterns reference.
3. For each remaining commit, read the full message and diff (`git show <sha>`), then read the surrounding code it touches.
   A diff alone isn't enough: check the callers, the policy, the controller, and the view that use the changed code.
   See `app/controllers/README.md` for how authorization, `permitted_attributes`, and `api_attributes` fit together.
4. Check each commit against [references/vulnerability-patterns.md](references/vulnerability-patterns.md).
   Also look for anything else that looks dangerous; the list isn't exhaustive.
   If the list is missing attack categories, be proactive and suggest an update.
5. Then think like an attacker, past the known patterns. For each commit, ask:
   - Abuse: what's the worst a user at each level (anonymous, member, builder, mod) can do with this? Changes that give
     trusted roles more power count too.
   - Multi-step and state: can an earlier step (another BUR line, a previous request, an edit after approval) change
     the state a permission check relied on?
   - Races: can two concurrent requests both pass a check-then-act (double approve, double vote, double use)?
   - Caching: can a response that depends on the current user be cached publicly or under a key shared between users?
   See the matching sections in the patterns reference.
6. Verify every suspected issue before reporting it.
   - Write a failing test (functional test for controllers/API, unit test for models) or reproduce it in `bin/rails runner`.
   - Don't fix anything unless the user asks. Delete throwaway tests afterwards unless the user wants to keep them.
7. Report the results.

## Report format

Start with the range audited and the number of commits reviewed and skipped. Then for each finding:

- **Severity**: Critical / High / Medium / Low / Info.
- **Commit**: `<sha> <subject>`, plus `file:line`.
- **Issue**: what's wrong, in one or two sentences.
- **Reproduction**: the request, URL, or test that demonstrates it.
- **Suggested fix**: brief.

List suspected issues you couldn't confirm separately, marked as unconfirmed. If nothing was found, say so plainly. Don't
pad the report with commits that are fine.

## Severity guidelines

- **Critical**: Account takeover, RCE, SQL injection, stored XSS, auth bypass.
- **High**: Leaking private data (emails, IPs, hidden posts, mod-only content), privilege escalation, SSRF.
- **Medium**: Info leaks that need effort to exploit, DoS from a single request, open redirects, missing rate limits on abusable actions.
- **Low**: Minor info leaks (e.g. `has_*` search counts), defense-in-depth gaps.
- **Info**: Not exploitable, but inconsistent with how the rest of the codebase handles it.

## Stop conditions

Stop and ask the user before continuing if:

- No `production-*` tag can be found, or the range is empty or invalid.
- You find something that looks actively exploitable on production. Report it immediately instead of finishing the audit
  first, and don't put details in public places (GitHub issues, commit messages, PRs).

## Completion checks

- Every non-skipped commit in the range was read in full, along with the code around it.
- Each commit was checked against every category in the patterns reference.
- Each commit was checked for abuse, multi-step bypasses, races, and caching (step 5).
- Each reported finding was reproduced, or clearly marked as unconfirmed.
- Temporary files and throwaway tests were deleted.
