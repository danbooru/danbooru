[![codecov](https://codecov.io/gh/danbooru/danbooru/branch/master/graph/badge.svg)](https://codecov.io/gh/danbooru/danbooru) [![Discord](https://img.shields.io/discord/310432830138089472?label=Discord)](https://discord.gg/eSVKkUF)

## Quickstart

Run this to start a basic Danbooru instance:

```sh
curl -sSL https://raw.githubusercontent.com/danbooru/danbooru/master/bin/danbooru | sh
```

This will install [Docker Compose](https://docs.docker.com/compose/) and use it
to start Danbooru. When it's done, Danbooru will be running at http://localhost:3000.

Alternatively, if you already have Docker Compose installed, you can just do:

```sh
wget https://raw.githubusercontent.com/danbooru/danbooru/master/docker-compose.yaml
docker-compose up
```

## Manual Server Installation

Follow the [INSTALL.debian](INSTALL.debian) script to install Danbooru.

The INSTALL.debian script is written for Debian, but can be adapted for other
distributions. Danbooru has been successfully installed on Debian, Ubuntu,
Fedora, Arch, and OS X. It is recommended that you use an Ubuntu-based system
since Ubuntu is what is used in development and production.

See [here](https://github.com/danbooru/danbooru/wiki/Ubuntu-Installation-Help-Guide)
for a guide on how set up Danbooru inside a virtual machine.

For best performance, you will need at least 256MB of RAM for PostgreSQL and
Rails. The memory requirement will grow as your database gets bigger.

In production, Danbooru uses PostgreSQL 10.18, but any release later than this should work.

## Running Locally

### Prerequisites

1) Install Ruby (preferably `3.1.0` via a version manager like [rbenv](https://github.com/rbenv/rbenv))

2) Make sure you have PostgreSQL 10.18 or above installed.

3) Install `glib` and `libvips`.

  * In MacOS, you can install these libraries via homebrew `brew install glib vips`

  * For Ubuntu and other Debian based distros, install via apt `sudo apt-get install libglib2.0-dev libvips`

4) Make sure you have [yarn](https://classic.yarnpkg.com/lang/en/docs/install) installed.

### Installation

1) Clone this project and enter its directory.

```shell
git clone https://github.com/danbooru/danbooru.git
cd danbooru
```

2) Set the database username and password in the `.env` file eg:

```
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=
```

2) Install ruby dependencies

```shell
bundle install
```

4) Install node dependencies via yarn

```shell
yarn install
```

5) Create the database and migrate

```shell
rails db:create db:migrate
```

6) Start the server!

```shell
rails s
```

Open [localhost:3000](http://localhost:3000) in your favorite browser.

Trouble with installation? Here's a [video](videolink).

## Troubleshooting

If your setup is not working, here are the steps I usually recommend to people:

1) Test the database. Make sure you can connect to it using `psql`. Make
sure the tables exist. If this fails, you need to work on correctly
installing PostgreSQL, importing the initial schema, and running the
migrations.

2) Test the Rails database connection by using `bin/rails console`. Run
`Post.count` to make sure Rails can connect to the database. If this
fails, you need to make sure your Danbooru configuration files are
correct.

3) Test Nginx to make sure it's working correctly.  You may need to
debug your Nginx configuration file.

4) Check all log files.

## Services

Danboou depends on a couple of cloud services and several microservices to
implement certain features.

### Amazon Web Services

The following features require an Amazon AWS account:

* Pool history
* Post history

### Google APIs

The following features require a Google Cloud account:

* BigQuery database export

### IQDB Service

IQDB integration is delegated to the [IQDB service](https://github.com/danbooru/iqdb).

### Archive Service

In order to access pool and post histories you will need to install and
configure the [Archives service](https://github.com/danbooru/archives).

### Reportbooru Service

The following features are delegated to the [Reportbooru service](https://github.com/danbooru/reportbooru):

* Post views
* Missed searches report
* Popular searches report

### Recommender Service

Post recommendations require the [Recommender service](https://github.com/danbooru/recommender).
