 # Quickstart

Run this to start a Danbooru instance:

```bash
sh -c "$(curl -sSL https://raw.githubusercontent.com/danbooru/danbooru/master/bin/setup)"
```

This will install [Docker Compose](https://docs.docker.com/compose/) and launch a Danbooru instance. When it's done, Danbooru will be running at http://localhost:3000/.

This is just a quick demo. Read on to learn how to run a full Danbooru instance.

# Preliminaries

This guide explains how to install and run Danbooru using [Docker](https://www.docker.com/get-started/). Using Docker is the recommended way to run Danbooru. It's possible to [install Danbooru manually](https://github.com/danbooru/danbooru/wiki/Manual-Installation-Guide), but manual installation is more difficult and not supported.

If you've never used Docker before, don't be put off. It's easier to learn Docker than to install and run Danbooru manually.

Before getting started, be aware that Danbooru is not designed to be used as a personal booru, or as an easy way to build your own booru. The Danbooru codebase is mainly designed to fit the needs of the Danbooru website. It's possible to use it to run your own booru, but it's not designed for this, and you'll need some programming skills in order to customize it for your needs.

If you're just looking for an easy way to manage your own image collection, consider [Hydrus](https://github.com/hydrusnetwork/hydrus) instead. If you're looking for an easy way to run your own booru, consider [Shimmie](https://github.com/shish/shimmie2).

If you need help, ask in the [#technical](https://discord.com/channels/310432830138089472/310846683376517121) channel on the [Danbooru Discord](https://discord.gg/danbooru), or in the [discussions area](https://github.com/danbooru/danbooru/discussions) on Github.

# Installation

First, download Danbooru's code:

```bash
git clone http://github.com/danbooru/danbooru
cd danbooru
```

Next, install Docker. The `bin/setup` script will try to do that automatically:

```bash
bin/setup
```

If that doesn't work, then you can try using Docker's install script:

```bash
curl -fsSL https://get.docker.com | sh
```

If that still doesn't work, or you don't want to use the install script, then follow Docker's [installation guide](https://docs.docker.com/get-docker/) to install Docker yourself. See the [Ubuntu](https://docs.docker.com/engine/install/ubuntu/) and [Windows](https://docs.docker.com/desktop/install/windows-install/) guides in particular.

To check that Docker is installed and working, try these commands:

```bash
sudo docker info
sudo docker version
sudo docker compose version
```

Make sure you have at least Docker Compose v2.21.0.

# Running Danbooru

There are two ways to run Danbooru: in production mode, or in development mode.

Production mode is run with `sudo docker compose up`. Production mode is faster than development mode, but you have to rebuild the image and restart the container every time you make any changes to the code.

Development mode is run with `bin/dev up`. In development mode, you can edit the code and your changes will immediately take effect. The downsides are that it's slower than production mode, it's less stable because it runs off the [master](https://github.com/danbooru/danbooru/commits/master/) branch instead of the [production](https://github.com/danbooru/danbooru/commits/production) branch, and it's not safe to let others have access to your instance. Anyone with access to your instance can run code or login as any user.

Use production mode if you just want to run your own booru. Use development mode if you plan on working on the code. Don't use development mode for a public site accessible by other people.

## Running in production mode

To start Danbooru, do:

```bash
sudo docker compose up
```

Give it a few minutes to finish. When it's done, Danbooru will be running at http://localhost:3000/.

If you get any errors about missing config files, do this to create them:

```
touch .env.local config/danbooru_local_config.rb
```

When you're done, you can run this to shut down the instance and delete all the data:

```bash
sudo docker compose down --volumes
```

Next read the [Configuration](#configuration) section to learn how to configure your instance.

## Running in development mode

To start Danbooru in development mode, do:

```bash
bin/dev up
```

Alternatively, you can do:

```bash
sudo docker compose -f docker-compose.dev.yaml up
```

`bin/dev` is just a shortcut for that command.

Give it a few minutes to finish. When it's done, Danbooru will be running at http://localhost:3000/.

When you're done, run this to shut down the instance and delete all the data:

```bash
bin/dev down --volumes
```

Next read the [Configuration](#configuration) section to learn how to configure your instance.

## Running in Visual Studio Code

It's possible to run Danbooru from inside Visual Studio Code. This is the easiest way to run Danbooru if you're using Windows, or if you're more comfortable with VS Code than the command line.

To get started:

* Install [Docker](https://docs.docker.com/get-docker/)
* Install [Git](https://git-scm.com/downloads)
* Install [Visual Studio Code](https://code.visualstudio.com/download)
* Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
* Clone the Danbooru repo. In VS Code, press `Ctrl+Shift+P`, type `git clone`, then type `https://github.com/danbooru/danbooru` in the window.
* Open the Danbooru folder.
* A window will appear in the bottom right saying `Folder contains a devcontainer...`. Click the `Reopen in container` option. Or press `Ctrl+Shift+P` and type `open folder in container`.
* A Danbooru instance will launch in the background. When it's done, you can open it at http://localhost:3000.

For more information:

* https://code.visualstudio.com/docs/devcontainers/containers
* https://code.visualstudio.com/docs/devcontainers/tutorial
* https://containers.dev/

## Running in Github Codespaces

[Github Codespaces](https://docs.github.com/en/codespaces) lets you run Danbooru inside your browser, without having to install anything on your computer. It works by launching a virtual machine in the cloud running a new Danbooru instance and a copy of Visual Studio Code.

To try it out:

1. [Create a Github account](https://github.com/signup) if you don't have one already.
2. Click [Open in Github Codespaces](https://codespaces.new/danbooru/danbooru?quickstart=1).
3. Click the `Create new codespace` button.
4. Wait a few minutes for it to launch.

When it's done, it will open a Visual Studio Code window in your browser, and a new tab with your Danbooru instance. You may have to enable popups for it to open the Danbooru tab.

If you don't see the Danbooru tab, you can click the `Ports` tab in the VS Code window, then click the Globe icon under the `Forwarded Address` column next to the `Danbooru (3000)` port. The address will look something like `https://fluffy-sniffle-qjppx59wr43jj8-3000.app.github.dev`.

Codespaces is a paid product, but you don't have to pay anything to try it out. There's a 60 hours per month free tier that doesn't require a credit card.

When you're done, you can go to your [Codespaces page](https://github.com/codespaces) to stop and delete your codespace.

# Configuration

To configure your instance, edit the files `.env.local` or `config/danbooru_local_config.rb`.

Start by copying either `config/danbooru_default_config.rb` to `config/danbooru_local_config.rb`, or `.env` to `.env.local`, then edit the files as needed.

See `config/danbooru_default_config.rb` for the default settings.

After you change your config, restart your instance with `docker compose restart` or `bin/dev restart`.

## Using a custom domain name

If you want to run a public site with a custom domain name, then set `DANBOORU_CANONICAL_URL` to the URL of your site in `.env.local`.

For example, if your site's address was `https://booru.example.com`, then you would set `DANBOORU_CANONICAL_URL="https://booru.example.com"` in `.env.local`.

## Running a reverse proxy

If your Danbooru instance is running behind a reverse proxy, then you need to set `DANBOORU_REVERSE_PROXY=true` in `.env.local`.

Your reverse proxy should send the following headers:

```
# In Nginx syntax
proxy_set_header Host $http_host;
proxy_set_header X-Forwarded-Host $http_host;
proxy_set_header X-Forwarded-Port $server_port;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-For $remote_addr;
```

You can check that the headers are being sent correctly by doing `curl http://localhost:3000/nginx/headers` and `curl http://localhost:3000/status.json` (replacing `localhost:3000` with the URL for your site).

The headers should look something like this:

```
Host: booru.example.com
X-Forwarded-For: 1.2.3.4
X-Forwarded-Host: booru.example.com
X-Forwarded-Port: 443
X-Forwarded-Proto: https
```

You can compare your headers with http://danbooru.donmai.us/nginx/headers and http://danbooru.donmai.us/status.json to see what a working example looks like.

# Working with Docker

Here are some useful commands for working with your instance. If working in development mode, write `bin/dev` instead of `sudo docker compose`.

To start your instance:

```bash
sudo docker compose up
```

To stop your instance, press `Ctrl+C`, or do:

```bash
sudo docker compose down
```

To delete all data for your instance:

```bash
sudo docker compose down --volumes
```

To update your instance:

```bash
git pull
sudo docker compose pull
sudo docker compose down
sudo docker compose up
```

To backup your data:

```bash
sudo docker compose run --rm -T danbooru bin/rails danbooru:database:backup > danbooru-database.pg_dump
sudo docker compose run --rm -T danbooru bin/rails danbooru:images:backup > danbooru-images.tar
sudo docker compose cp iqdb:/iqdb/data/iqdb.sqlite ./
```

To restore your data:

```bash
sudo docker compose down --volumes
sudo docker compose run --rm -T danbooru bin/rails danbooru:database:restore < danbooru-database.pg_dump
sudo docker compose run --rm -T danbooru bin/rails danbooru:images:restore < danbooru-images.tar
sudo docker compose cp ./iqdb.sqlite iqdb:/iqdb/data/iqdb.sqlite
```

To start a Bash shell inside your instance (for debugging).

```bash
sudo docker compose run --rm danbooru bash
```

To start a Rails console inside your instance (for debugging)

```bash
sudo docker compose run --rm danbooru bin/rails console
```

To start a Postgres shell inside your instance (for debugging)

```bash
sudo docker compose run --rm danbooru bin/rails dbconsole -p
```

To get a shell inside the `danbooru` container:

```bash
sudo docker compose exec danbooru bash
```

To show the logs of a container:

```bash
sudo docker compose logs -f danbooru
```

To start two Danbooru instances at the same time:

```bash
sudo env DANBOORU_PORT=3000 docker compose -p danbooru-1 up
sudo env DANBOORU_PORT=3001 docker compose -p danbooru-2 up
sudo docker compose -p danbooru-1 down --volumes
sudo docker compose -p danbooru-2 down --volumes
```

To build a new image:

```bash
# You have to commit your changes first.
git commit --all
bin/build-docker-image
```

To use your custom image:

```bash
sudo env DANBOORU_IMAGE=danbooru docker compose up # For production mode
DANBOORU_IMAGE=danbooru:development bin/dev up     # For development mode
```

To run a Danbooru container by itself without Docker Compose:

```bash
sudo docker run --rm -it ghcr.io/danbooru/danbooru bash
```

# Development tips

Here are some tips for working with the code under Docker.

## Debugging

To use a debugger, add `binding.break` to set a breakpoint in the code, then attach to the `danbooru` container to open the debugger when the breakpoint is hit:

```bash
bin/dev up -d
docker attach danbooru-danbooru-1
```

Another trick is to write a test case that triggers the bug, then put `binding.break` in the test case or in the code where you think the bug lies. Then run your test with `bin/rails test test/unit/post_test.rb -n "/name of your test/"` to trigger the breakpoint.

See also [Debugging Rails Applications](https://edgeguides.rubyonrails.org/debugging_rails_applications.html#entering-a-debugging-session) and [How to use the debug gem](https://github.com/ruby/debug#how-to-use).

## Testing

To run the test suite:

```bash
bin/dev run --rm danbooru bin/rails test
```

To run the tests for a single file:

```bash
bin/dev run --rm danbooru bin/rails test test/unit/media_file_test.rb
```

To only run specific tests:

```bash
bin/dev run --rm danbooru bin/rails test test/unit/media_file_test.rb -n "/determine the correct dimensions/"
```

See also the [Testing Rails Applications](https://edgeguides.rubyonrails.org/testing.html) guide.

Note that you will need to configure usernames and passwords in `.env.local` for every source site Danbooru supports, otherwise you will get test failures for many of the upload and source extractor tests.

# Troubleshooting

Here are some things to try if you can't get it to work:

* Restart your instance with `docker compose down; docker compose up`.
* Check the logs with `docker compose logs -f`.
* Upgrade to the latest version with `git pull; docker compose pull; docker compose down; docker compose up`.
* Run with `bin/dev up` instead of `docker compose up` (or vice versa).

# Frequently Asked Questions

#### Where are my images and data stored?

Images and data are stored inside Docker in [Docker volumes](https://docs.docker.com/storage/volumes/). Use the backup and restore commands above to get your data in or out.

#### How do I run a booru under my own domain name?

Set `DANBOORU_CANONICAL_URL` to the URL for your site. For example, if your site is `mybooru.example.com`, then put `DANBOORU_CANONICAL_URL=http://mybooru.example.com` in `.env.local`.

#### I get a `HTTP Origin header didn't match request.base_url` error

This usually means you're running behind a reverse proxy and either `DANBOORU_REVERSE_PROXY` isn't set, or your proxy isn't sending the right headers. Put `DANBOORU_REVERSE_PROXY=true` in `.env` and read the [Running a reverse proxy](#running-a-reverse-proxy) section above to make sure you're sending the right headers.

#### I can't get it to work behind Cloudflare

Do the following:

* Set `DANBOORU_REVERSE_PROXY=true` in `.env` if proxying is enabled in Cloudflare (your site has an [orange cloud](https://developers.cloudflare.com/dns/manage-dns-records/reference/proxied-dns-records)).
* Set `DANBOORU_PORT=80` in `.env` (or use another port [supported by Cloudflare](https://developers.cloudflare.com/fundamentals/reference/network-ports)). Cloudflare doesn't support port 3000 if proxying is enabled.
* Don't enable [Full SSL mode](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/full/) in Cloudflare unless you have SSL working on your server.

#### It's not picking up my changes

Make sure you restart your instance with `docker compose down; docker compose up` after making any changes to your config file.

If you're running with `docker compose up` and you're trying to change the code, then you have to rebuild the Docker image for it to pick up your changes. It's easier to run with `bin/dev up` so that you don't have to rebuild the image every time you make a change. See the [Running Danbooru](#running-danbooru) section above.

# References

* https://www.docker.com/get-started/
* https://docs.docker.com/compose/install/
* https://docs.docker.com/compose/reference/
* https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04
