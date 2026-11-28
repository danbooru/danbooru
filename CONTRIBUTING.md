# Contributing

Thanks for helping out! This page explains how to get started contributing, followed by a detailed list of common mistakes, based on bugs we've fixed before.

## Quick start

**Before you start:** set up your development environment with [docs/README.md](docs/README.md). The easiest way is to open the project in a [Dev Container in VS Code](docs/README.md#visual-studio-code), or in [Codespaces on GitHub](docs/README.md#codespaces).

**How to make a change:**

1. Write a test first. Writing tests first makes it easier to test your code as you work.
2. Make the change.
3. Run the tests for the files you changed (`bin/rails test <file>`).
4. Once it works, run the tests for the whole project to make sure nothing else broke.
5. Write a commit message (see [Commit messages](#commit-messages)), then open a pull request (see [Issues and pull requests](#issues-and-pull-requests)).

**The rules that matter most:**

- **Don't trust user input.** Validate it, limit its size, and escape it.
- **Be mindful of performance.** Watch out for introducing too many new database queries, doing slow work during web requests, and handling huge or pathological inputs.
- **Don't cause errors in views.** An exception while rendering breaks the whole page for everyone who views it.
- **Include tests for every change you make.** Bug fixes need tests proving that the bug is fixed, and new features need tests proving that they work, including in the error paths.

**How to use the rest of this page:** it's a reference, not something to read top to bottom. Skim the section for the area you're changing. The rules in each section start with the most important and common mistakes. Most rules link to examples of fixes for that mistake.

Existing code doesn't always follow these rules. Try to follow them in new code, but don't mix unrelated cleanups into your change.

- [Issues and pull requests](#issues-and-pull-requests), [Commit messages](#commit-messages), [Code style](#code-style)
- [General](#general), [Controllers and API](#controllers-and-api), [Models and database](#models-and-database), [Database design](#database-design), [Migrations and deploys](#migrations-and-deploys), [HTML](#html), [Javascript](#javascript), [CSS](#css)
- [Background jobs](#background-jobs), [Files, HTTP, and external commands](#files-http-and-external-commands), [Tests](#tests), [Source extractors](#source-extractors), [DText parser](#dtext-parser)
- [Security](#security), [Further reading](#further-reading)

## Issues and pull requests

**Reporting bugs and requesting features:**

- Search [existing issues](https://github.com/danbooru/danbooru/issues) first, and comment there instead of opening a duplicate.
- Open a [new issue](https://github.com/danbooru/danbooru/issues/new) for each bug or request. Don't bundle unrelated problems into one report.
- For bugs, include the URL, what happened, the error message, and the steps to reproduce it. You can use https://testbooru.donmai.us to test or demonstrate things instead of the main site.
- Report security vulnerabilities privately. See [SECURITY.md](SECURITY.md).

**Submitting pull requests:**

- Explain what your pull request does, and link to the issue it fixes.
- For large changes, open an issue first to discuss the approach.
- Stick to one logical change per commit. Don't mix together unrelated fixes, refactoring, or formatting changes.
- Include tests. Bug fixes need a test that reproduces the bug.
- Run the tests and linters for the files you changed before opening the pull request, and make sure they pass.
- Split changes that need a migration into stacked pull requests, one per deployment stage (see [Migrations and deploys](#migrations-and-deploys)).
- Rebase your branch on `master` instead of merging `master` into it.
- Consider using an AI agent to review your code, especially for bugs, performance problems, and security issues. They should not be trusted blindly, but they can help you navigate the code or find things you missed.

## Commit messages

A good commit message is a short, plain-English summary of what the commit changes or fixes, and why. The diff already shows the how.

**Titles:**

- If the commit fixes an issue, write `Fix #XXX: <Issue title>` as the title, e.g. `Fix #6431: Upload validation failures cause the error to be [object Object].` GitHub closes the issue when the commit is merged.
- Otherwise, use `<area>: <description>.` as the title, e.g. `posts: fix N+1 queries for child post previews.`
- Pick the area from where the change lives, and reuse areas from past commits.
- For bug fixes, say in the title what was broken, not how the code changed: `comments: fix commenters being able to undelete moderator-deleted comments.`, not `comments: check the saved deleted status when updating comments.` Explain the cause in the body.
- Limit the title to 72 columns (that's the cutoff on GitHub).

**Bodies:**

- Lead with the main point: what was broken, or why the change was needed, then the fix in a clause. The first sentence can restate the title in better words. If the body has several sentences or paragraphs, the first paragraph should sum up the commit in one sentence. A few sentences or less is usually enough. If the title says it all, leave the body out.
- Only explain what the diff doesn't show. Don't list the files or methods you changed, walk through how the code works step by step, or describe how you found the bug, unless the bug is tricky enough to need it.
- Write the fix in the imperative, like the title: `Fix reports leaving out the last day by ending the range at the start of the next day.`
- Leave out details that go stale: local benchmarks, timings, and dates, and status like "tested locally".
- For design changes, say why the new design is better than the old one, and mention alternatives you rejected if a reader would wonder about them.
- When fixing a regression, name the commit that caused it, e.g. `Fix regression in c6720ed4d.` When a change follows up on another commit, reference it instead of explaining it again.
- List any breaking changes to the API, and any manual upgrade steps that people running their own Danbooru instance have to do, like running a script or changing their config.
- Hard wrap the body at about 100 columns.
- For security fixes, describe what was fixed and what it protects, but not how to exploit it: no reproduction steps or payloads. Linking to the private report, issue, or unpublished GHSA advisory is fine, and exploit details can go there.

Before committing, reread the message and delete each sentence a reviewer wouldn't miss. For example, this is too long:

```
reports: fix reports not including the last day.

ReportsController#show passed `from` and `to` to Reports::Base#records, which built the range
with `created_at: from..to`. Since `to` was parsed with `parse_date!`, it was midnight on the end
date, so a report for 2026-11-01 to 2026-11-21 left out 9,812 of the 10,344 comments created on
the 21st. I found this while comparing the comments report to /comments?search[created_at]=...
Changed Reports::Base#records and added tests in reports_controller_test.rb. Tested locally.
```

This says the same thing:

```
reports: fix reports not including the last day.

Reports only included records from the end date if they were created exactly at midnight. End the
range at the start of the next day instead, so the whole end date is included.
```

## Code style

- Keep it simple. Don't introduce unnecessary abstractions, indirections, metaprogramming, or helper methods. Avoid introducing constants or helper methods that are only used in one place, unless it helps readability.
- Don't add unnecessary comments. Keep comments short and focused on what isn't obvious from the code. Put longer explanations about why a change was made in the commit message, not in a comment.
- Add YARD comments (`@param`, `@return`) to public methods, and update the folder's `README.md` when you change how its code fits together.
- Avoid loops that build up results with mutation. Prefer functional transformations like `map`, `select`, and `sum`, and immutable data instead. A plain loop is fine when it's clearer, like checking each item and raising an error on the first bad one.
- When writing regexes or parsing code, put examples of what the input looks like in a comment next to it, so readers can see what it matches without working it out.
- Use `memoize` for expensive methods that are called more than once, like ones that make HTTP requests. Repeated database queries are usually cached already. Don't memoize values that can change, since then you have to remember to clear the cache whenever they do.
- Avoid `method_missing`, `define_method`, and other metaprogramming that makes code hard to search for.
- Avoid adding methods to core classes (like `String` in `config/initializers/core_extensions.rb`) unless really necessary.
- Use parentheses around method call arguments (`foo(bar, baz)`), but leave them off macro-style calls like `validates :name`, `has_many :posts`, `before_action :foo`, or `assert_equal`.
- Lint the files you changed with `bin/rubocop`, `npx eslint`, or `npx stylelint`. Fix the errors you introduced, but not unrelated errors that were already there.
  - Some rules on this page are checked by custom cops in `lib/rubocop/cop/danbooru`. Don't add files to their `Exclude` lists in `.rubocop.yml` to get around them.

## General

- Don't trust user input. Anything from params, headers, cookies, uploaded files, URLs, or other sites can be malicious. Validate it, and limit its size ([2f37b8773], [bda798258]).
- Ask how a malicious or compromised account at each level (member, builder, mod, admin) could abuse every change you make. See [Security](#security).
- Use the existing helpers for escaping, sanitizing, and URL checks (Rails escaping, DText, `Danbooru::Http.external`, `ExternalCommand`, `local_path`) instead of writing your own ([e18055917]).
- Handle missing data: nil values, empty tables, and deleted users or posts ([584940b12], [19ada3939], [027637401]).
- Rescue only the specific errors you expect. Rescuing `Exception` or `StandardError` and carrying on makes failures disappear silently ([d73895312], [2b8767d7f], [3414d27c7]).
- Log unexpected errors with `DanbooruLogger.log` when you rescue them and carry on, so they don't go unnoticed.
- Test `rescue` blocks and error pages. A bug in the handler hides the original error or crashes the error page ([a1d4408c2], [627e8e101], [ece0b1b17]).
- Normalize the same input the same way everywhere. Use Rails' `normalizes`, and watch for Unicode when changing case ([cf4b86950], [a139d31c1], [057125161], [db7623feb], [21c0d55aa]).
- Don't rely on the current user implicitly. Only use `CurrentUser.user` in controllers and views, and pass the user in explicitly everywhere else: models, components, and service objects. Implicit current users make code harder to understand and test, and background jobs and the console don't have the user who made the request ([361936d5b], [eca4eac5e], [92e4635af]).
- Be careful with Unicode input. Normalize text to NFC before storing or comparing it (most text fields already do this with `normalizes`). Use NFKC only when lookalike forms should count as the same, like wiki page titles. Don't normalize URLs, because servers treat differently encoded paths as different ([cac1b93fa]). Watch out for lookalike, invisible, and zero-width characters, and normalization differences in tag names, usernames, and URLs.
- Don't use `/regex/i` when you expect ASCII input. Ruby does Unicode case folding, so `/s/i` matches `ſ` and `/k/i` matches the Kelvin sign `K`. Use explicit character classes like `[a-zA-Z]` instead.
- Use `[[:space:]]` instead of `\s`, and `VisibleStringValidator` instead of `blank?`. The first two miss Unicode spaces, zero-width characters, and other invisible characters ([03abbd068], [6966b74e1], [d9dc84325]).
- Anchor validation regexes with `\A` and `\z`, not `^` and `$`, which match on any line ([d76d54369], [dcefb842d]).
- Don't assume text from HTTP headers, external programs, file metadata, or decoded URLs is valid UTF-8. Convert it with `encode("UTF-8", invalid: :replace, undef: :replace)` before using it. `force_encoding` alone doesn't fix invalid bytes ([8813970ed], [43a8adbde], [b48161783], [396590321]).
- Use `Date.current` and `Time.zone.now`, which use the current user's time zone, not `Date.today` or `Time.now`, which use the server's time zone ([9ab799ef3]).
- Don't parse dates from user input with `Date.parse` or `String#to_date`. They guess a date from almost any text, so `"1.month.ago".to_date` returns today's date. Use `String#parse_date!`, which raises `Date::Error` for anything that isn't a date.
- Make code work, or fail cleanly, when optional services, API keys, or config values aren't set, as in a fresh install or in tests ([3f35a9ab6], [127e4e385], [4c55c809b], [432b3e19a]).
- Add new config options to `config/danbooru_default_config.rb` with a safe default and a comment explaining them, and read them with `Danbooru.config`, not `ENV`. People running their own instance configure their site there.
- Never commit secrets, `.env` files, or local config like `config/danbooru_local_config.rb`.
- Don't add a gem or npm package for something existing code or the standard library already does, or that would only take a few lines of code to write ourselves.
- Do add a gem when it would be less work to maintain than our own implementation.
- Wrap gems in our own classes, like `Danbooru::Http` and `MediaFile`. That way we control the interface, and can handle breaking changes, swap to a different gem, or add missing utility methods in one place.
- Check changelogs for breaking changes before upgrading dependencies. See the `update-dependencies` skill ([999f050dd], [3069db2e5], [0ef8e2dc8]).

## Controllers and API

- Follow the [Security](#security) rules for every action: use `authorize` and `permitted_attributes`, hide the same things in the API as in HTML, don't redirect to user-supplied URLs, and rate limit write and expensive read endpoints.
- Test every new action with each relevant user level. It should work for the levels that can use it, and be denied for the levels that can't.
- Use RESTful routes and the standard actions (`index`, `show`, `create`, `update`, `destroy`) instead of custom actions.
- Make helper methods in controllers private. Rails treats public methods as actions, and `protected` doesn't apply inside `concerning` blocks ([63eb593ae]).
- Use `respond_with`, so the action works as HTML, JSON, and XML like every other page.
- Add search params through the model's `search` method and the `Searchable` helpers, so they work like every other search.
- Handle bad search params the same way everywhere:
  - Return a 422 error for malformed values that can't be parsed, like `search[is_deleted]=abc`, `search[name][x]=1`, or an invalid date. Say what's wrong in the error message. Never ignore a filter you can't parse. That returns more results than the user asked for, which can make an API script act on the wrong records ([2edaaf716], [f15c285dc]).
  - Return no results for well-formed values that don't match anything, like a user or tag that doesn't exist. Don't skip the filter ([7a7bebd02], [ad22e42e6], [be27423af], [3691404a8]).
  - Ignore unknown params, so old clients keep working when params are renamed or removed. Options that only change how results are displayed, like a report's chart mode, can fall back to their default.
- Expect any param to be a string, an array, or a hash (`?id[]=1`, `?id[x]=1`), including params read in model `search` methods and `*_matches` scopes. Check the type before calling string methods on it, and test actions with array and hash values.
  - Check types with an allowlist, like `value.nil? || value.is_a?(String) || value.is_a?(Integer)`, not by rejecting arrays and hashes. JSON request bodies can also contain booleans and floats.
- Use `params.expect(:post_id)` for required scalar params, and pass the record to constructors (`post: Post.find(...)`), not the ID (`post_id: params[:post_id]`). `Model.find` returns an array when it's given an array, and an ID that doesn't exist leaves a nil association that crashes later.
- Handle bad or missing params in every action, and return the right 4xx error, not a 500: 400 for malformed params, 404 for records that don't exist, and 422 for records that fail validation. Raise `ActionController::BadRequest` for malformed params in controllers; only `Searchable` raises `Searchable::SearchError`. Slice the keys you expect instead of passing `search_params` straight into a constructor ([990bc2345], [cecb0990e]).
- Test HEAD requests, `.json`, `.xml`, and unknown extensions, not only HTML GETs. Keep the format when redirecting, and only set flash notices for HTML responses ([1292e7393], [35dfc704b], [99a1a408c], [43e84a043]).
- Don't change state on GET requests. Use POST, PUT, or DELETE, so links and `<img>` tags can't trigger the action ([08a784f78]).
- Check that the JSON and XML API return the same records as the HTML page ([788c372cd]).
- Test new API attributes and associations with `only=`, including nested associations that are empty or nil ([b7a1747cd], [65dbfcf55], [3312030ce]).
- Truncate flash notices and other session data that contain user content. Session cookies are limited to 4KB ([814947b33], [4e1a8cda9], [82c08c9fa]).
- Write error messages that tell users what went wrong and what to do about it, not just "invalid".
- Make error pages and early callbacks work without `CurrentUser.user` or the database ([5f56d9cd8], [0d69c0324], [87115a479]).
- Add an `id:` constraint to routes whose IDs are names (wiki titles, tags, IPs). Otherwise Rails reads anything after a dot as the format ([a653513e0]).

## Models and database

- Don't interpolate values into SQL strings, even ones you think are safe. Use `where` with a hash or bind params, `where_like`/`where_ilike` from `Searchable` for `LIKE` patterns, and Arel for subqueries and `ORDER BY` instead of interpolating `to_sql` ([4fb2894f0], [5c0b3557d]).
- Preload associations used in views to avoid N+1 queries ([c2da8e485], [de6f386e9], [808fe0411]).
  - Avoid association lookups in policies. These may run once for every record on the page, so a lookup there is an N+1 query everywhere the policy is used. If you must add one, find every caller of the policy, preload the association, and check the queries on each of those pages and API endpoints ([a0638daf1]).
- Use `with_lock` (or `locked_update`) to lock records before reading, modifying, and writing them back, e.g. when appending to an array or string column. Otherwise concurrent edits can overwrite each other ([31b58e17b], [80e115b60], [06e12973e]) or both get past the check ([f286cb003], [5110b4bfa], [f0a593609], [e72446463], [a1ae09a18]).
  - Use `with_lock`, not `lock!`, outside a transaction. `lock!` doesn't lock anything without one ([7a24d08bb]).
  - Lock multiple rows in a consistent order with `order(:id).lock`. Otherwise concurrent transactions can deadlock ([aeb5edaff]).
  - Check preconditions inside the lock, not before it ([651dfc095]).
- Put permission checks in the policy, and call it from the controller, where the current user is known. Avoid permission checks in models, which shouldn't depend on who the current user is. Make sure every path that changes the record goes through the policy, including the API, metatags, reverts, undeletes, and bulk edits ([0006b76c4], [fb91bbc6c], [7726e85e3], [96a468b51]).
- Pass the current user in explicitly, to `visible`, `search`, and everything else. Don't use default arguments that silently fall back to the current user. For example, use `system_tag_match` for internal post searches, not `user_tag_match`, which depends on the current user's settings ([92e4635af], [ce0550569]).
- Don't use `update_attribute`, `update_column`, or `update_columns` for user changes. They skip validations and callbacks, so they skip lock and permission checks too ([010008eab], [07921d2c8]).
- Consider the performance of queries on large tables. Queries that are fast in development can time out in production ([99416d47b], [d34592650], [5f6fc9f3e]).
- Use `find_each` to iterate over large tables, not `.all.each` or `.map`.
- Use `exists?` on relations that aren't loaded yet, and `size` or `present?` on relations that are. `exists?` and `count` always query the database again.
- Update cached counts (`*_count`, `has_children`) on every code path that changes them, including delete, undelete, expunge, and bulk updates. Use `update_counters` or SQL increments in the same transaction, not read-modify-write in Ruby ([5baeb3eec], [69facb22b], [1ec02dbe4], [e8b92781c]).
- Recompute derived flags and limits (`is_banned`, upload limits) from the source records on every change, not in one place ([0d03e7c5c], [0b3d95c73], [1d5bb39cc]).
- Don't keep database transactions open during slow work, like HTTP requests, external commands, file processing, or updating many records. Long transactions hold locks that block other requests, and can deadlock ([463e6d7b4]).
- Remember that Rails saves records and runs their callbacks inside a transaction. Once the row is written, other writes to it are blocked until the transaction commits, so slow work in callbacks holds that lock and can cause deadlocks. Before the row is written, other writers aren't blocked, so lock the record explicitly if it mustn't be changed concurrently.
- Use `after_commit`, not `after_save` or `after_destroy`, for side effects that can't be taken back, like sending emails, deleting files, or calling services. Otherwise they happen even if the transaction rolls back ([b27f98dc5], [8fff3315f], [88d14b30e]).
- Don't create a new version or change `updater_id` when nothing changed ([4b635628c], [bb5f29111], [160829d26]).
- Don't set `updater_id` or `*_ip_addr` with `||=`. A default or the previous value may already be there, so the edit gets credited to the wrong user ([feb3ec075], [02122343c], [3dc854c0c]).
- Add `id` as a tiebreaker when sorting on a non-unique column. Otherwise rows come back in random order and pages overlap ([d74eda2b9], [6ad774b93], [57c4d2a54], [5ea61c692]).
- Qualify column names in raw SQL strings (`where("created_at > ?")`, `order("id desc")`) with the table name, or use hash syntax. Bare names become ambiguous when the query is joined ([ad3f3fdce], [638696235], [49d18e64e], [120434bb9]).
- Watch out for string vs. symbol keys in JSON columns. Hashes loaded from the database have string keys ([0ef8e2dc8]).
- Use `PostQuery#posts_with_timeout` for post searches embedded in other pages (wiki, artist, or profile previews), so a slow search doesn't time out the whole page ([e5b2adc37], [461da6505]).
- Check self-referencing data (parent posts, implications, nested extractors) for cycles and unlimited depth. Check the whole chain, not only direct self-references ([1183341a4], [6fdc41a1b], [365e04b5f], [fde15d979]).
- Add a maximum length validation to every string and array attribute users can edit ([58e471948], [02ba1e37b], [c3f834f79], [46027e9eb]).
- Only run validations when the attribute changes, with `if: :name_changed?`. Otherwise old records that don't pass a newer validation can't be saved at all, and slow validations like uniqueness checks run on every save.
  - For required attributes, use `if: -> { new_record? || name_changed? }`. A blank attribute on a new record doesn't count as changed, so `if: :name_changed?` skips the validation, and saving fails with a database NOT NULL error instead of a validation error.
- Guard validations and callbacks that use an association with `if: :post`. `belongs_to` adds a "must exist" error when the association is missing, but the other validations still run, and crash on the nil association.
- Remember that `!=`, `NOT IN`, and `where.not` don't match rows where the column is NULL. Add `OR col IS NULL` when those rows should match. Also, `where.not(a: 1, b: 2)` means NOT (a AND b), not (NOT a) AND (NOT b) ([65dbd89e2]).

## Database design

- Index new columns and tables for how they'll be queried: foreign keys, columns you search, filter, or sort by, and columns you query together. Think about the queries before you design the table.
- Don't add indexes blindly. Every index slows down writes and takes up space, so don't index columns nobody will search, and remove indexes that aren't used ([766113a44]).
- Be careful about indexing columns that change often, like counts, scores, and `last_*_at` timestamps. Writes to indexed columns are more expensive than writes to unindexed ones, because Postgres can't do a HOT update, and has to update every index on the table, not only the one for that column. This is most expensive on tables with many indexes, especially GIN indexes on arrays.
- Pick the right type of index. Use btree for exact matches, ranges, and sorting. Use GIN for arrays (`post_ids`, `other_names`) and `jsonb`, a `to_tsvector` GIN index for full-text search, and a trigram index (`gin_trgm_ops`) for wildcard searches on short text like names and URLs ([d84201273], [4066ee52b]).
- Don't put btree indexes on free-form text like comments, descriptions, or error messages. They don't help search it, and Postgres can't index values over about 2700 bytes, so long values fail to save ([6f3f92088]). Use a full-text index if the text needs to be searchable.
- Use partial indexes (`WHERE is_deleted = false`) when queries only look at a small part of the table, like rows where a flag is set.
- Make expression indexes match the query exactly. An index on `name` doesn't help `lower(name) = ?`; you need an index on `lower(name)`.
- Put the columns you match exactly first in multi-column indexes. An index on `(a, b)` also works for queries on `a` alone, so don't add a separate index on `a`.
- Back uniqueness rules with a unique index, not only `validates :uniqueness`. Two requests can both pass the validation and save duplicates ([345a22216], [9efa52142]).
- Add a foreign key to every column that references another table (see [Migrations and deploys](#migrations-and-deploys) for how to add one safely).
- Use a `status` column instead of several boolean flags (`is_pending`, `is_deleted`, `is_banned`) for the states a record moves through. Flags allow impossible combinations, like pending and deleted at once, and each new state needs another column.
- Make columns NOT NULL with a default when they always have a value, especially booleans. A nullable boolean has three states, and queries forget about the third.
- Use real columns, not `jsonb`, for data you search, filter, sort, join on, or validate. Keep `jsonb` for extra data that's only read back as a whole.
- Use a join table for relationships that need their own data, foreign keys, or history. Arrays are fine for small lists like pool post IDs or other names, but Rails can't join on them easily.
- Give enums explicit integer values, and never renumber or reuse a value. The integers are what's stored in the database. Leave gaps between values (e.g. 0, 100, 200) so new values can go in between later.
- When you store new user data, decide who can see it, and handle it in `UserDeletion` so it's removed or anonymized when the user deletes their account.

## Migrations and deploys

Deploys are rolling restarts, so the new code will be running alongside the old code for a short time. Betabooru may also be running newer code than production. Code is deployed before migrations are run, so it must not depend on migrations that haven't run yet.

- Don't use a new column in the same deploy that adds it. Add the column and `self.ignored_columns += [:col]` in one commit, and start using it in a later commit, after the migration has run in production ([cbaaf2694] → [133531bb5], [0001d6b55] → [b891b8015]).
- Drop columns in steps: stop using the column and add it to `ignored_columns`, deploy, then drop it in a later migration ([2dfec29da] → [7c63ac8db]).
- Rename columns in steps: add the new column, copy the data, switch the code over, then drop the old column.
- Keep schema changes on busy tables (posts, users, tags, media assets) in short migrations of their own. `ALTER TABLE` waits behind running queries for a lock, then blocks every query behind it.
- Don't write migrations that will lock busy tables for a long time.
  - Add and remove indexes with `algorithm: :concurrently` and `disable_ddl_transaction!`, so they don't lock the table. Use `if_exists:` or `if_not_exists:` too ([8ed2c4f0b]).
  - Use `add_not_null_constraint` from `MigrationHelpers` to make an existing column NOT NULL, not `change_column_null`, which locks the whole table while it scans it ([c72ee9edd], [d27cab65b]).
  - Add foreign keys with `deferrable: :deferred` and an index on the column. On large tables, add the key with `validate: false` and validate it in a separate migration ([5623b139a]).
- Don't use app models or classes in migrations. Use SQL, or define a small model inside the migration. Later changes to the app's classes break old migrations ([f6a96c632]).
- Put data backfills and fixes in `script/fixes/`, not in migrations. Make them dry-run by default, with `FIX=true` to actually write, and put the command to run in the commit message ([96085f17d]).
- Make migrations reversible. Use `change`, or `reversible` with an explicit `down` for raw SQL.
- Make migrations safe to rerun if they fail halfway through, and tell the user what to do if manual steps are needed ([c72ee9edd], [d27cab65b]).
- Commit the `db/structure.sql` generated by `bin/rails db:migrate` together with the migration. Don't edit it by hand ([a2690dcb4]).
- Use a stacked pull request for changes that need a migration, with each deployment stage in its own pull request.

## HTML

- Don't pass user-controlled input to `html_safe`, `raw`, or `innerHTML`.
- Use ViewComponents (`app/components`) for reusable pieces of HTML, not partials or presenter classes (`app/presenters`).
- Use SimpleForm for forms.
  - Keep the user's input when a form fails validation. Re-render the form with the values as typed and the error shown ([f52003f12], [fbf96d111], [0f36a3152], [f942768ce]).
- Don't use inline `<script>` tags. See [XSS, open redirects, and unsafe URLs](#xss-open-redirects-and-unsafe-urls).
- Use `href="#"` with `.prevent` or `preventDefault`, not `href="javascript:void(0)"`, which breaks the CSP ([cf1a82a3b]).
- Use semantic HTML: `<a href>` for navigation, `<button>` for actions, and `<label>` for form fields.
- Don't add `id`s to elements unless you have to. Use classes instead. IDs break in components that render more than once per page, and once they exist, it's hard to tell what Javascript, CSS, or userscripts depend on them. Use `namespace:` on forms to keep their field IDs unique ([e4096460e], [f7f72e29b], [804a2ef9a]).

## Javascript

- Add system tests (`test/system`) for any Javascript functionality you add or change.
- Use Alpine.js for client-side interactions. Avoid adding new jQuery code, though `$(...)` is fine for selecting and traversing the DOM.
- Keep logic out of Alpine attributes (`x-data`, `@click`, `:class`), and put it in `Alpine.data` components or magics. We use Alpine's CSP build, which can't evaluate arrow functions, `?.`, `new`, regexes, globals like `Danbooru.*`, or assignments to DOM properties, and doesn't support `x-html` ([28cdd0599], [975cf9609], [1fd18d470], [a90b4fba2], [bdd6ae766]).
- Test UI changes on mobile, including touch and swipe gestures ([64a8719e0], [f425fa7ce]).
- Test that errors are handled properly. Don't show `[object Object]` to the user ([6d62e3e48]).
- Don't use newer JS features that old mobile browsers don't support, like regex lookbehinds ([1ff98b41a], [fb13ffdd9]). Syntax that old browsers can't parse breaks the entire Javascript bundle, not just one feature.
- In click handlers, use `this` or `e.currentTarget`, not `e.target`, which may be a child element inside the link ([095f8f444]).
- Let ctrl+click, middle click, and other modified clicks on links work normally. Only cancel plain left clicks ([9d301b827], [4a7d2f337], [c4e47e46c], [1b540c4c2]).
- Make keyboard shortcuts ignore keys pressed with ctrl, alt, or meta, so they don't override browser shortcuts ([a62eb7704]).
- Don't use selectors that user content might match (e.g. `a[rel~=next]` used for navigation). Check that DText and the user-written HTML in notes can't produce matching elements ([5b61bbd1c]).

## CSS

- Use the Tailwind-style utility classes in `app/javascript/src/styles/common/utilities.scss` to style HTML, like `flex items-center gap-2`, not new CSS rules. They use the same names as Tailwind, so the Tailwind docs explain what each one does.
- Don't add new CSS rules unless you can't do it with utilities. Global rules are hard to maintain, because it's hard to tell where they're used and what will break if they change. Put a component's CSS in the `.scss` file next to the component.
- Don't add new utility classes unless the existing ones can't do what you need. If you do add a utility class, give it the same name and behavior as the Tailwind class.
- Use the color variables from `040_colors.scss` (`var(--link-color)`), never hardcoded colors, so every theme works. If you add a new variable, define it for each theme, and check your change in dark mode ([8dca5cd8e]).
- Use the `sm:` and `md:` utility variants for mobile layouts, and check your change on a narrow screen.
- Use the Tailwind-style spacing classes for padding, margins, and sizes, not made-up values. When you have to write CSS, use `rem` units in multiples of `0.25rem`.
- Avoid inline `style=` attributes, and style with classes, not `id`s.

## Background jobs

- Don't do slow work like HTTP requests, processing files, or large database updates during a web request. It ties up a worker thread, and enough slow requests at once make the site unresponsive. Move the work to a background job when you can. When the user needs the result right away and a job won't work, keep it fast and give it a short timeout.
- Set the job's priority with `queue_with_priority`, relative to the existing jobs listed in `ApplicationJob`. Work users are waiting on, like uploads, goes first; maintenance goes last.
- Override `job_timeout` with a realistic limit. The default is 24 hours ([7a1f08b95]).
- Retry temporary errors, like network timeouts, with `retry_on ... wait: :polynomially_longer, attempts: N`. GoodJob doesn't retry other errors automatically ([ad2e003d7], [6bd77d983]).
- Avoid long-running jobs. Redeploying the site kills jobs that are still running, so split large work into smaller jobs.
- Avoid scheduling jobs to run far in the future. The job runs against whatever code is deployed at the time, so if its arguments or the methods it calls have changed by then, it fails.
- When you change a job's arguments, keep accepting the old ones for one deploy, and give new arguments defaults. Old servers keep queueing jobs with the old arguments during the restart. To remove a job, stop queueing it first, and delete the class in a later deploy.
- Make jobs safe to retry or run twice. A retried job may find its work half done.
- Pass records or IDs to jobs, not large amounts of data.
- Pass the acting user to the job when it matters. Jobs run as `User.system`, not as the user who queued them.
- The record may change by the time the job runs. Don't assume that it hasn't been edited or deleted. Re-check the record's state when the job starts, and anything else it depends on, like the posts in a pool ([e05d8d173]).
- Save the failure when a job fails, so records don't get stuck in a "processing" state. Make sure this works even when the error itself is huge or saving it fails ([6f3f92088], [9430e6505], [c584ca5b1], [87a00a118]).
- Add `ApplicationMetrics` counters for new background processes and external services, so you can see when they fail.

## Files, HTTP, and external commands

- Make all HTTP requests through `Danbooru::Http`, and fetch user-supplied URLs with `Danbooru::Http.external`. See [SSRF and outgoing requests](#ssrf-and-outgoing-requests).
- Give every external command and HTTP request a timeout, and make sure each step of a multi-step process gets the right one ([d972b0b32], [7a1f08b95]).
- Don't fork child processes. The app is multithreaded, and forking a multithreaded process can deadlock the child. Run programs with `ExternalCommand`, which uses `Process.spawn` ([777893bb9]).
  - In code that runs after a fork anyway (like Puma workers or parallel tests), don't close or delete resources the parent process still uses ([520f54d77], [d2018b04e]).
  - Use `wait_for_fork` with a timeout in tests that wait on forked processes, so a hung child doesn't hang the whole run ([777893bb9]).
- Check the status and content type of external API responses before parsing them. Deleted posts, 429s, and HTML error pages are common ([be721db44], [bdb08b780], [00531dd2c]).
- Keep private user data (IPs, API keys, email addresses) out of emails, logs, and metrics unless it's needed ([a6844e9c3], [6c9f5809b]).
- Give every cache entry an expiry, and don't push it back every time the entry is read ([442515029], [3af352c76]).
- Don't cache temporary errors like 429s, or fallback values as if they were real results. Do cache slow failures like timeouts, so every page load doesn't hit them again ([d281252e4], [f85eef9bc], [f0a5dc35f], [2e0ad42ec]).
- Keep values that change on every call, like tokens or credentials, out of cache keys ([a36ae3984]).
- Change the cache key when you change the format of a cached value. Old and new code share the cache during a deploy, and old entries stay until they expire.
- Close files you open. Use the block form of `File.open` and similar methods ([79923344d], [cbc3b4877], [570d6a9d0]).
- Write files to a temp path and then rename them into place, so readers never see a half-written file ([42afe48d9]).
- Delete temp files when an error happens partway through, not only on success ([55e84426b]).

## Tests

- Test the unhappy paths. Test that users who shouldn't have access are denied, and test hostile input: huge, deeply nested, empty, multi-line, Unicode, and special characters.
- Test visible behavior and the interfaces at the edges, like controller endpoints or a class's public interface. Don't test implementation details, like the number of queries a page does or whether an internal method was called. Those tests break when you refactor without catching real bugs.
- Prefer functional tests (`test/functional`) over unit tests when you can. They test the whole request from end to end, and they define the behavior users actually see.
- Write unit tests (`test/unit`) for a class's public interface, not for internal methods that only the class itself uses.
- Test model validations in unit tests (`test/unit`), including the error message for each invalid value.
- Add system tests (`test/system`) for any Javascript functionality. Functional and unit tests don't run Javascript.
- Use one test file per class, e.g. `test/unit/artist_test.rb` for `Artist` and `test/functional/artists_controller_test.rb` for `ArtistsController`, and one system test file per page or component.
- Keep tests simple. Avoid loops and layers of abstraction, and repeat the same assertions when needed. Only add a new assertion helper if it will be used in many places, not just a few.
- Check that a new test fails without your change. Revert the fix or invert the condition, and run it again.
- Don't delete or skip a failing test because you can't fix it.
- Use FactoryBot (`create(:user)`) to create records in tests.
- Keep tests fast. Don't create large numbers of records, and avoid slow work like reading files or hashing passwords in factory methods ([9db78c4ed], [4fdef8393]).
- Keep files in `test/files` small, and note where each one came from in the folder's `README.md`. Files are stored in the git history forever even if they're removed from git.
- Don't hardcode record IDs, because parallel tests collide. Make sure random Faker values pass validations, like public IPs for IP bans ([d1caa7d66], [e38c959da]).
- Use `travel_to` instead of depending on the current date or time zone ([9ab799ef3]).
- Don't memoize stubbed objects at the class level. They leak into later tests and cause random failures ([f08f57907]).
- Test post search metatags in combination, not only one at a time. An order plus `random:`, `ordfav:` plus other metatags, duplicates, and `or` can fail when each works alone ([174c8e006], [9867514a7], [659f8a6e9]).

## Source extractors

See [test/unit/source/README.md](test/unit/source/README.md) for how to test URL parsers and extractors.

- Return nil or empty values instead of raising exceptions in extractors and URL parsers, whether data is missing, a request fails, or the URL doesn't match. Remember the `else` in `case` statements ([339dde092], [bb831d2b7], [1b0e094b0], [9651eba71], [02d99af7e]).
- Parse every URL format the site uses, not only the one you were given: full-size images, samples, thumbnails, videos, page URLs, profile URLs, short links, and other subdomains and CDNs.
- Keep support for old URL formats when a site changes. We still have to parse them in existing post sources and artist URLs.
- Check `/artist_urls` and `source:` searches for real URLs, and other projects like gallery-dl and Image Max URL for formats you missed. Don't copy their API keys ([57931c9e3]).
- Rewrite sample images into full-size URLs, and strip resize params. Mark real samples with `image_sample?` ([c135a6a0a], [688065591], [f7cc970c5], [c210ba058]).
- Don't make HTTP requests or database queries in `Source::URL` classes. Parsing a URL must be fast and work offline. Do lookups in the extractor.
- Only return data for the given URL itself. Don't extract data recursively from quoted, reblogged, or parent posts ([e28b403fb], [fde15d979]).
- Use the extractor's `http` and `parsed_get` instead of creating your own HTTP client. They block local IPs, cache responses, track credentials, and return nil on failure.
- Use site credentials instead of hardcoding API keys, cookies, or tokens ([57931c9e3], [e32e7af6f]).
- Use `Danbooru::URL.escape` instead of `CGI.escape`, and `String#parse_json` instead of `JSON.parse`. `parse_json` returns nil on invalid JSON instead of raising an exception.
- Handle deleted, private, age-restricted, followers-only, and redirected posts ([00531dd2c], [e6542eba7], [b34aa3d04], [2b2af84c9]).
- Only mark URLs as `bad_source?` or `bad_link?` when you're sure. Return nil when you aren't ([af35ec930], [6325e9d26], [e925d8538], [edd4e4691], [fde20e439]).
- Generate full extractor test cases with `.test_case`, and cover the cases listed in the source tests README. Don't add half-finished tests.
- Convert commentaries to DText with `DText.from_html` in `dtext_artist_commentary_desc`, not by hand, and normalize whitespace and URLs ([c42e139e7], [dd9dfd3b5], [5ec0124da]).
- Memoize API responses, and avoid unnecessary requests and redirects ([7ac15b980]).
- Skip tests that need credentials when the credentials aren't set, instead of letting them fail ([27b75a205]).
- Add the site's logo when you add a new site.

## DText parser

The DText parser is a C++ Ruby extension in `lib/dtext_rb`, generated from a Ragel grammar. See [lib/dtext_rb/README.md](lib/dtext_rb/README.md) for how to build and test it.

- Edit `dtext.cpp.rl`, not the generated `dtext.cpp`. Rebuild with `bin/rake compile` and run `bin/rake test` in `lib/dtext_rb` after every change.
- Keep existing DText working. There are millions of comments, forum posts, and wiki pages written in it. Test every change to the grammar or pattern rules against a dump of all DText on the site with `lib/dtext_rb/bin/test-dtext`, and make sure the amount of changed output is acceptable.
- Build with `DTEXT_DEBUG=true` when you change C++ code. It turns on the undefined behavior and leak sanitizers and the standard library debug checks.
- Don't write rules that scan ahead looking for a closing tag, then backtrack when they don't find one. Many unclosed tags make parsing quadratic.
  - Test large amounts of repeated unclosed tags, and check `bin/rake bench` ([3ebff34b4], [8ece9bcc5], [fc95d7585], [ea6d799de]).
  - Test long runs between other text too (`"a" + " " * n + "b"`), not only on their own. A run that fills the whole input can take a different, fast path.
  - Watch out for Ragel's `space` class. It also matches `\r`, `\v`, and `\f`, which DText's `ws` doesn't, so a rule using `space*` can read through text that other rules split into many tokens.
  - Build with `DTEXT_COUNT_WORK=true` and check that `DText.work` per byte stays the same as these inputs grow. It counts the parser's work exactly, so superlinear growth shows up even at a few KB (see [lib/dtext_rb/README.md](lib/dtext_rb/README.md)).
- Reset the match marks (`c1`, `c2`, and so on) for optional parts of a token. Otherwise they keep positions from an earlier failed match ([692355592]).
- Don't use recursion on user input.
- Use a nesting limit when parsing HTML. Deeply nested HTML is slow or crashes the code that processes it afterwards ([1682ad927], [a889cc6a6]).
- Escape everything you output with `append_html_escaped` or `append_uri_escaped`, and be careful when classifying links as internal or external ([6d99f50ee]).
- Don't raise Ruby exceptions (`rb_raise`, `StringValue`, `Check_Type`) while C++ objects are alive. Ruby exceptions use `longjmp`, which skips C++ destructors and leaks memory. Raise C++ exceptions as Ruby exceptions only after the C++ stack has unwound, like `rescue` in `rb_dtext.cpp` does ([67bfecd74]).
- Keep the input checks in `rb_dtext.cpp`. The parser assumes the input is valid UTF-8 with no null bytes, because it uses null bytes to mark the start and end of the text.
- Keep per-call work small. DText runs on almost every page, so converting large Ruby objects to C++ on every call adds up ([4d807c399]).

## Security

Security bugs we've fixed before. This list doesn't cover everything, only the most common patterns. To report a vulnerability, see [SECURITY.md](SECURITY.md).

### Authorization and visibility

- Permission checks use `policy` and usually go at the edge of the application inside controllers, not inside models.
- Use `authorize` and `permitted_attributes` in every controller action to check that the current user has permission to perform the action (see `app/controllers/README.md`).
- Use `visible` in both `index` and `show` actions to check that the user can view the item ([37b43a702], [b8aa223ec], [28d2753c5], [16d27c0c0]).
- Use `permitted_attributes_for_create` or `permitted_attributes_for_update` to allowlist which attributes the user can set. Don't include attributes that users shouldn't set, like owner, level, status, or another record's ID ([8df1496d2], [a16b91e2b], [3da90ca25]).
- Check saved values in policies (`is_deleted_was`), not new ones. Some controllers assign the request's attributes before calling `authorize`, so the policy sees the value the user is trying to set ([551f29b7e]).
- Check `unbanned?` in policies for write actions, not only the user's level. Banned users below Moderator keep their level, and should only be able to change things that affect themselves ([89bffbe87], [105553a1d], [6c6931399], [2537145b0], [954370be6]).
- Check the parent record in policies when creating child records, not only the child (e.g. check that the user has permission to view or edit the post when creating comments, notes, flags, etc.). In views, call `policy(Model.new(post: post))`, not `policy(Model)` ([37b43a702], [25978ca75], [835cc23f6]).
- Hide child records whose parent the user can't see, like BURs in private forum topics, or the replaced files of hidden posts ([03f1c9cb3], [a0638daf1]).
- Check that the user has permission to update every record you change as a side effect (metatags, callbacks, bulk actions) ([9282fd968]).
- Hide soft-deleted records on every path that can reach them, not only the index: show pages, the API, votes, quotes and replies, metatags, and DText links ([7f8a6adb0], [ccb38a5bc], [20cc2cd18], [d5ae2b1bc]).
- Scope records loaded by ID params other than `:id` (`version_id`, `respond_to_id`) through the parent, e.g. `@artist.versions.find(...)`, or authorize them separately. Don't use a global `Model.find` ([c46b31aa9], [4eb0a6413]).
- Check the right level for admin, mod, and owner-only features, and hide staff-only info in the API too ([bab611d78]).
- Don't let staff see or change private data of users at their own level or higher ([87ac52578], [c795ba054]).
- Don't let edits to another user's content trigger actions as that user, like sending mention dmails as the author ([c8debfb81], [b5d602836]).

### Info leaks through the API and search

- Don't forget to hide content everywhere it appears. Check the API, the HTML, `<meta>` and `og:image` tags, `data-*` attributes, Atom feeds, sitemaps, version histories, `dtext_links`, thumbnails on other pages, and BigQuery dumps ([9893dc173], [efc5487dd], [f0a573e1e], [34c3df78d], [4320e2ef7], [b169d60f6]).
  - Hide the same things in the API as in the HTML. Check `api_attributes` and `respond_with(..., methods: ...)` when you expose attributes or methods ([3efac206a], [146222286]).
- Don't accidentally leak hidden data.
  - Don't leak hidden data in exceptions. Only show users the messages of known exception types. `NoMethodError` messages can include a whole `User` or `Post`, and database errors can include other users' data ([7bed81812], [b695c4ccb], [d053e135a], [80e0ae6a3]).
  - Don't leak private details (IPs, private reasons, private topic titles) in public ModAction descriptions. Add the category to `ModAction::MOD_ONLY_CATEGORIES` instead of filtering the text in `serializable_hash`, which `only=` gets around ([6c6916578], [3d03de1c5], [a8799b1ae]).
  - Don't leak the number of records the user can't see in counts and aggregates (`*_count`, `has_*`, reports that group or aggregate records) ([899798431], [a442658f8], [9e86282f0], [bc4b7c4fb]).
  - Don't send notifications (dmails, mentions) with content the recipient can't see ([c7a47cadf]).
  - Don't allow hidden data to be inferred through searches, such as by partial matches on hidden attributes (`_like`, `_regex`, wildcards, ranges) that allow them to be found one character at a time ([db60981eb], [8ce870da5], [dedd509dd]), or by allowing searches on private attributes (`creator_id`, `user_id`, `ip_addr`, etc.) that can be used to infer hidden data, e.g. who flagged a post ([b46400bac], [899798431], [a442658f8]).
  - Don't allow hidden data to be inferred through side channels or timing attacks, such as differences in response time, rate limits, or error codes that reveal whether an account or email address exists ([fa39094da], [92c5f9a64]).
  - Don't reveal the existence of hidden data, like email addresses or private forum topics, through error messages or differences in HTTP responses, including timing. Authorize before looking up the hidden data ([1af7bf6fb]).
    - Look up parent records through `visible`, like `ForumTopic.visible(user).find(...)`, so a hidden record gives the same response as one that doesn't exist.

### XSS, open redirects, and unsafe URLs

- Don't allow XSS in HTML. Don't pass user data to `html_safe`, `raw`, `<%==`, `.js.erb` responses, `x-html`, `innerHTML`, or jQuery's `.html()` ([37e13e1b5], [02c7c90a8], [0e7349ca4], [c1371eb0a], [fce8dcc97]).
  - Don't allow XSS in HTML attributes by allowing things like `onclick=` handlers in tags.
- Don't allow XSS in links. Don't allow user-controlled URLs (e.g. `javascript://<host>/%0Aalert(1)`) in `href` or `src` attributes. Use `local_path` from `ApplicationController` or don't take a URL param at all ([b35d108df], [5465c20cb], [0f768d144]).
  - Don't pass raw request params to `url_for` or `link_to`. Rails treats `protocol`, `host`, and `script_name` as URL options, which gives the user control of the link ([f461b0996], [84a0a89f4]).
- Don't allow open redirects. Don't allow user-controlled URLs in `redirect_to`.
- Don't relax the CSP in `config/initializers/content_security_policy.rb` without a good reason ([e0f459e26]). Any allowed host can log users' IPs, or be used to exfiltrate data through HTTP requests. This includes `img-src`, `style-src`, `font-src`, and `connect-src`.

### Code injection and unsafe deserialization

- Don't call `send`, `public_send`, `constantize`, or `render` with user input. Write out the allowed calls instead (`type == "current" ? current : previous`), so it's obvious at the call site that nothing else can be called, even if the input was checked earlier ([c944ba4f8], [90b2a2c4f]).
- Don't deserialize untrusted data with `Marshal` or `YAML.load`. Use `YAML.safe_load` if you must, and cache plain strings and hashes, not Ruby objects ([42fb81ffd]).

### Authentication, sessions, and 2FA

- Require reauthentication (`before_action :requires_reauthentication`) before sensitive account actions like changing emails or passwords, deactivating the account, viewing API keys, enabling 2FA, etc, and before staff actions that a hijacked session could abuse, like banning, promoting, or demoting users. Logging in doesn't count as reauthentication ([b0f4d573c], [5a7966336], [9fb2e4911], [111a24184], [b59586203]).
- Don't add `skip_before_action :verify_authenticity_token` ([f1e31868d]).
- Rate limit sensitive account actions like login and 2FA attempts, including on reauthentication paths ([d72623abd]).
- Bind tokens, signed links, and sessions to the user, session, and current email or password, so they stop working when any of those change ([e3ee3b1cd], [7ad1b8717], [9548dad16], [d7cdd3f19], [18503fcf0]).
- Build tokens with `signed_id`, `MessageVerifier`, or `generate_token_for`, not from guessable or private data ([73219f38c]).
- Compare secrets and signatures with `ActiveSupport::SecurityUtils.secure_compare`, not `==` ([a029b71ce], [73219f38c]).
- Don't change a user's account from a link without `authorize`, unless the link is signed with a real secret ([e25c00ef5]).
- Record sensitive actions performed by users, like logins and password, email, or 2FA changes, as a `UserEvent`.
- Record sensitive actions performed by moderators with `ModAction.log`.

### Denial of service

- Cap how many items searches and params accept (space-separated terms, URLs, IDs) ([19bbc165d], [2f37b8773], [a219ab393], [a54c15e47], [72d00b7fd], [8f97937dc], [73478613f]).
- Lower the page size limit on pages where each row is expensive to render, like long DText or version diffs. The default of 1000 is too many ([24ea0921e], [802229065]).
- Cap how much output a short input can expand into, like a DText message repeating the same embed hundreds of times, or a URL param with no length limit that's embedded in the page many times ([8d986e4f7]).
- Rate limit every write endpoint, and any expensive or abusable read endpoint, with `rate_limit_for_<action>`, `rate_limit_for_read`, or `rate_limit_for_write` in the policy (see `ApplicationPolicy#rate_limit`). Don't rate limit heavily viewed pages, because checking a rate limit needs a database write ([86f88ac72]).
- Rate limit anything that sends email by the recipient's account, not only by IP, so it can't be used to flood someone's inbox from many IPs. Keep the limit silent, so it doesn't reveal whether the address exists ([8c1ea77fb], [e74afa017]).
- Don't allow anonymous users to use write endpoints, unless they need them, like for logging in.
- Don't write quadratic algorithms or regexes on user text (diffs, DText, tag lists). Watch for nested quantifiers and backtracking, and test with very large or deeply nested input ([f3abe1db5], [3ebff34b4], [2f3d49112], [ee072e323], [4029dfd8e], [fc2242849], [20c42ce8d]).
- Don't make an outbound request or query for each user-supplied item ([2f37b8773]).
- Escape user input with `Regexp.escape` before building a regex from it ([3949338b9]).
- Limit work done in Ruby yourself. The database statement timeout doesn't cover it.
- Reject huge URLs or input before parsing them, or cut them to the longest length that could matter ([bda798258], [b13086a63]).

### SSRF and outgoing requests

- Use `Danbooru::Http.external` (or anything built on it, like extractors' `http`) for user-controlled URLs, including redirects and side requests like fetching the file size. It blocks local IPs with `public_only` / `ValidatingSocket`. `Danbooru::Http.new` and `Danbooru::Http.internal` don't block anything ([a2de525b4], [2f17082e7], [99221e402]).
- Never use `Net::HTTP`, `open-uri`, or other HTTP clients directly. When using non-HTTP network clients (`Net::SMTP`, `Resolv`, sockets), resolve the IP, check `Danbooru::IpAddress#prohibited_for_outgoing?`, then connect to that IP to prevent DNS rebinding ([a2de525b4], [73625ec1c]).
- Limit response sizes on every request, not only media downloads ([439d389b5], [5ad06a403]).
- Pass user input to extractor API URLs as escaped `params:`, not with string interpolation ([00d7c1912]).

### Files, media, and external commands

- Run programs on uploaded files with `ExternalCommand.run`, not `system`, backticks, `Open3`, or `spawn`. It splits the command string with `shellsplit` (no shell), so `.shellescape` every interpolated value. Pass the files the command needs in `read:`/`write:`, and add a `PROFILE` entry for new programs ([1c2545c37], [bd24db65e]).
- Use `File.open`, never `Kernel.open` or backticks, with user data ([9b8d3ac4e]).
- Don't trust file extensions, sizes, or archive contents. Check that contents match the extension, and watch for nested archives, hardlinks, and path traversal ([e54fdf3a9], [5eb147058], [5ad06a403]).
- Restrict programs to the expected file format. Format auto-detection can make them read other files (ffmpeg concat playlists) or formats we don't support (libarchive reading tar as zip) ([da6fa4b7e], [5eb147058]).
- Limit the size of metadata, frames, and decompressed data ([245602601]).
- Decode untrusted files with native libraries in a sandboxed helper script run by `ExternalCommand.run_script`, not in the Rails process. Validate the helper's output too, since a compromised helper can print anything ([cb48619bc], [0b2fd85fa]).

### Caching

- Don't publicly cache responses (e.g. `expires_in ..., public: true`) if they depend on the current user, their level, or their settings (safe mode, blacklist, hidden posts). `skip_session_if_publicly_cached` only drops the session cookie, it doesn't make the content safe to share ([cb63d16a2], [a63662302]).
- Include the user or their level in `Cache.get`/`Rails.cache` keys for data that depends on the user.
- Don't publicly cache error pages, or fallback results from timeouts that depend on the user's level ([a49425e0c], [6f2e0a00d]).

### Secrets and logging

- Don't log secrets or put them in exception messages. Filter new secrets in `config.filter_parameters`, and hide them from `inspect` ([790d585b6]).
- Don't hardcode keys in config defaults ([e25c00ef5]).
- Send API keys to other sites in headers or POST bodies, not in URL query strings, which end up in logs ([9fe61fd9e], [ea32361ed]).
- Don't pass the Rails environment to child processes. `ExternalCommand` only passes `ExternalCommand::ENVIRONMENT` ([fb5fb418c]).
- Restrict Unix sockets and files with sensitive data to the owner ([10a129f53]).

### Build and CI

- Don't check out and run fork code with secrets or write access in workflows triggered by pull requests from forks (`pull_request_target`, `workflow_run`).
- Don't reuse caches written by untrusted builds in images that get deployed.
- Pin base images and verify checksums of downloaded files in Dockerfiles.

## Further reading

- [strong_migrations checks](https://github.com/ankane/strong_migrations#checks): unsafe Postgres migrations and how to do them safely.
- [GitLab: Avoiding downtime in migrations](https://docs.gitlab.com/development/database/avoiding_downtime_in_migrations/): how to drop, rename, and change columns step by step.
- [GitLab: Multi-version compatibility](https://docs.gitlab.com/development/multi_version_compatibility/): why old and new code running side by side matters.
- [Rails Security Guide](https://guides.rubyonrails.org/security.html)
- [OWASP Ruby on Rails Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Ruby_on_Rails_Cheat_Sheet.html)

<!-- Commit links -->

[2f37b8773]: https://github.com/danbooru/danbooru/commit/2f37b8773
[bda798258]: https://github.com/danbooru/danbooru/commit/bda798258
[361936d5b]: https://github.com/danbooru/danbooru/commit/361936d5b
[eca4eac5e]: https://github.com/danbooru/danbooru/commit/eca4eac5e
[92e4635af]: https://github.com/danbooru/danbooru/commit/92e4635af
[e18055917]: https://github.com/danbooru/danbooru/commit/e18055917
[9d301b827]: https://github.com/danbooru/danbooru/commit/9d301b827
[584940b12]: https://github.com/danbooru/danbooru/commit/584940b12
[19ada3939]: https://github.com/danbooru/danbooru/commit/19ada3939
[027637401]: https://github.com/danbooru/danbooru/commit/027637401
[3f35a9ab6]: https://github.com/danbooru/danbooru/commit/3f35a9ab6
[127e4e385]: https://github.com/danbooru/danbooru/commit/127e4e385
[4c55c809b]: https://github.com/danbooru/danbooru/commit/4c55c809b
[432b3e19a]: https://github.com/danbooru/danbooru/commit/432b3e19a
[d73895312]: https://github.com/danbooru/danbooru/commit/d73895312
[2b8767d7f]: https://github.com/danbooru/danbooru/commit/2b8767d7f
[3414d27c7]: https://github.com/danbooru/danbooru/commit/3414d27c7
[a1d4408c2]: https://github.com/danbooru/danbooru/commit/a1d4408c2
[627e8e101]: https://github.com/danbooru/danbooru/commit/627e8e101
[ece0b1b17]: https://github.com/danbooru/danbooru/commit/ece0b1b17
[7a7bebd02]: https://github.com/danbooru/danbooru/commit/7a7bebd02
[ad22e42e6]: https://github.com/danbooru/danbooru/commit/ad22e42e6
[be27423af]: https://github.com/danbooru/danbooru/commit/be27423af
[3691404a8]: https://github.com/danbooru/danbooru/commit/3691404a8
[cf4b86950]: https://github.com/danbooru/danbooru/commit/cf4b86950
[a139d31c1]: https://github.com/danbooru/danbooru/commit/a139d31c1
[057125161]: https://github.com/danbooru/danbooru/commit/057125161
[db7623feb]: https://github.com/danbooru/danbooru/commit/db7623feb
[21c0d55aa]: https://github.com/danbooru/danbooru/commit/21c0d55aa
[cac1b93fa]: https://github.com/danbooru/danbooru/commit/cac1b93fa
[03abbd068]: https://github.com/danbooru/danbooru/commit/03abbd068
[6966b74e1]: https://github.com/danbooru/danbooru/commit/6966b74e1
[d9dc84325]: https://github.com/danbooru/danbooru/commit/d9dc84325
[8813970ed]: https://github.com/danbooru/danbooru/commit/8813970ed
[43a8adbde]: https://github.com/danbooru/danbooru/commit/43a8adbde
[b48161783]: https://github.com/danbooru/danbooru/commit/b48161783
[396590321]: https://github.com/danbooru/danbooru/commit/396590321
[999f050dd]: https://github.com/danbooru/danbooru/commit/999f050dd
[3069db2e5]: https://github.com/danbooru/danbooru/commit/3069db2e5
[0ef8e2dc8]: https://github.com/danbooru/danbooru/commit/0ef8e2dc8
[990bc2345]: https://github.com/danbooru/danbooru/commit/990bc2345
[cecb0990e]: https://github.com/danbooru/danbooru/commit/cecb0990e
[1292e7393]: https://github.com/danbooru/danbooru/commit/1292e7393
[35dfc704b]: https://github.com/danbooru/danbooru/commit/35dfc704b
[99a1a408c]: https://github.com/danbooru/danbooru/commit/99a1a408c
[43e84a043]: https://github.com/danbooru/danbooru/commit/43e84a043
[08a784f78]: https://github.com/danbooru/danbooru/commit/08a784f78
[788c372cd]: https://github.com/danbooru/danbooru/commit/788c372cd
[b7a1747cd]: https://github.com/danbooru/danbooru/commit/b7a1747cd
[65dbfcf55]: https://github.com/danbooru/danbooru/commit/65dbfcf55
[3312030ce]: https://github.com/danbooru/danbooru/commit/3312030ce
[814947b33]: https://github.com/danbooru/danbooru/commit/814947b33
[4e1a8cda9]: https://github.com/danbooru/danbooru/commit/4e1a8cda9
[82c08c9fa]: https://github.com/danbooru/danbooru/commit/82c08c9fa
[5f56d9cd8]: https://github.com/danbooru/danbooru/commit/5f56d9cd8
[0d69c0324]: https://github.com/danbooru/danbooru/commit/0d69c0324
[87115a479]: https://github.com/danbooru/danbooru/commit/87115a479
[a653513e0]: https://github.com/danbooru/danbooru/commit/a653513e0
[0006b76c4]: https://github.com/danbooru/danbooru/commit/0006b76c4
[fb91bbc6c]: https://github.com/danbooru/danbooru/commit/fb91bbc6c
[7726e85e3]: https://github.com/danbooru/danbooru/commit/7726e85e3
[96a468b51]: https://github.com/danbooru/danbooru/commit/96a468b51
[c2da8e485]: https://github.com/danbooru/danbooru/commit/c2da8e485
[de6f386e9]: https://github.com/danbooru/danbooru/commit/de6f386e9
[808fe0411]: https://github.com/danbooru/danbooru/commit/808fe0411
[a0638daf1]: https://github.com/danbooru/danbooru/commit/a0638daf1
[31b58e17b]: https://github.com/danbooru/danbooru/commit/31b58e17b
[80e115b60]: https://github.com/danbooru/danbooru/commit/80e115b60
[06e12973e]: https://github.com/danbooru/danbooru/commit/06e12973e
[ce0550569]: https://github.com/danbooru/danbooru/commit/ce0550569
[010008eab]: https://github.com/danbooru/danbooru/commit/010008eab
[07921d2c8]: https://github.com/danbooru/danbooru/commit/07921d2c8
[99416d47b]: https://github.com/danbooru/danbooru/commit/99416d47b
[d34592650]: https://github.com/danbooru/danbooru/commit/d34592650
[5f6fc9f3e]: https://github.com/danbooru/danbooru/commit/5f6fc9f3e
[9ab799ef3]: https://github.com/danbooru/danbooru/commit/9ab799ef3
[5baeb3eec]: https://github.com/danbooru/danbooru/commit/5baeb3eec
[69facb22b]: https://github.com/danbooru/danbooru/commit/69facb22b
[1ec02dbe4]: https://github.com/danbooru/danbooru/commit/1ec02dbe4
[e8b92781c]: https://github.com/danbooru/danbooru/commit/e8b92781c
[0d03e7c5c]: https://github.com/danbooru/danbooru/commit/0d03e7c5c
[0b3d95c73]: https://github.com/danbooru/danbooru/commit/0b3d95c73
[1d5bb39cc]: https://github.com/danbooru/danbooru/commit/1d5bb39cc
[463e6d7b4]: https://github.com/danbooru/danbooru/commit/463e6d7b4
[b27f98dc5]: https://github.com/danbooru/danbooru/commit/b27f98dc5
[8fff3315f]: https://github.com/danbooru/danbooru/commit/8fff3315f
[88d14b30e]: https://github.com/danbooru/danbooru/commit/88d14b30e
[4b635628c]: https://github.com/danbooru/danbooru/commit/4b635628c
[bb5f29111]: https://github.com/danbooru/danbooru/commit/bb5f29111
[160829d26]: https://github.com/danbooru/danbooru/commit/160829d26
[feb3ec075]: https://github.com/danbooru/danbooru/commit/feb3ec075
[02122343c]: https://github.com/danbooru/danbooru/commit/02122343c
[3dc854c0c]: https://github.com/danbooru/danbooru/commit/3dc854c0c
[d74eda2b9]: https://github.com/danbooru/danbooru/commit/d74eda2b9
[6ad774b93]: https://github.com/danbooru/danbooru/commit/6ad774b93
[57c4d2a54]: https://github.com/danbooru/danbooru/commit/57c4d2a54
[5ea61c692]: https://github.com/danbooru/danbooru/commit/5ea61c692
[ad3f3fdce]: https://github.com/danbooru/danbooru/commit/ad3f3fdce
[638696235]: https://github.com/danbooru/danbooru/commit/638696235
[49d18e64e]: https://github.com/danbooru/danbooru/commit/49d18e64e
[120434bb9]: https://github.com/danbooru/danbooru/commit/120434bb9
[d76d54369]: https://github.com/danbooru/danbooru/commit/d76d54369
[dcefb842d]: https://github.com/danbooru/danbooru/commit/dcefb842d
[e5b2adc37]: https://github.com/danbooru/danbooru/commit/e5b2adc37
[461da6505]: https://github.com/danbooru/danbooru/commit/461da6505
[1183341a4]: https://github.com/danbooru/danbooru/commit/1183341a4
[6fdc41a1b]: https://github.com/danbooru/danbooru/commit/6fdc41a1b
[365e04b5f]: https://github.com/danbooru/danbooru/commit/365e04b5f
[fde15d979]: https://github.com/danbooru/danbooru/commit/fde15d979
[7a24d08bb]: https://github.com/danbooru/danbooru/commit/7a24d08bb
[aeb5edaff]: https://github.com/danbooru/danbooru/commit/aeb5edaff
[58e471948]: https://github.com/danbooru/danbooru/commit/58e471948
[02ba1e37b]: https://github.com/danbooru/danbooru/commit/02ba1e37b
[c3f834f79]: https://github.com/danbooru/danbooru/commit/c3f834f79
[46027e9eb]: https://github.com/danbooru/danbooru/commit/46027e9eb
[65dbd89e2]: https://github.com/danbooru/danbooru/commit/65dbd89e2
[766113a44]: https://github.com/danbooru/danbooru/commit/766113a44
[d84201273]: https://github.com/danbooru/danbooru/commit/d84201273
[4066ee52b]: https://github.com/danbooru/danbooru/commit/4066ee52b
[6f3f92088]: https://github.com/danbooru/danbooru/commit/6f3f92088
[345a22216]: https://github.com/danbooru/danbooru/commit/345a22216
[9efa52142]: https://github.com/danbooru/danbooru/commit/9efa52142
[cbaaf2694]: https://github.com/danbooru/danbooru/commit/cbaaf2694
[133531bb5]: https://github.com/danbooru/danbooru/commit/133531bb5
[0001d6b55]: https://github.com/danbooru/danbooru/commit/0001d6b55
[b891b8015]: https://github.com/danbooru/danbooru/commit/b891b8015
[2dfec29da]: https://github.com/danbooru/danbooru/commit/2dfec29da
[7c63ac8db]: https://github.com/danbooru/danbooru/commit/7c63ac8db
[8ed2c4f0b]: https://github.com/danbooru/danbooru/commit/8ed2c4f0b
[c72ee9edd]: https://github.com/danbooru/danbooru/commit/c72ee9edd
[d27cab65b]: https://github.com/danbooru/danbooru/commit/d27cab65b
[5623b139a]: https://github.com/danbooru/danbooru/commit/5623b139a
[96085f17d]: https://github.com/danbooru/danbooru/commit/96085f17d
[f6a96c632]: https://github.com/danbooru/danbooru/commit/f6a96c632
[a2690dcb4]: https://github.com/danbooru/danbooru/commit/a2690dcb4
[cf1a82a3b]: https://github.com/danbooru/danbooru/commit/cf1a82a3b
[4a7d2f337]: https://github.com/danbooru/danbooru/commit/4a7d2f337
[c4e47e46c]: https://github.com/danbooru/danbooru/commit/c4e47e46c
[1b540c4c2]: https://github.com/danbooru/danbooru/commit/1b540c4c2
[f52003f12]: https://github.com/danbooru/danbooru/commit/f52003f12
[fbf96d111]: https://github.com/danbooru/danbooru/commit/fbf96d111
[0f36a3152]: https://github.com/danbooru/danbooru/commit/0f36a3152
[f942768ce]: https://github.com/danbooru/danbooru/commit/f942768ce
[64a8719e0]: https://github.com/danbooru/danbooru/commit/64a8719e0
[f425fa7ce]: https://github.com/danbooru/danbooru/commit/f425fa7ce
[6d62e3e48]: https://github.com/danbooru/danbooru/commit/6d62e3e48
[1ff98b41a]: https://github.com/danbooru/danbooru/commit/1ff98b41a
[fb13ffdd9]: https://github.com/danbooru/danbooru/commit/fb13ffdd9
[095f8f444]: https://github.com/danbooru/danbooru/commit/095f8f444
[a62eb7704]: https://github.com/danbooru/danbooru/commit/a62eb7704
[e4096460e]: https://github.com/danbooru/danbooru/commit/e4096460e
[f7f72e29b]: https://github.com/danbooru/danbooru/commit/f7f72e29b
[804a2ef9a]: https://github.com/danbooru/danbooru/commit/804a2ef9a
[8dca5cd8e]: https://github.com/danbooru/danbooru/commit/8dca5cd8e
[7a1f08b95]: https://github.com/danbooru/danbooru/commit/7a1f08b95
[ad2e003d7]: https://github.com/danbooru/danbooru/commit/ad2e003d7
[6bd77d983]: https://github.com/danbooru/danbooru/commit/6bd77d983
[9430e6505]: https://github.com/danbooru/danbooru/commit/9430e6505
[c584ca5b1]: https://github.com/danbooru/danbooru/commit/c584ca5b1
[87a00a118]: https://github.com/danbooru/danbooru/commit/87a00a118
[d972b0b32]: https://github.com/danbooru/danbooru/commit/d972b0b32
[777893bb9]: https://github.com/danbooru/danbooru/commit/777893bb9
[be721db44]: https://github.com/danbooru/danbooru/commit/be721db44
[bdb08b780]: https://github.com/danbooru/danbooru/commit/bdb08b780
[00531dd2c]: https://github.com/danbooru/danbooru/commit/00531dd2c
[55e84426b]: https://github.com/danbooru/danbooru/commit/55e84426b
[a6844e9c3]: https://github.com/danbooru/danbooru/commit/a6844e9c3
[6c9f5809b]: https://github.com/danbooru/danbooru/commit/6c9f5809b
[442515029]: https://github.com/danbooru/danbooru/commit/442515029
[3af352c76]: https://github.com/danbooru/danbooru/commit/3af352c76
[d281252e4]: https://github.com/danbooru/danbooru/commit/d281252e4
[f85eef9bc]: https://github.com/danbooru/danbooru/commit/f85eef9bc
[f0a5dc35f]: https://github.com/danbooru/danbooru/commit/f0a5dc35f
[2e0ad42ec]: https://github.com/danbooru/danbooru/commit/2e0ad42ec
[a36ae3984]: https://github.com/danbooru/danbooru/commit/a36ae3984
[79923344d]: https://github.com/danbooru/danbooru/commit/79923344d
[cbc3b4877]: https://github.com/danbooru/danbooru/commit/cbc3b4877
[570d6a9d0]: https://github.com/danbooru/danbooru/commit/570d6a9d0
[42afe48d9]: https://github.com/danbooru/danbooru/commit/42afe48d9
[520f54d77]: https://github.com/danbooru/danbooru/commit/520f54d77
[d2018b04e]: https://github.com/danbooru/danbooru/commit/d2018b04e
[9db78c4ed]: https://github.com/danbooru/danbooru/commit/9db78c4ed
[4fdef8393]: https://github.com/danbooru/danbooru/commit/4fdef8393
[d1caa7d66]: https://github.com/danbooru/danbooru/commit/d1caa7d66
[e38c959da]: https://github.com/danbooru/danbooru/commit/e38c959da
[f08f57907]: https://github.com/danbooru/danbooru/commit/f08f57907
[174c8e006]: https://github.com/danbooru/danbooru/commit/174c8e006
[9867514a7]: https://github.com/danbooru/danbooru/commit/9867514a7
[659f8a6e9]: https://github.com/danbooru/danbooru/commit/659f8a6e9
[339dde092]: https://github.com/danbooru/danbooru/commit/339dde092
[bb831d2b7]: https://github.com/danbooru/danbooru/commit/bb831d2b7
[1b0e094b0]: https://github.com/danbooru/danbooru/commit/1b0e094b0
[9651eba71]: https://github.com/danbooru/danbooru/commit/9651eba71
[02d99af7e]: https://github.com/danbooru/danbooru/commit/02d99af7e
[57931c9e3]: https://github.com/danbooru/danbooru/commit/57931c9e3
[c135a6a0a]: https://github.com/danbooru/danbooru/commit/c135a6a0a
[688065591]: https://github.com/danbooru/danbooru/commit/688065591
[f7cc970c5]: https://github.com/danbooru/danbooru/commit/f7cc970c5
[c210ba058]: https://github.com/danbooru/danbooru/commit/c210ba058
[e28b403fb]: https://github.com/danbooru/danbooru/commit/e28b403fb
[e32e7af6f]: https://github.com/danbooru/danbooru/commit/e32e7af6f
[e6542eba7]: https://github.com/danbooru/danbooru/commit/e6542eba7
[b34aa3d04]: https://github.com/danbooru/danbooru/commit/b34aa3d04
[2b2af84c9]: https://github.com/danbooru/danbooru/commit/2b2af84c9
[af35ec930]: https://github.com/danbooru/danbooru/commit/af35ec930
[6325e9d26]: https://github.com/danbooru/danbooru/commit/6325e9d26
[e925d8538]: https://github.com/danbooru/danbooru/commit/e925d8538
[edd4e4691]: https://github.com/danbooru/danbooru/commit/edd4e4691
[fde20e439]: https://github.com/danbooru/danbooru/commit/fde20e439
[c42e139e7]: https://github.com/danbooru/danbooru/commit/c42e139e7
[dd9dfd3b5]: https://github.com/danbooru/danbooru/commit/dd9dfd3b5
[5ec0124da]: https://github.com/danbooru/danbooru/commit/5ec0124da
[7ac15b980]: https://github.com/danbooru/danbooru/commit/7ac15b980
[27b75a205]: https://github.com/danbooru/danbooru/commit/27b75a205
[3ebff34b4]: https://github.com/danbooru/danbooru/commit/3ebff34b4
[8ece9bcc5]: https://github.com/danbooru/danbooru/commit/8ece9bcc5
[fc95d7585]: https://github.com/danbooru/danbooru/commit/fc95d7585
[ea6d799de]: https://github.com/danbooru/danbooru/commit/ea6d799de
[692355592]: https://github.com/danbooru/danbooru/commit/692355592
[1682ad927]: https://github.com/danbooru/danbooru/commit/1682ad927
[a889cc6a6]: https://github.com/danbooru/danbooru/commit/a889cc6a6
[6d99f50ee]: https://github.com/danbooru/danbooru/commit/6d99f50ee
[67bfecd74]: https://github.com/danbooru/danbooru/commit/67bfecd74
[4d807c399]: https://github.com/danbooru/danbooru/commit/4d807c399
[37b43a702]: https://github.com/danbooru/danbooru/commit/37b43a702
[b8aa223ec]: https://github.com/danbooru/danbooru/commit/b8aa223ec
[28d2753c5]: https://github.com/danbooru/danbooru/commit/28d2753c5
[16d27c0c0]: https://github.com/danbooru/danbooru/commit/16d27c0c0
[8df1496d2]: https://github.com/danbooru/danbooru/commit/8df1496d2
[a16b91e2b]: https://github.com/danbooru/danbooru/commit/a16b91e2b
[3da90ca25]: https://github.com/danbooru/danbooru/commit/3da90ca25
[89bffbe87]: https://github.com/danbooru/danbooru/commit/89bffbe87
[105553a1d]: https://github.com/danbooru/danbooru/commit/105553a1d
[6c6931399]: https://github.com/danbooru/danbooru/commit/6c6931399
[2537145b0]: https://github.com/danbooru/danbooru/commit/2537145b0
[25978ca75]: https://github.com/danbooru/danbooru/commit/25978ca75
[835cc23f6]: https://github.com/danbooru/danbooru/commit/835cc23f6
[9282fd968]: https://github.com/danbooru/danbooru/commit/9282fd968
[7f8a6adb0]: https://github.com/danbooru/danbooru/commit/7f8a6adb0
[ccb38a5bc]: https://github.com/danbooru/danbooru/commit/ccb38a5bc
[20cc2cd18]: https://github.com/danbooru/danbooru/commit/20cc2cd18
[d5ae2b1bc]: https://github.com/danbooru/danbooru/commit/d5ae2b1bc
[c46b31aa9]: https://github.com/danbooru/danbooru/commit/c46b31aa9
[4eb0a6413]: https://github.com/danbooru/danbooru/commit/4eb0a6413
[bab611d78]: https://github.com/danbooru/danbooru/commit/bab611d78
[87ac52578]: https://github.com/danbooru/danbooru/commit/87ac52578
[c795ba054]: https://github.com/danbooru/danbooru/commit/c795ba054
[c8debfb81]: https://github.com/danbooru/danbooru/commit/c8debfb81
[b5d602836]: https://github.com/danbooru/danbooru/commit/b5d602836
[3efac206a]: https://github.com/danbooru/danbooru/commit/3efac206a
[146222286]: https://github.com/danbooru/danbooru/commit/146222286
[9893dc173]: https://github.com/danbooru/danbooru/commit/9893dc173
[efc5487dd]: https://github.com/danbooru/danbooru/commit/efc5487dd
[f0a573e1e]: https://github.com/danbooru/danbooru/commit/f0a573e1e
[34c3df78d]: https://github.com/danbooru/danbooru/commit/34c3df78d
[4320e2ef7]: https://github.com/danbooru/danbooru/commit/4320e2ef7
[b169d60f6]: https://github.com/danbooru/danbooru/commit/b169d60f6
[899798431]: https://github.com/danbooru/danbooru/commit/899798431
[a442658f8]: https://github.com/danbooru/danbooru/commit/a442658f8
[b46400bac]: https://github.com/danbooru/danbooru/commit/b46400bac
[7bed81812]: https://github.com/danbooru/danbooru/commit/7bed81812
[b695c4ccb]: https://github.com/danbooru/danbooru/commit/b695c4ccb
[d053e135a]: https://github.com/danbooru/danbooru/commit/d053e135a
[80e0ae6a3]: https://github.com/danbooru/danbooru/commit/80e0ae6a3
[c7a47cadf]: https://github.com/danbooru/danbooru/commit/c7a47cadf
[6c6916578]: https://github.com/danbooru/danbooru/commit/6c6916578
[3d03de1c5]: https://github.com/danbooru/danbooru/commit/3d03de1c5
[a8799b1ae]: https://github.com/danbooru/danbooru/commit/a8799b1ae
[db60981eb]: https://github.com/danbooru/danbooru/commit/db60981eb
[8ce870da5]: https://github.com/danbooru/danbooru/commit/8ce870da5
[dedd509dd]: https://github.com/danbooru/danbooru/commit/dedd509dd
[37e13e1b5]: https://github.com/danbooru/danbooru/commit/37e13e1b5
[02c7c90a8]: https://github.com/danbooru/danbooru/commit/02c7c90a8
[0e7349ca4]: https://github.com/danbooru/danbooru/commit/0e7349ca4
[c1371eb0a]: https://github.com/danbooru/danbooru/commit/c1371eb0a
[fce8dcc97]: https://github.com/danbooru/danbooru/commit/fce8dcc97
[b35d108df]: https://github.com/danbooru/danbooru/commit/b35d108df
[5465c20cb]: https://github.com/danbooru/danbooru/commit/5465c20cb
[0f768d144]: https://github.com/danbooru/danbooru/commit/0f768d144
[e0f459e26]: https://github.com/danbooru/danbooru/commit/e0f459e26
[f461b0996]: https://github.com/danbooru/danbooru/commit/f461b0996
[84a0a89f4]: https://github.com/danbooru/danbooru/commit/84a0a89f4
[42fb81ffd]: https://github.com/danbooru/danbooru/commit/42fb81ffd
[b0f4d573c]: https://github.com/danbooru/danbooru/commit/b0f4d573c
[5a7966336]: https://github.com/danbooru/danbooru/commit/5a7966336
[9fb2e4911]: https://github.com/danbooru/danbooru/commit/9fb2e4911
[f1e31868d]: https://github.com/danbooru/danbooru/commit/f1e31868d
[d72623abd]: https://github.com/danbooru/danbooru/commit/d72623abd
[f286cb003]: https://github.com/danbooru/danbooru/commit/f286cb003
[e3ee3b1cd]: https://github.com/danbooru/danbooru/commit/e3ee3b1cd
[7ad1b8717]: https://github.com/danbooru/danbooru/commit/7ad1b8717
[9548dad16]: https://github.com/danbooru/danbooru/commit/9548dad16
[d7cdd3f19]: https://github.com/danbooru/danbooru/commit/d7cdd3f19
[18503fcf0]: https://github.com/danbooru/danbooru/commit/18503fcf0
[73219f38c]: https://github.com/danbooru/danbooru/commit/73219f38c
[a029b71ce]: https://github.com/danbooru/danbooru/commit/a029b71ce
[e25c00ef5]: https://github.com/danbooru/danbooru/commit/e25c00ef5
[5110b4bfa]: https://github.com/danbooru/danbooru/commit/5110b4bfa
[f0a593609]: https://github.com/danbooru/danbooru/commit/f0a593609
[e72446463]: https://github.com/danbooru/danbooru/commit/e72446463
[651dfc095]: https://github.com/danbooru/danbooru/commit/651dfc095
[19bbc165d]: https://github.com/danbooru/danbooru/commit/19bbc165d
[a219ab393]: https://github.com/danbooru/danbooru/commit/a219ab393
[a54c15e47]: https://github.com/danbooru/danbooru/commit/a54c15e47
[72d00b7fd]: https://github.com/danbooru/danbooru/commit/72d00b7fd
[86f88ac72]: https://github.com/danbooru/danbooru/commit/86f88ac72
[f3abe1db5]: https://github.com/danbooru/danbooru/commit/f3abe1db5
[2f3d49112]: https://github.com/danbooru/danbooru/commit/2f3d49112
[ee072e323]: https://github.com/danbooru/danbooru/commit/ee072e323
[4029dfd8e]: https://github.com/danbooru/danbooru/commit/4029dfd8e
[fc2242849]: https://github.com/danbooru/danbooru/commit/fc2242849
[20c42ce8d]: https://github.com/danbooru/danbooru/commit/20c42ce8d
[3949338b9]: https://github.com/danbooru/danbooru/commit/3949338b9
[a2de525b4]: https://github.com/danbooru/danbooru/commit/a2de525b4
[2f17082e7]: https://github.com/danbooru/danbooru/commit/2f17082e7
[99221e402]: https://github.com/danbooru/danbooru/commit/99221e402
[73625ec1c]: https://github.com/danbooru/danbooru/commit/73625ec1c
[439d389b5]: https://github.com/danbooru/danbooru/commit/439d389b5
[5ad06a403]: https://github.com/danbooru/danbooru/commit/5ad06a403
[00d7c1912]: https://github.com/danbooru/danbooru/commit/00d7c1912
[1c2545c37]: https://github.com/danbooru/danbooru/commit/1c2545c37
[bd24db65e]: https://github.com/danbooru/danbooru/commit/bd24db65e
[9b8d3ac4e]: https://github.com/danbooru/danbooru/commit/9b8d3ac4e
[e54fdf3a9]: https://github.com/danbooru/danbooru/commit/e54fdf3a9
[5eb147058]: https://github.com/danbooru/danbooru/commit/5eb147058
[da6fa4b7e]: https://github.com/danbooru/danbooru/commit/da6fa4b7e
[245602601]: https://github.com/danbooru/danbooru/commit/245602601
[cb63d16a2]: https://github.com/danbooru/danbooru/commit/cb63d16a2
[a63662302]: https://github.com/danbooru/danbooru/commit/a63662302
[790d585b6]: https://github.com/danbooru/danbooru/commit/790d585b6
[fb5fb418c]: https://github.com/danbooru/danbooru/commit/fb5fb418c
[10a129f53]: https://github.com/danbooru/danbooru/commit/10a129f53
[5b61bbd1c]: https://github.com/danbooru/danbooru/commit/5b61bbd1c
[63eb593ae]: https://github.com/danbooru/danbooru/commit/63eb593ae
[2edaaf716]: https://github.com/danbooru/danbooru/commit/2edaaf716
[f15c285dc]: https://github.com/danbooru/danbooru/commit/f15c285dc
[4fb2894f0]: https://github.com/danbooru/danbooru/commit/4fb2894f0
[5c0b3557d]: https://github.com/danbooru/danbooru/commit/5c0b3557d
[a1ae09a18]: https://github.com/danbooru/danbooru/commit/a1ae09a18
[28cdd0599]: https://github.com/danbooru/danbooru/commit/28cdd0599
[975cf9609]: https://github.com/danbooru/danbooru/commit/975cf9609
[1fd18d470]: https://github.com/danbooru/danbooru/commit/1fd18d470
[a90b4fba2]: https://github.com/danbooru/danbooru/commit/a90b4fba2
[bdd6ae766]: https://github.com/danbooru/danbooru/commit/bdd6ae766
[e05d8d173]: https://github.com/danbooru/danbooru/commit/e05d8d173
[551f29b7e]: https://github.com/danbooru/danbooru/commit/551f29b7e
[954370be6]: https://github.com/danbooru/danbooru/commit/954370be6
[03f1c9cb3]: https://github.com/danbooru/danbooru/commit/03f1c9cb3
[9e86282f0]: https://github.com/danbooru/danbooru/commit/9e86282f0
[bc4b7c4fb]: https://github.com/danbooru/danbooru/commit/bc4b7c4fb
[fa39094da]: https://github.com/danbooru/danbooru/commit/fa39094da
[92c5f9a64]: https://github.com/danbooru/danbooru/commit/92c5f9a64
[1af7bf6fb]: https://github.com/danbooru/danbooru/commit/1af7bf6fb
[c944ba4f8]: https://github.com/danbooru/danbooru/commit/c944ba4f8
[90b2a2c4f]: https://github.com/danbooru/danbooru/commit/90b2a2c4f
[111a24184]: https://github.com/danbooru/danbooru/commit/111a24184
[b59586203]: https://github.com/danbooru/danbooru/commit/b59586203
[8f97937dc]: https://github.com/danbooru/danbooru/commit/8f97937dc
[73478613f]: https://github.com/danbooru/danbooru/commit/73478613f
[24ea0921e]: https://github.com/danbooru/danbooru/commit/24ea0921e
[802229065]: https://github.com/danbooru/danbooru/commit/802229065
[8d986e4f7]: https://github.com/danbooru/danbooru/commit/8d986e4f7
[8c1ea77fb]: https://github.com/danbooru/danbooru/commit/8c1ea77fb
[e74afa017]: https://github.com/danbooru/danbooru/commit/e74afa017
[b13086a63]: https://github.com/danbooru/danbooru/commit/b13086a63
[cb48619bc]: https://github.com/danbooru/danbooru/commit/cb48619bc
[0b2fd85fa]: https://github.com/danbooru/danbooru/commit/0b2fd85fa
[a49425e0c]: https://github.com/danbooru/danbooru/commit/a49425e0c
[6f2e0a00d]: https://github.com/danbooru/danbooru/commit/6f2e0a00d
[9fe61fd9e]: https://github.com/danbooru/danbooru/commit/9fe61fd9e
[ea32361ed]: https://github.com/danbooru/danbooru/commit/ea32361ed
