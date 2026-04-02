# AGENTS.md

This file provides guidance for coding agents working in this repository. It's meant for coding agents, but the information may be useful for humans as well.

## Project Overview

- Backend: Ruby on Rails, with PostgreSQL for the database, Redis for caching, GoodJob for background jobs.
- Frontend: Server-rendered HTML, with Tailwind-style CSS (in `utilities.scss`), Alpine.js and jQuery for interactivity, SimpleForm for forms, ViewComponents for reusable HTML/CSS/JS components.
- Testing: Minitest, with shoulda-context for structure, shoulda-matchers for RSpec-style matchers, FactoryBot for creating objects, Faker for generating fake data, Mocha for mocking.
- Development environment: Devcontainer inside Docker, with the Rails app, PostgreSQL, and other services in separate containers.

## Development Guidelines

- Use test-driven (red/green) development. Write tests first, then write code to make the tests pass.
- Always write tests to reproduce a bug before attempting to fix it.
- Always write tests specifying how new features should work before implementing the feature.
- Lint files after you're done editing them. Fix any lint errors introduced by your changes, but not any lint errors that were already present.

## General Guidelines

- Do not run destructive git commands (for example: `git reset --hard`, `git checkout --`, `git clean`, etc) unless explicitly requested.
- Use Ruby scripts instead of Python or Bash when possible. Ruby is the language used by this codebase.
- Use `grep` instead of `ripgrep` or `rg`. `rg` is not installed in this environment.
- Use `sudo apt-get` if you need to install a new package in the devcontainer.
- Use the debugger instead of guessing at the source of a problem.
- Don't remove tests if the test is failing and you can't fix it.
- Place temporary files in `/tmp`. Delete them when you're done.
- See `docs/` or look for `README.md` files in each folder if you need more information.
- Propose updates to AGENTS.md, skills, or other documentation if you think it would be helpful for future agents.

## Code Style

- Don't keep old code around as a fallback path. If the old code is wrong, just fix it instead of leaving it in place.
- Don't introduce unnecessary abstractions, indirections, or helper methods. Don't add methods only used in one place.
- Avoid loops and mutation. Prefer functional transformations and immutable data instead.

## Commands

| Command | Description |
|---------|-------------|
| `bin/rails test <file>` | Run tests for a single file. |
| `bin/rails test -n '/test name/' <file>` | Run a specific test by name. |
| `bin/rubocop <file>` | Lint a Ruby file. |
| `npx eslint <file>` | Lint a JavaScript file. |
| `npx stylelint <file>` | Lint a CSS file. |
| `bin/dev ps` | Show running Docker containers. |
| `bin/dev logs <container>` | Show logs for a specific container. |
| `bin/dev exec <container> <CMD>` | Run a command in a specific container. |
| `bin/rdbg -A danbooru 12345` | Attach debugger to Rails server running in `danbooru` container on port 12345. |
| `bin/rbtrace --firehose --exec <CMD>` | Trace execution of a Ruby process (see `bin/rbtrace --help` for more options). |
