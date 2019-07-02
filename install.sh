#!/bin/bash

# Run: curl -L -s https://raw.githubusercontent.com/r888888888/danbooru/master/INSTALL.debian -o install.sh ; chmod +x install.sh ; ./install.sh

export RUBY_VERSION=2.5.1
export GITHUB_INSTALL_SCRIPTS=https://raw.githubusercontent.com/kdoshere/booru/master/script/install
export GITHUB_ENV=https://raw.githubusercontent.com/kdoshere/booru/master
export VIPS_VERSION=8.7.0

if [[ "$(whoami)" != "root" ]] ; then
  echo "You must run this script as root"
  exit 1
fi

verlte() {
  [ "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

verlt() {
  [ "$1" = "$2" ] && return 1 || verlte $1 $2
}

echo "* DANBOORU INSTALLATION SCRIPT"
echo "*"
echo "* This script will install all the necessary packages to run Danbooru."
echo
echo -n "* Enter the hostname for this server (ex: danbooru.donmai.us): "
read HOSTNAME

if [[ -z "$HOSTNAME" ]] ; then
  echo "* Must enter a hostname"
  exit 1
fi

# Install packages
echo "* Installing packages..."

if [ -n "$(uname -a | grep Ubuntu)" ] ; then
  LIBSSL_DEV_PKG=libssl-dev
else
  LIBSSL_DEV_PKG=$( verlt `lsb_release -sr` 9.0 && echo libssl-dev || echo libssl1.0-dev )
fi
apt-get update
apt-get -y install $LIBSSL_DEV_PKG build-essential automake libxml2-dev libxslt-dev ncurses-dev sudo libreadline-dev flex bison ragel memcached libmemcached-dev git curl libcurl4-openssl-dev sendmail-bin sendmail nginx ssh coreutils ffmpeg mkvtoolnix
apt-get -y install libpq-dev postgresql-client postgresql postgresql-server-dev-10 redis-server
apt-get -y install liblcms2-dev libjpeg-turbo8-dev libexpat1-dev libgif-dev libpng-dev libexif-dev

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
curl -sSL https://deb.nodesource.com/setup_10.x | sudo -E bash -
apt-get update
apt-get remove cmdtest
apt-get -y install nodejs yarn

if [ $? -ne 0 ]; then
  echo "* Error installing packages; aborting"
  exit 1
fi

# compile and install libvips (the version in apt is too old)
cd /tmp
wget -q https://github.com/libvips/libvips/releases/download/v$VIPS_VERSION/vips-$VIPS_VERSION.tar.gz
tar xzf vips-$VIPS_VERSION.tar.gz
cd vips-$VIPS_VERSION
./configure --prefix=/usr
make install
ldconfig

# Create user account
useradd -m danbooru
chsh -s /bin/bash danbooru
usermod -G danbooru,sudo danbooru

# Set up Postgres
export PG_VERSION=`pg_config --version | egrep -o '[0-9]{1,}\.[0-9]{1,}'`
if verlte 9.5 $PG_VERSION ; then
  # only do this on postgres 9.5 and above
  git clone https://github.com/r888888888/test_parser.git /tmp/test_parser
  cd /tmp/test_parser
  make install
fi

# Install rbenv
echo "* Installing rbenv..."
cd /
sudo -i -u danbooru git clone git://github.com/sstephenson/rbenv.git ~danbooru/.rbenv
sudo -i -u danbooru touch ~danbooru/.bash_profile
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~danbooru/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~danbooru/.bash_profile
sudo -i -u danbooru mkdir -p ~danbooru/.rbenv/plugins
sudo -i -u danbooru git clone https://github.com/rbenv/ruby-build.git ~danbooru/.rbenv/plugins/ruby-build
sudo -i -u danbooru bash -l -c "rbenv install $RUBY_VERSION"
sudo -i -u danbooru bash -l -c "rbenv global $RUBY_VERSION"

# Generate secret token and secret key
echo "* Generating secret keys..."
sudo -i -u danbooru mkdir ~danbooru/.danbooru/
openssl rand -hex 32 > ~danbooru/.danbooru/secret_token
openssl rand -hex 32 > ~danbooru/.danbooru/session_secret_key
chown danbooru:danbooru ~danbooru/.danbooru/*
chmod 600 ~danbooru/.danbooru/*

# Install gems
echo "* Installing gems..."
sudo -i -u danbooru bash -l -c 'gem install --no-ri --no-rdoc bundler'

echo "* Install configuration scripts..."

# Update PostgreSQL
curl -L -s $GITHUB_INSTALL_SCRIPTS/postgresql_hba_conf -o /etc/postgresql/$PG_VERSION/main/pg_hba.conf
/etc/init.d/postgresql restart
sudo -u postgres createuser -s danbooru
sudo -i -u postgres createdb danbooru2

# Setup nginx
curl -L -s $GITHUB_INSTALL_SCRIPTS/nginx.danbooru.conf -o /etc/nginx/sites-enabled/danbooru.conf
sed -i -e "s/__hostname__/$HOSTNAME/g" /etc/nginx/sites-enabled/danbooru.conf
/etc/init.d/nginx restart

# Setup logrotate
curl -L -s $GITHUB_INSTALL_SCRIPTS/danbooru_logrotate_conf -o /etc/logrotate.d/danbooru.conf

# Setup danbooru account
echo "* Enter a new password for the danbooru account"
passwd danbooru

echo "* Setting up SSH keys for the danbooru account"
sudo -i -u danbooru ssh-keygen

sudo -i -u danbooru git clone https://github.com/kdoshere/booru.git ~danbooru/danbooru
mkdir -p /var/www/danbooru/shared/config
mkdir -p /var/www/danbooru/shared/data
mkdir -p /var/www/danbooru/shared/data/preview
mkdir -p /var/www/danbooru/shared/data/sample
curl -L -s $GITHUB_INSTALL_SCRIPTS/database.yml.templ -o /var/www/danbooru/shared/config/database.yml
curl -L -s $GITHUB_INSTALL_SCRIPTS/danbooru_local_config.rb.templ -o /var/www/danbooru/shared/config/danbooru_local_config.rb
curl -L -s $GITHUB_ENV/.env -o /var/www/danbooru/shared/.env.production
chown -R danbooru:danbooru /var/www/danbooru
