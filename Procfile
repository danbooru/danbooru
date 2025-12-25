# Usage: run `gem install foreman` then run `foreman start`. This will start
# all the processes needed to run Danbooru in a dev environment.
#
# Uncomment the `db` line to start a database (assuming you have Docker and
# don't have another database already running).
#
# http://blog.daviddollar.org/2011/05/06/introducing-foreman.html
# https://github.com/ddollar/foreman

# The main webserver. See config/puma.rb and https://github.com/puma/puma.
# unset PORT to workaround a Puma+Foreman issue (https://github.com/puma/puma/issues/1771)
web: unset PORT && bin/rails server

# The background job worker. See app/jobs/ and https://github.com/bensheldon/good_job.
worker: bin/good_job start

# The cron job worker. See config/initializers/clockwork.rb and https://github.com/Rykian/clockwork.
clock: bin/rails danbooru:cron

# The Javascript bundler. Rebuilds Javascript/CSS files when they change. See
# config/shakapacker.yml and https://webpack.js.org/configuration/dev-server.
shakapacker-dev-server: bin/shakapacker-dev-server

# The postgres database. It can be run in the Procfile, but it's better to run it manually.
# db: docker run --rm -it --name danbooru-postgres --shm-size=8g -p 5432:5432 -e POSTGRES_USER=danbooru - e POSTRES_HOST_AUTH_METHOD=trust -v danbooru-postgres:/var/lib/postgresql/data ghcr.io/danbooru/postgres:14.1
