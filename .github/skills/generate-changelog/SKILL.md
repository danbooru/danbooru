---
name: generate-changelog
description: Generate a changelog for a specified commit range.
argument-hint: "--commits=origin/production..master"
---

# Generate changelog

Generate a changelog by calling `bin/generate-changelog`, then filling in the `Changes` and `Fixes` sections based on
the commits in the generated changelog.

## When to use

- The user asks for release notes or a changelog.

## Procedure

1. Run the script to generate the base changelog:
   - `bin/generate-changelog <arguments>`
   - Default to `bin/generate-changelog origin/production..master` when no arguments are provided.
2. For each commit, read the full commit message, diff, and any linked pull requests or issues to fully understand the changes being made.
   - For pull requests: `gh pr view <number> --json title,body`
   - For issues: `gh issue view <number> --json title,body`
3. For each change, classify it as either a `Change` or a `Fix` and summarize it in one bullet point.
   - If a change is not user-visible, exclude it from the changelog.
4. Replace the bullets in the `Changes` and `Fixes` sections.
   - Keep the rest of the generated output structure unchanged (date, commit table, compare link).
5. Return the completed changelog in the requested format.

## Classification guidelines

- Put user-visible features, enhancements, changes, and improvements under `Changes`.
- Put bug fixes under `Fixes`.
- Keep each item to one bullet point.
- Do not include internal changes that are not user-visible, such as refactors, code cleanup, test case fixes, or dependency updates.
- Do not include fixes for bugs that were introduced during development and were never released to production.
- Read each commit along with any linked issues or pull requests to fully understand the changes.

## Writing guidelines

- Use clear user-facing wording, not internal implementation details.
- If no user-visible items exist for a section, leave the section header and omit bullets for that section.
- Refer to https://danbooru.donmai.us/forum_topics/17913 for examples of well-written changelogs.

## Stop conditions

Stop and ask the user before continuing if:

- The commit range is missing or invalid.
- `bin/generate-changelog` fails.
- GitHub authentication is required for `gh` commands and is not available.
- A change is ambiguous and it's unclear whether it belongs in `Changes`, `Fixes`, or should be excluded entirely.

## Completion checks

- Script was run successfully.
- `Changes` and `Fixes` bullets were replaced from commit-derived summaries.
- Non-user-visible/internal-only work was excluded.
