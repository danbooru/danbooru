[![codecov](https://codecov.io/gh/danbooru/danbooru/branch/master/graph/badge.svg)](https://codecov.io/gh/danbooru/danbooru) [![Discord](https://img.shields.io/discord/310432830138089472?label=Discord)](https://discord.gg/eSVKkUF)

## Installation

It is recommended that you install Danbooru on a Debian-based system
since most of the required packages are available on APT. Danbooru
has been successfully installed on Fedora, CentOS, FreeBSD, and OS X.
The INSTALL.debian install script is straightforward and should be
simple to adapt for other platforms.

For best performance, you will need at least 256MB of RAM for
PostgreSQL and Rails. The memory requirement will grow as your
database gets bigger. 

On production Danbooru uses PostgreSQL 9.4, but any 9.x release should
work.

Use your operating system's package management system whenever
possible.  This will simplify the process of installing init scripts,
which will not always happen when compiling from source.

## Troubleshooting

These instructions won't work for everyone. If your setup is not
working, here are the steps I usually recommend to people:

1) Test the database. Make sure you can connect to it using psql. Make
sure the tables exist. If this fails, you need to work on correctly
installing PostgreSQL, importing the initial schema, and running the
migrations.

2) Test the Rails database connection by using rails console. Run
Post.count to make sure Rails can connect to the database. If this
fails, you need to make sure your Danbooru configuration files are
correct.

3) Test Nginx to make sure it's working correctly.  You may need to
debug your Nginx configuration file.

4) Check all log files.

## Services

Danbooru employs numerous external services to delegate some 
functionality.

For development purposes, you can just run mocked version of these
services. They're available in `scripts/mock_services` and can be started
automatically using Foreman and the provided Procfile.

### Amazon Web Services

In order to enable the following features, you will need an AWS SQS 
account:

* Pool versions
* Post versions
* IQDB
* Saved searches
* Related tags

### Google APIs

The following features requires a Google API account:

* Bulk revert
* Post versions report

### IQDB Service

IQDB integration is delegated to the [IQDBS service](https://github.com/r888888888/iqdbs). 

### Archive Service

In order to access versioned data for pools and posts you will 
need to install and configure the [Archives service](https://github.com/r888888888/archives).

### Reportbooru Service

The following features are delegated to the [Reportbooru service](https://github.com/r888888888/reportbooru):

* Related tags
* Missed searches report
* Popular searches report
* Favorite searches
* Upload trend graphs

### Recommender Service

Post recommendations require the [Recommender service](https://github.com/r888888888/recommender).

### Cropped Thumbnails

There's optional support for cropped thumbnails. This relies on installing
`libvips-8.6` or higher and setting `Danbooru.config.enable_image_cropping`
to true.
