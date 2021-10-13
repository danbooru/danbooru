# Usage: run `gem install foreman` then run `foreman start`. This will start
# all the processes needed to run Danbooru in a dev environment.
#
# Uncomment the `db` line to start a database (assuming you have Docker and
# don't have another database already running).
#
# http://blog.daviddollar.org/2011/05/06/introducing-foreman.html
# https://github.com/ddollar/foreman

web: bin/rails server
worker: bin/rails jobs:work
clock: bin/rails danbooru:cron
webpack-dev-server: bin/webpack-dev-server
# db: docker run --rm -it --name danbooru-postgres --shm-size=8g -p 5432:5432 -e POSTGRES_USER=danbooru - e POSTRES_HOST_AUTH_METHOD=trust -v danbooru-postgres:/var/lib/postgresql/data ghcr.io/danbooru/postgres:14.0
