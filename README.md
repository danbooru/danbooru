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

If you get an error such as `'name' does not match any of the regexes: '^x-'` make sure 
that you're running an updated version of Docker Compose.

## Manual Installation

See [here](https://github.com/danbooru/danbooru/wiki/Ubuntu-Installation-Help-Guide)
for a guide on how set up Danbooru inside a virtual machine. Note that this
is a deprecated method, and that Docker is the only supported way to run this software.

You can also follow the [INSTALL.debian](INSTALL.debian) script to install Danbooru.
This script is written for Debian, but can be adapted for other
distributions. Danbooru has been successfully installed on Debian, Ubuntu,
Fedora, Arch, and OS X.

In production, Danbooru uses PostgreSQL 14.1, but any release later than this
should work.

If your manual installation is not working, here are the steps we usually recommend:

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
