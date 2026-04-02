# Development

This document provides an overview of the project structure and the development workflow for Danbooru.

## Getting Started

### Codespaces

The easiest way to get started is to use [Github Codespaces](https://docs.github.com/en/codespaces). This will start a virtual machine running in the cloud with a fresh development instance, without having to install anything on your computer.

To try it out:

1. [Create a Github account](https://github.com/signup) if you don't have one already.
2. Click [Open in Github Codespaces](https://codespaces.new/danbooru/danbooru?quickstart=1).
3. Click the `Create new codespace` button.
4. Wait a few minutes for it to launch.

When it's done, it will open a Visual Studio Code window in your browser, and a new tab with your Danbooru instance. You can then proceed to editing the code. You can also open a terminal to run commands in the virtual machine.

See the [Running in Github Codespaces](DOCKER.md#running-in-github-codespaces) section of the [Docker guide](DOCKER.md) for more details.

### Visual Studio Code

The next easiest way to get started is to use Visual Studio Code with the Dev Containers extension. This will run the development environment in Docker containers on your local machine.

To get started:

* Install [Docker](https://docs.docker.com/get-docker/)
* Install [Git](https://git-scm.com/downloads)
* Install [Visual Studio Code](https://code.visualstudio.com/download)
* Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
* Clone the Danbooru repo. In VS Code, press `Ctrl+Shift+P`, type `git clone`, then type `https://github.com/danbooru/danbooru` in the window.
* Open the Danbooru folder.
* A window will appear in the bottom right saying `Folder contains a devcontainer...`. Click the `Reopen in container` option. Or press `Ctrl+Shift+P` and type `open folder in container`.
* A new development instance will launch in the background. When it's done, you can open it at http://localhost:3000.

You can then proceed to editing the code. You can also open a terminal in Visual Studio Code to run commands inside the devcontainer.

See the [Running in Visual Studio Code](DOCKER.md#running-in-visual-studio-code) section of the [Docker guide](DOCKER.md) for more details.

### Docker

If you don't use Visual Studio Code, you can use Docker Compose to run the development environment from the command line.

To get started, run:

```bash
bin/dev up
```

Alternatively, you can do:

```bash
sudo docker compose -f docker-compose.dev.yaml up
```

`bin/dev` is just a shortcut for that command.

Give it a minute to finish. When it's done, Danbooru will be running at http://localhost:3000/. You can then proceed to editing the code. To run commands in the devcontainer, use `bin/dev exec devcontainer bash`.

See the [Running in development mode](DOCKER.md#running-in-development-mode) section of the [Docker guide](DOCKER.md) for more details.

## Project Overview

The general flow of the app is that HTTP requests are handled by controllers in `app/controllers/`, which use `app/models` to load objects from the database, and `app/views` to render HTML pages. `app/policies` are used to check user permissions, and `app/components` are used to render reusable HTML components.

For example, a request to `/posts/1234` is handled by `PostsController#show`, which is defined in `app/controllers/posts_controller.rb`. The controller loads the `Post` (defined in `app/models/post.rb`) using `Post.find(params[:id])`, and then calls `authorize` to check permissions (which are defined in `PostPolicy#show?` in `app/policies/post_policy.rb`), and then calls `respond_with(@post)` to render the HTML page using `app/views/posts/show.html.erb`.

Danbooru follows standard Rails conventions. If you're unfamiliar with Rails, you should start with https://guides.rubyonrails.org. If you're unfamiliar with Ruby, you should start with https://www.ruby-lang.org/en/documentation/.

### Architecture

- Backend: Ruby on Rails, with PostgreSQL for the database, Redis for caching, GoodJob for background jobs.
- Frontend: Server-rendered HTML, with Tailwind-style CSS (in `utilities.scss`), Alpine.js and jQuery for interactivity, SimpleForm for forms, ViewComponents for reusable HTML/CSS/JS components.
- Testing: Minitest, with shoulda-context for structure, shoulda-matchers for RSpec-style matchers, FactoryBot for creating objects, Faker for generating fake data, Mocha for mocking.
- Development environment: Devcontainer inside Docker, with the Rails app, PostgreSQL, and other services in separate containers.

### File Structure

```
app/
├─ controllers/                     # Rails controllers (HTTP request handlers)
├─ models/                          # Rails models (Database-backed objects)
├─ views/                           # Rails views (HTML templates)
├─ components/                      # View components (HTML templates with CSS/JS/Ruby logic)
├─ policies/                        # Authorization policies (user permissions)
├─ helpers/                         # Helper functions for views
├─ jobs/                            # Background jobs
├─ mailers/                         # Email logic
├─ logical/                         # Non-Rails Ruby code (business logic, internal libraries, etc)
└─ javascript/                      # JavaScript/CSS sources
   ├─ packs/                        # Webpack entry points
   └─ src/
      ├─ javascripts/               # Javascript code
      └─ styles/                    # CSS code
bin/                                # Project-specific scripts and programs
config/                             # Rails configuration files
├─ danbooru_default_config.rb       # Default configuration file
├─ danbooru_local_config.rb         # Local configuration file (not committed to git)
├─ routes.rb                        # HTTP route/endpoint definitions
└─ initializers/                    # Code that runs on app startup
db/
├─ structure.sql                    # Database schema dump
└─ migrate/                         # Database migration scripts
lib/
├─ dtext_rb/                        # DText parser library
└─ tasks/                           # Rake tasks
public/                             # Static assets (compiled JS/CSS, images, favicons, etc)
├─ data/                            # Where uploaded files are stored by default
├─ fonts/                           # Fonts for translation notes
├─ logos/                           # Logos for links to external sites
└─ packs/                           # Compiled JS/CSS assets
script/                             # One-off scripts for fixing data issues
test/                               # Tests
├─ functional/                      # Controller/integration tests
├─ unit/                            # Model/unit tests
│  └─ source/                       # Source::Extractor tests
├─ components/                      # View component tests
├─ mailers/                         # Email tests
├─ jobs/                            # Background job tests
├─ system/                          # Frontend/headless browser tests
├─ factories/                       # Factories for test data (FactoryBot)
├─ files/                           # Test files (images, videos, etc)
└─ test_helpers/                    # Helper functions for tests
```

## Debugging

There are a few general techniques for debugging issues:

- Run `bin/rails console` to open a console and run code directly to inspect its behavior.
- Write a test that reproduces the issue, then use `bin/rails test -n '/test name/' <file>` to run the test.
- Use `binding.break` to set breakpoints in the code, then use `bin/rails test` or `bin/rails console` to run the code, or `bin/rdbg -A danbooru 12345` to attach to the running server.
- Use `puts` or `Rails.logger.debug("message")` to add logging statements, then use `bin/rails test` to run the code, or `bin/dev logs -f danbooru` to view the server logs.
- Add `raise "blah"` statements to raise an exception, then use the Ruby console on the error page to inspect variables.
- In views, you can do `<% binding.break %>` or `<% raise "blah" %>` to set a breakpoint or raise an exception in the view template.

### Commands

| Command | Description |
|---------|-------------|
| `bin/rails console` | Open Rails console. |
| `bin/rdbg -A danbooru 12345` | Attach debugger to Rails app server. |
| `bin/rdbg -A jobs 12345` | Attach debugger to background job processor. |

### External links

- https://guides.rubyonrails.org/debugging_rails_applications.html - Rails debugging guide
- https://github.com/ruby/debug - Ruby debugger documentation

## Testing

To run the tests, use `bin/rails test`. For extractor tests, you will have to add credentials for each site in `.env.test`.

A HTML test report will be generated at `tmp/html-test-results/index.html`, and a code coverage report will be generated at `tmp/coverage/index.html` if you ran the tests with `COVERAGE=1`. You can open these files in a browser to view the reports.

When working on controller tests in `test/functional`, you can use `DANBOORU_DEBUG_MODE=1 bin/rails test` to disable parallel tests and the error page, which makes it easier to use breakpoints and to see the actual exception when an exception is raised.

### Commands

| Command | Description |
|---------|-------------|
| `bin/rails test <file>` | Run tests for a single file. |
| `bin/rails test -n '/test name/' <file>` | Run test(s) by name. |
| `DANBOORU_DEBUG_MODE=true bin/rails test` | Run tests with debug mode enabled (disable parallel tests and the error page, etc). |
| `COVERAGE=1 bin/rails test` | Run tests with code coverage measurement. |

### External links

- https://guides.rubyonrails.org/testing.html

## Commands

Common commands used during day-to-day development:

| Command | Description |
|---------|-------------|
| `bin/dev ps` | List running containers. |
| `bin/dev logs -f <container>` | See logs for a container. |
| `bin/dev exec <container> bash` | Open a shell inside a container. |
| `bin/rails console` | Open a Rails console. |
| `bin/rubocop <file>` | Lint a Ruby file. |
| `npx eslint <file>` | Lint a JavaScript file. |
| `npx stylelint <file>` | Lint a CSS/SCSS file. |
| `bin/bundle outdated` | Check for outdated Ruby gems. |
| `bin/bundle update <gem>` | Update a Ruby gem. |
| `npm outdated` | Check for outdated npm packages. |
| `npm update <package>` | Update an npm package. |
| `bin/build-docker-image` | Rebuild the Docker image. |

## Commit Messages

Commit messages should use the following format:

- `<topic>: <short description>`
- `Fix #<issue number>: <issue title>` (if the commit fixes an issue)

The commit body should explain things in more detail. Provide enough context so that someone looking at the code years from now can understand why the change was made.

## Pull Requests

Pull requests should include tests when possible. For bug fixes, a test should be added that reproduces the bug and that shows the bug is fixed.

## External links

- https://guides.rubyonrails.org/ - Rails intro documentation
- https://api.rubyonrails.org/ - Rails API reference
- https://www.ruby-lang.org/en/documentation/ - Ruby intro documentation
- https://docs.ruby-lang.org/en/ - Ruby reference manual
- https://rubyapi.org/ - Ruby standard library documentation
