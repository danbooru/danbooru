[<img src="https://github.com/codespaces/badge.svg" height="20">](https://codespaces.new/danbooru/danbooru?quickstart=1) [![Discord](https://img.shields.io/discord/310432830138089472?label=Discord)](https://discord.gg/danbooru) [![codecov](https://codecov.io/gh/danbooru/danbooru/branch/master/graph/badge.svg)](https://codecov.io/gh/danbooru/danbooru)

## Quickstart

### Using Github Codespaces

To launch a Danbooru instance in your browser:

1. [Create a Github account](https://github.com/signup).
2. Click [Open in Github Codespaces](https://codespaces.new/danbooru/danbooru?quickstart=1).
3. Click the `Create new codespace` button.
4. Wait a few minutes for it to launch.

When it's done, you'll have a new Danbooru instance with a full development environment running in your browser. This way you can try out Danbooru without installing anything on your computer.

See the [Codespaces section](https://github.com/danbooru/danbooru/wiki/Docker-Guide#user-content-running-in-github-codespaces) in the [Docker Guide](https://github.com/danbooru/danbooru/wiki/Docker-Guide) to learn more.

### Using Docker

Run this to start a Danbooru instance:

```sh
sh -c "$(curl -sSL https://raw.githubusercontent.com/danbooru/danbooru/master/bin/setup)"
```

This will install [Docker Compose](https://docs.docker.com/compose/) and start Danbooru. When it's done, Danbooru will be running at http://localhost:3000.

Alternatively, if you already have Docker Compose installed, you can do:

```sh
git clone http://github.com/danbooru/danbooru
cd danbooru
touch .env.local config/danbooru_local_config.rb
sudo docker compose up
```

When you're done, you can run the following to delete everything:

```sh
sudo docker compose down --volumes # Delete all data and images in your Danbooru instance.
sudo docker image prune            # Clean up all unused Docker images.
rm -rf ~/danbooru                  # Delete the Danbooru code.
```

## Installation

See the [Docker Guide](https://github.com/danbooru/danbooru/wiki/Docker-Guide) for more information on running Danbooru using Docker. This is the recommended way to run Danbooru.

Alternatively, you may use the [Manual Installation Guide](https://github.com/danbooru/danbooru/wiki/Manual-Installation-Guide) to install Danbooru without Docker. Manual installation is much more difficult than using Docker, and therefore is not recommended or officially supported.

For help, ask in the [#technical](https://discord.com/channels/310432830138089472/310846683376517121) channel on the [Danbooru Discord](https://discord.gg/danbooru), or in the [discussions area](https://github.com/danbooru/danbooru/discussions) on Github.

## Services

Danboou depends on a couple of cloud services and several microservices to
implement certain features.

### Amazon Web Services

In the production environment, for historical reasons, Danbooru relies on Amazon AWS to send pool/post versions to a SQS queue, and on a separate archives service ([available here](https://github.com/danbooru/archives/)) to extract the versions from that queue and insert them into a database.

The Docker Compose files in this repository come with a preconfigured archives service and an SQS mock using [ElasticMQ](https://github.com/softwaremill/elasticmq), so following the docker tutorial at the start of this file is sufficient to have post/pool versions working for a new instance.

### Google APIs

The following features require a Google Cloud account:

* BigQuery database export

### IQDB Service

IQDB integration is delegated to the [IQDB service](https://github.com/danbooru/iqdb).

### Reportbooru Service

The following features are delegated to the [Reportbooru service](https://github.com/danbooru/reportbooru):

* Post views
* Missed searches report
* Popular searches report

### Recommender Service

Post recommendations require the [Recommender service](https://github.com/danbooru/recommender).
