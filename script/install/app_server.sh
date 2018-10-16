#!/bin/bash

# this is a version of the install script designed to be run on
# app servers (that is, they won't install PostgreSQL server).
#
# Run: curl -L -s https://raw.githubusercontent.com/r888888888/danbooru/master/script/install/app_server.sh | sh

export RUBY_VERSION=2.5.1
export GITHUB_INSTALL_SCRIPTS=https://raw.githubusercontent.com/r888888888/danbooru/master/script/install
export VIPS_VERSION=8.7.0

if [[ "$(whoami)" != "root" ]] ; then
  echo "You must run this script as root"
  exit 1
fi

echo "* DANBOORU INSTALLATION SCRIPT"
echo "*"
echo "* This script will install all the necessary packages to run Danbooru on an"
echo "* Ubuntu server."
echo

echo -n "* Enter the VLAN IP address for this server: "
read VLAN_IP_ADDR

# Install packages
echo "* Installing packages..."

apt-get update
apt-get -y install libssl-dev build-essential automake libxml2-dev libxslt-dev ncurses-dev sudo libreadline-dev flex bison ragel memcached libmemcached-dev git curl libcurl4-openssl-dev sendmail-bin sendmail nginx ssh coreutils ffmpeg mkvtoolnix
apt-get -y install libpq-dev postgresql-client
apt-get -y install liblcms2-dev libjpeg-turbo8-dev libexpat1-dev libgif-dev libpng-dev libexif-dev

# vrack specific stuff
apt-get -y install vlan
modprobe 8021q
echo "8021q" >> /etc/modules
vconfig add eno2 99
ip addr add $VLAN_IP_ADDR/24 dev eno2.99
ip link set up eno2.99
curl -L -s $GITHUB_INSTALL_SCRIPTS/vrack-cfg.yaml -o /etc/netplan/01-netcfg.yaml

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
curl -sSL https://deb.nodesource.com/setup_10.x | sudo -E bash -
apt-get update
apt-get -y install nodejs yarn
apt-get remove cmdtest

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
git clone https://github.com/r888888888/test_parser.git /tmp/test_parser
cd /tmp/test_parser
make install

# Install rbenv
echo "* Installing rbenv..."
cd /tmp
sudo -u danbooru git clone git://github.com/sstephenson/rbenv.git ~danbooru/.rbenv
sudo -u danbooru touch ~danbooru/.bash_profile
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~danbooru/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~danbooru/.bash_profile
sudo -u danbooru mkdir -p ~danbooru/.rbenv/plugins
sudo -u danbooru git clone git://github.com/sstephenson/ruby-build.git ~danbooru/.rbenv/plugins/ruby-build
sudo -u danbooru bash -l -c "rbenv install $RUBY_VERSION"
sudo -u danbooru bash -l -c "rbenv global $RUBY_VERSION"

# Install gems
echo "* Installing gems..."
sudo -u danbooru bash -l -c 'gem install --no-ri --no-rdoc bundler'

# Setup danbooru account
echo "* Enter a new password for the danbooru account"
passwd danbooru

echo "* Setting up SSH keys for the danbooru account"
sudo -u danbooru ssh-keygen
sudo -u danbooru cat ~danbooru/.ssh/id_rsa.pub >> ~danbooru/.ssh/authorized_keys

echo "* TODO:"
echo "on kagamihara:"
echo "script/install/distribute_new_pubkey.sh"
echo
echo "on this server:"
echo "rsync -av kagamihara:/etc/nginx/nginx.conf /etc/nginx"
echo "rsync -av kagamihara:/etc/nginx/conf.d /etc/nginx"
echo "rsync -av kagamihara:/etc/nginx/sites-enabled /etc/nginx"
echo "rsync -av kagamihara:/etc/logrotate.d /etc/logrotate.d"
