---
name: update-dependencies
description: "Update Ruby gems or JavaScript packages. Use for upgrading one or all outdated dependencies with Bundler or npm, reviewing changelogs and breaking changes, and running verification after dependency updates."
argument-hint: "gem, npm package, outdated gems, show changelogs, show breaking changes"
---

# Update Dependencies

Update Ruby gems and JavaScript dependencies safely.

This skill supports three modes:

- Update specific dependencies.
- Update all outdated Ruby gems.
- Update all outdated JavaScript packages.

The workflow is conservative by default: establish a baseline, review upstream changes before editing dependencies, prefer incremental updates when risk is high, and verify the result with tests.

## When to Use

- The user asks to update a Ruby gem, npm package, or a mix of both.
- The user wants help checking whether a dependency update is safe.
- The user wants changelog-aware dependency updates instead of a blind `bundle update` or `npm update`.

## Trigger Patterns

Activate this skill when the user says things like:

- "update rails"
- "update all outdated gems"
- "update all outdated npm packages"
- "run bundle update safely"
- "check which dependencies can be upgraded"

## Inputs

- One dependency name, or a list of names.
- Or an instruction to update all outdated dependencies.
- Optional version constraints or upgrade targets.

If the request is ambiguous, clarify whether the user wants:

- Ruby gems, npm packages, or both.
- One dependency only.
- Several named dependencies.
- Every outdated dependency.

## Procedure

1. Identify the requested scope.
   - Determine whether the user wants Bundler updates, npm updates, or both.
   - If the user named one dependency, update only that dependency unless they explicitly ask for related packages too.
   - If the user asked for all outdated dependencies, inspect outdated lists first and separate high-risk upgrades from low-risk ones.

2. Establish a baseline before changing dependencies.
   - Inspect the working tree and avoid overwriting unrelated user changes.
   - Check the current dependency state with Bundler and/or npm based on requested scope.
   - Record the currently locked version and the requested target if one was provided.
   - If the project already has failing tests, note that before updating so regressions can be attributed correctly.
   - Use `bundle outdated` for Ruby and `npm outdated` for JavaScript.
   - Run `npm install` before `npm outdated` to ensure the lockfile is up to date.

3. Review upgrade risk before running update commands.
   - Read changelog, releases, upgrade guide, or release notes for each dependency and version jump being crossed.
   - For gems, watch for dropped Ruby or Rails support, generator changes, and native extension requirements.
   - For npm packages, watch for dropped Node/browser support, module format changes (ESM/CJS), renamed exports, build tool changes, and required config updates.
   - Prefer official sources first. Use the guidance in [changelog and testing](./references/changelog-and-testing.md).
   - Summarize the relevant breaking changes before modifying files.

4. Choose the update strategy.
   - Ruby gems:
     - For a single gem, prefer `bundle update GEM_NAME`.
     - For several explicitly named gems, update only that set.
   - npm packages:
     - For one package to newest version, use `npm install PACKAGE@latest` (or `--save-dev` for dev dependencies).
     - For many packages in one category, use targeted install commands instead of a blind bulk update when risk is high.
     - Use `npm update` only when the user wants in-range updates constrained by current semver ranges.
   - For all outdated dependencies:
     - Prefer incremental or grouped updates when there are major version bumps or updates to framework-level gems, build tooling, or core frontend libraries.
     - If the user explicitly wants one bulk pass, proceed, but still call out high-risk updates first.
   - Do not edit unrelated dependency constraints unless needed for the requested upgrade.

5. Apply the update.
   - Update the requested gem set with Bundler and/or npm.
   - If the Ruby upgrade includes `rails`, run `bin/rails app:update` after Bundler finishes, then review and reconcile the generated file changes before continuing.
   - If the Ruby upgrade includes `good_job`, run `bin/rails generate good_job:update` after Bundler finishes, then review and reconcile the generated file changes before continuing.
   - Review `Gemfile.lock` and `package-lock.json` diffs plus transitive dependency changes.
   - If either Bundler or npm resolves to a surprising set of additional upgrades, explain that and decide whether to continue or narrow the update.

6. Verify the update incrementally.
   - Run targeted tests for the directly affected area when the impacted subsystem is clear.
   - Then run the project's standard verification command.
   - In this repository, prefer:
     - `bin/rails test <file> -n '/test name/'` for targeted checks.
     - `bin/rails test <file>` for focused file-level verification.
     - `bin/rails test` for broader validation.
     - `bin/rubocop <file>` for files changed as part of the update when linting is relevant.
     - `npm run eslint-all` for JavaScript linting after npm updates.
     - `npm run stylelint-all` for stylesheet linting after npm updates.
   - If updating all outdated gems, escalate from targeted tests to a broader suite before calling the work complete.
   - If updating all outdated npm packages, escalate from targeted checks to broader JS and app verification before calling the work complete.

7. Handle failures explicitly.
   - If tests fail after the update, inspect the failures and determine whether they are caused by the dependency change.
   - If the root cause is clear and within scope, fix compatibility issues and rerun verification.
   - If the failures point to a breaking change that requires product or design decisions, stop and report the blocker clearly.
   - Do not claim success while post-update tests are failing.

8. Report the result.
   - List which dependencies changed and the before and after versions.
   - Summarize important changelog findings and any breaking changes reviewed.
   - Link to the relevant changelog entries, upgrade guides, release notes, or security advisories.
   - Report which tests were run and whether they passed.
   - Call out residual risks, follow-up work, or upgrades intentionally deferred.

## Decision Rules

- Apply release-age gates unless the release is explicitly a security fix:
   - Minor version updates: wait at least 7 days after the initial minor release.
   - Major version updates: wait until the first point release (for example, `2.0.1`) is available.
- If a release is a security fix, the waiting rules above do not apply; proceed with normal risk review and verification.
- If a dependency jump crosses a major version, treat it as high risk until changelog review says otherwise.
- If multiple framework gems or major frontend/build packages are outdated, avoid doing them all at once unless the user explicitly wants a bulk upgrade.
- If changelog information cannot be found, say so and treat the update as higher risk.
- If baseline tests already fail, report that clearly before using test failures as evidence against the upgrade.
- If an update requires a multi-step migration (Rails or frontend tooling), break the work into smaller hops instead of forcing a single large jump.

## Stop Conditions

Stop and ask the user before continuing if:

- The request is ambiguous about which dependency ecosystem to update (Ruby, npm, or both).
- A requested non-security update does not meet the release-age gate yet (minor is less than 7 days old, or major has no first point release).
- The update pulls in unexpected high-risk dependency changes.
- The work tree is not clean and the update would overwrite unrelated user changes.
- Changelog review reveals a breaking migration that needs product-level decisions.
- The project has pre-existing failing tests that make regression attribution unclear.

## Completion Checks

- Only the intended gem or gem set was updated.
- Only the intended dependency set was updated.
- If `rails` was upgraded, `bin/rails app:update` was run and the generated config changes were reviewed.
- Relevant changelogs or release notes were reviewed and summarized.
- `Gemfile.lock` and/or `package-lock.json` changes were inspected.
- Post-update tests were run.
- Any new failures were either fixed or reported clearly as blockers.
- Final output includes changed dependencies, links to changelogs, notable risks or potential breaking changes, and verification results.

## References

- [Changelog and testing](./references/changelog-and-testing.md)
- [Upgrading Ruby on Rails](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html)
