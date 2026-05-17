# Changelog and Testing Reference

Practical guidance for locating changelogs and verifying dependency updates in this project.

## Finding Changelogs

### Ruby Gems

Prefer sources in this order:

1. **GitHub Releases page** — `https://github.com/<owner>/<repo>/releases` — most gems publish release notes here.
2. **CHANGELOG.md** in the repo root — check for a `CHANGELOG.md`, `HISTORY.md`, or `CHANGES.md` file.
3. **RubyGems.org gem page** — `https://rubygems.org/gems/<name>` — the sidebar links to the source repo and changelog when provided.
4. **Git log between tags** — `git log v1.2.3..v2.0.0 --oneline` in a local checkout when release notes are absent.

Common locations for gems used in this project:

| Gem | Changelog |
|-----|-----------|
| `rails` (and railties, activesupport, etc.) | https://github.com/rails/rails/releases and the [Rails upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html) |
| `good_job` | https://github.com/bensheldon/good_job/blob/main/CHANGELOG.md |
| `puma` | https://github.com/puma/puma/blob/master/History.md |
| `nokogiri` | https://github.com/sparklemotion/nokogiri/blob/main/CHANGELOG.md |
| `pundit` | https://github.com/varvet/pundit/blob/main/CHANGELOG.md |
| `view_component` | https://viewcomponent.org/CHANGELOG.html |
| `rubocop` | https://github.com/rubocop/rubocop/releases |
| `rubocop-rails` | https://github.com/rubocop/rubocop-rails/releases |
| `shakapacker` | https://github.com/shakacode/shakapacker/blob/main/CHANGELOG.md |
| `scenic` | https://github.com/scenic-views/scenic/blob/main/CHANGELOG.md |

### npm Packages

Prefer sources in this order:

1. **GitHub Releases page** — most packages publish release notes here.
2. **CHANGELOG.md** in the repo root.
3. **npm registry page** — `https://www.npmjs.com/package/<name>?activeTab=versions` — links to the repo.
4. **GitHub compare URL** — `https://github.com/<owner>/<repo>/compare/v1.2.3...v2.0.0` for a condensed diff view.

Common locations for packages used in this project:

| Package | Changelog |
|---------|-----------|
| `webpack` | https://github.com/webpack/webpack/releases |
| `alpinejs` | https://github.com/alpinejs/alpine/releases |
| `postcss` | https://github.com/postcss/postcss/blob/main/CHANGELOG.md |
| `postcss-preset-env` | https://github.com/csstools/postcss-plugins/blob/main/plugin-packs/postcss-preset-env/CHANGELOG.md |
| `sass` / `sass-loader` | https://github.com/sass/dart-sass/blob/main/CHANGELOG.md and https://github.com/webpack-contrib/sass-loader/releases |
| `eslint` | https://github.com/eslint/eslint/releases |
| `stylelint` | https://github.com/stylelint/stylelint/releases |
| `babel-loader` / `@babel/*` | https://github.com/babel/babel/releases |
| `jquery` | https://github.com/jquery/jquery/releases |

---

## What to Look For

### Ruby Gems

When scanning a changelog, flag and act on:

- **Ruby or Rails version drops** — check against `Gemfile` (`ruby "~> 3.4.5"`, current Rails version).
- **Generator changes** — `rails`, `good_job`, and similar gems ship generators or migration templates; re-run the generator after updating (`bin/rails app:update`, `bin/rails generate good_job:update`).
- **New native extension requirements** — gems like `nokogiri`, `ffi`, `ruby-vips`, `pg`, and `rbnacl` link against system libraries; check if a new system package is required.
- **Renamed or removed public APIs** — search the codebase for any method or constant removed in the new version.
- **Initializer / configuration file changes** — new required config keys, deprecated options, or changed defaults.
- **Deprecation warnings promoted to errors** — anything that printed a warning in the previous version may now raise.

### npm Packages

When scanning a changelog, flag and act on:

- **Node.js or browser support drops** — check `.nvmrc` / `engines` field and project browser targets.
- **ESM / CJS module format changes** — packages switching from CJS to pure ESM require import style changes or Babel/webpack loader updates; check `babel.config.json` and `config/webpack/`.
- **Renamed or removed exports** — deep imports like `package/dist/file` often break on major bumps; search the codebase.
- **Webpack loader or plugin API changes** — `webpack`, `css-loader`, `sass-loader`, `postcss-loader`, `mini-css-extract-plugin`, `compression-webpack-plugin`, and `babel-loader` all have webpack-version coupling; cross-check versions.
- **PostCSS plugin API changes** — `postcss`, `postcss-loader`, and `postcss-preset-env` share a plugin API level; a major update to any one of them may require the others to move together.
- **Stylelint or ESLint config format changes** — major versions of these tools sometimes change config file formats (e.g., ESLint's flat config migration).
- **Build output format changes** — changes in how a bundler or transpiler emits code that could affect runtime behaviour.

---

## Testing After Updates

Run verification in order from narrow to broad. Stop and investigate at the first failure.

### Ruby / Rails

```bash
# Targeted – one test by name
bin/rails test <path/to/test_file.rb> -n '/relevant test name/'

# File-level
bin/rails test <path/to/test_file.rb>

# Full suite
bin/rails test

# Linting (for changed Ruby files)
bin/rubocop <path/to/changed_file.rb>
```

Choose the test file(s) based on what the gem affects:

| Updated gem | Start with |
|-------------|-----------|
| `rails` / `activerecord` | `test/unit/` and `test/functional/` |
| `pundit` | `test/policies/` |
| `view_component` | `test/components/` |
| `good_job` | `test/jobs/` |
| `rubocop` / `rubocop-rails` | `bin/rubocop` on changed files, then full `bin/rubocop` |

### JavaScript / CSS

```bash
# JS linting
npm run eslint-all

# CSS/SCSS linting
npm run stylelint-all

# Full Rails test suite (covers JS integration via system tests)
bin/rails test
```

Choose the check based on what the package affects:

| Updated package | Start with |
|-----------------|-----------|
| `webpack` / `webpack-cli` / `webpack-merge` | `npm run eslint-all`, then build verification |
| `postcss` / `postcss-preset-env` / `postcss-loader` | `npm run stylelint-all`, then check compiled CSS output |
| `sass` / `sass-loader` | `npm run stylelint-all`, then check compiled CSS output |
| `eslint` / `eslint-plugin-*` | `npm run eslint-all` |
| `stylelint` / `stylelint-config-*` | `npm run stylelint-all` |
| `alpinejs` / `@alpinejs/*` | System tests that exercise Alpine-powered interactions |
| `babel-loader` / `@babel/*` | `npm run eslint-all`, then full suite |

---

## Tips

- When the changelog lists a version as "yanked" on RubyGems.org or npm, skip straight to the next version.
- For Rails upgrades, always cross-read the [Rails upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html) in addition to the release notes; the guide covers config file and initializer changes that the changelog omits.
- For gems with no changelog, read the GitHub commit history between the two tags. Even a quick `git log` scan is better than skipping review entirely.
- When a major version has no point release yet (e.g., `2.0.0` only), wait before updating unless the update is a security fix.
