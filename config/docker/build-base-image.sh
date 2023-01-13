#!/usr/bin/env bash

set -xeuo pipefail

RUBY_VERSION="${RUBY_VERSION:-3.2.0}"
VIPS_VERSION="${VIPS_VERSION:-8.14.1}"
FFMPEG_VERSION="${FFMPEG_VERSION:-5.1.2}"
MOZJPEG_VERSION="${MOZJPEG_VERSION:-4.1.1}"
EXIFTOOL_VERSION="${EXIFTOOL_VERSION:-12.50}"
OPENRESTY_VERSION="${OPENRESTY_VERSION:-1.21.4.1}"
POSTGRESQL_CLIENT_VERSION="${POSTGRESQL_CLIENT_VERSION:-14}"

COMMON_BUILD_DEPS="
  curl ca-certificates build-essential pkg-config git
"
RUBY_BUILD_DEPS="rustc libssl-dev zlib1g-dev libgmp-dev libyaml-dev libffi-dev libreadline-dev"
FFMPEG_BUILD_DEPS="libvpx-dev libdav1d-dev nasm"
MOZJPEG_BUILD_DEPS="cmake nasm libpng-dev zlib1g-dev"
VIPS_BUILD_DEPS="
  meson libgirepository1.0-dev
  libfftw3-dev libwebp-dev liborc-dev liblcms2-dev libpng-dev
  libexpat1-dev libglib2.0-dev libgif-dev libexif-dev libheif-dev
"
EXIFTOOL_RUNTIME_DEPS="perl perl-modules libarchive-zip-perl"
DANBOORU_RUNTIME_DEPS="
  ca-certificates mkvtoolnix rclone libpq5 openssl libgmpxx4ldbl
  zlib1g libfftw3-3 libwebp7 libwebpmux3 libwebpdemux2 liborc-0.4.0 liblcms2-2
  libpng16-16 libexpat1 libglib2.0 libgif7 libexif12 libheif1 libvpx7 libdav1d6
  libseccomp2 libseccomp-dev libjemalloc2 libarchive13 libyaml-0-2 libffi8 libreadline8
"
COMMON_RUNTIME_DEPS="
  $DANBOORU_RUNTIME_DEPS $EXIFTOOL_RUNTIME_DEPS tini busybox less ncdu
"

apt_install() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

install_asdf() {
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf
}

install_mozjpeg() {
  apt_install $MOZJPEG_BUILD_DEPS

  MOZJPEG_URL="https://github.com/mozilla/mozjpeg/archive/refs/tags/v${MOZJPEG_VERSION}.tar.gz"
  curl -L "$MOZJPEG_URL" | tar -C /usr/local/src -xzvf -
  cd /usr/local/src/mozjpeg-${MOZJPEG_VERSION}

  mkdir build
  cd build
  cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..
  make -j "$(nproc)"
  make install
  ldconfig

  cjpeg -version
}

install_vips() {
  apt_install $VIPS_BUILD_DEPS

  VIPS_URL="https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.xz"
  curl -L "$VIPS_URL" | tar -C /usr/local/src -xJvf -
  cd /usr/local/src/vips-${VIPS_VERSION}

  meson build --prefix /usr/local --buildtype release
  cd build
  meson compile
  meson install
  ldconfig

  vips --version
}

install_ffmpeg() {
  apt_install $FFMPEG_BUILD_DEPS

  FFMPEG_URL="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n${FFMPEG_VERSION}.tar.gz"
  curl -L "$FFMPEG_URL" | tar -C /usr/local/src -xzvf -
  cd /usr/local/src/FFmpeg-n${FFMPEG_VERSION}

  ./configure --disable-ffplay --disable-network --disable-doc --enable-libvpx --enable-libdav1d
  make -j "$(nproc)"
  cp ffmpeg ffprobe /usr/local/bin

  ffmpeg -version
  ffprobe -version
}

# https://github.com/exiftool/exiftool/blob/master/README
# Optional dependencies: Compress::Zlib (for SWF files), Archive::Zip (ZIP), Digest::MD5
install_exiftool() {
  EXIFTOOL_URL="https://github.com/exiftool/exiftool/archive/refs/tags/${EXIFTOOL_VERSION}.tar.gz"
  curl -L "$EXIFTOOL_URL" | tar -C /usr/local/src -xzvf -
  cd /usr/local/src/exiftool-${EXIFTOOL_VERSION}

  perl Makefile.PL
  make -j "$(nproc)" install

  exiftool -ver
  perl -e 'require Compress::Zlib' || exit 1
  perl -e 'require Archive::Zip' || exit 1
  perl -e 'require Digest::MD5' || exit 1
}

install_ruby() {
  apt_install $RUBY_BUILD_DEPS

  asdf plugin add ruby
  RUBY_BUILD_OPTS="--verbose" RUBY_CONFIGURE_OPTS="--disable-install-doc --enable-yjit" asdf install ruby "$RUBY_VERSION"
  asdf global ruby "$RUBY_VERSION"

  ruby --version
}

install_openresty() {
  apt_install libpcre++-dev

  OPENRESTY_URL="https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz"
  curl -L "$OPENRESTY_URL" | tar -C /usr/local/src -xzvf -
  cd /usr/local/src/openresty-${OPENRESTY_VERSION}

  # https://github.com/openresty/docker-openresty/blob/master/alpine/Dockerfile
  ./configure -j$(nproc) --prefix=/usr/local \
    --with-threads --with-compat --with-pcre-jit --with-file-aio \
    --with-http_gunzip_module --with-http_gzip_static_module \
    --with-http_realip_module --with-http_ssl_module \
    --with-http_stub_status_module --with-http_v2_module
  make -j $(nproc)
  make install
}

install_postgresql_client() {
  apt_install gnupg

  . /etc/lsb-release
  curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > /usr/share/keyrings/postgresql.gpg
  echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt $DISTRIB_CODENAME-pgdg main" > /etc/apt/sources.list.d/pgdg.list

  apt-get update
  apt_install postgresql-client-${POSTGRESQL_CLIENT_VERSION}
}

install_foreman() {
  gem install foreman
}

install_busybox() {
  busybox --install -s
}

cleanup() {
  apt-get purge -y $RUBY_BUILD_DEPS $VIPS_BUILD_DEPS $FFMPEG_BUILD_DEPS
  apt-get purge -y --allow-remove-essential \
    build-essential pkg-config e2fsprogs git libglib2.0-bin libglib2.0-doc \
    mount procps python3 tzdata
  apt-get autoremove -y

  rm -rf \
    /var/lib/apt/lists/* \
    /var/log/* \
    /usr/local/share/gtk-doc \
    /usr/local/src \
    /usr/share/doc/* \
    /usr/share/info/* \
    /usr/share/gtk-doc

  cd /
}

apt-get update
apt_install $COMMON_BUILD_DEPS $COMMON_RUNTIME_DEPS
install_asdf
install_exiftool
install_mozjpeg
install_ffmpeg
install_vips
install_ruby
install_openresty
install_postgresql_client
install_foreman
cleanup
install_busybox # after cleanup so we can install some utils removed by cleanup
