# syntax=docker/dockerfile:1

# Build:
#
#   git archive HEAD | docker buildx build - --tag danbooru --load --build-arg SOURCE_COMMIT=$(git rev-parse HEAD)
#
# Run:
#
#   # Run the Danbooru webserver. Run Postgres first because a database is necessary for Danbooru to function.
#   docker run --rm -it --network host -e POSTGRES_USER=danbooru -e POSTGRES_HOST_AUTH_METHOD=trust -v $PWD/danbooru-postgres:/var/lib/postgresql/data ghcr.io/danbooru/postgres:14.1 -c listen_addresses=localhost
#   docker run --rm -it --network host -v $PWD:/danbooru danbooru
#
#   # Run a Bash or Ruby shell inside the Danbooru container (for development or debugging).
#   docker run --rm -it --network host -v $PWD:/danbooru danbooru bash
#   docker run --rm -it --network host -v $PWD:/danbooru danbooru bin/rails console
#
# See https://github.com/danbooru/danbooru/wiki/Docker-Guide for more details.

ARG MOZJPEG_URL="https://github.com/mozilla/mozjpeg/archive/refs/tags/v4.1.5.tar.gz"
ARG VIPS_URL="https://github.com/libvips/libvips/releases/download/v8.14.2/vips-8.14.2.tar.xz"
ARG FFMPEG_URL="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n6.1.1.tar.gz"
ARG EXIFTOOL_URL="https://github.com/exiftool/exiftool/archive/refs/tags/12.70.tar.gz"
ARG OPENRESTY_URL="https://openresty.org/download/openresty-1.25.3.1.tar.gz"
ARG RUBY_URL="https://cache.ruby-lang.org/pub/ruby/3.3/ruby-3.3.2.tar.gz"
ARG RUBY_MINOR_VERSION="3.3.0"
ARG NODE_VERSION="20.x"
ARG UBUNTU_VERSION="24.04"


# The base layer for everything.
FROM ubuntu:$UBUNTU_VERSION AS base
SHELL ["/bin/bash", "-xeuo", "pipefail", "-O", "globstar", "-O", "dotglob", "-c"]

ARG RUBY_MINOR_VERSION
ENV DEBIAN_FRONTEND="noninteractive"
ENV LANG=C.UTF-8
ENV GEM_HOME=/home/danbooru/bundle
ENV GEM_PATH=/home/danbooru/bundle/ruby/$RUBY_MINOR_VERSION:/usr/local/lib/ruby/gems/$RUBY_MINOR_VERSION
ENV PATH=$GEM_HOME/bin:$PATH

RUN <<EOS
  userdel ubuntu
  useradd --user-group danbooru --create-home --shell /bin/bash

  cat > /etc/apt/apt.conf.d/local <<EOF
    Dpkg::Options {
      "--force-confnew";
      "--force-confdef";
    }
EOF

  apt-get update
  apt-get install -y --no-install-recommends \
    postgresql-client ca-certificates mkvtoolnix rclone openssl perl perl-modules-5.38 libpq5 libpcre3 libsodium23 \
    libgmpxx4ldbl zlib1g libfftw3-bin libwebp7 libwebpmux3 libwebpdemux2 liborc-0.4.0t64 liblcms2-2 libpng16-16 libexpat1 \
    libglib2.0-0 libgif7 libexif12 libheif1 libvpx9 libdav1d7 libseccomp-dev libjemalloc2 libarchive13 libyaml-0-2 libffi8 \
    libreadline8t64 libarchive-zip-perl tini busybox less ncdu curl

  apt-get purge -y --allow-remove-essential pkg-config e2fsprogs mount procps python3 tzdata
  apt-get autoremove -y
  rm -rf /etc/gnutls/config /var/{lib,cache,log} /usr/share/{doc,info}/* /usr/local/*
  mkdir -p /var/{lib,cache,log}/apt /var/lib/dpkg

  busybox --install -s
EOS



# The base layer for building dependencies. All builds take place inside /build.
FROM base AS build-base
WORKDIR /build

RUN <<EOS
  apt-get update
  apt-get install -y --no-install-recommends ca-certificates g++ make pkg-config git
EOS



# Build Ruby. Output is in /usr/local.
FROM build-base AS build-ruby
ARG RUBY_BUILD_DEPS="rustc libssl-dev libgmp-dev libyaml-dev libffi-dev libreadline-dev zlib1g-dev"
ARG RUBY_URL
RUN <<EOS
  apt-get install -y --no-install-recommends $RUBY_BUILD_DEPS
  curl -L $RUBY_URL | tar --strip-components=1 -xzvf -

  ./configure --enable-yjit --enable-shared --disable-install-doc
  make -j install

  find /usr/local -type f -executable -exec strip --strip-unneeded {} \;
  rm -rf *

  ruby --version
EOS



# Build MozJPEG. Output is in /usr/local.
FROM build-base AS build-mozjpeg
ARG MOZJPEG_BUILD_DEPS="cmake nasm libpng-dev zlib1g-dev"
ARG MOZJPEG_URL
RUN <<EOS
  apt-get install -y --no-install-recommends $MOZJPEG_BUILD_DEPS
  curl -L $MOZJPEG_URL | tar --strip-components=1 -xzvf -

  cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DENABLE_STATIC=0 -DWITH_ARITH_ENC=1 -DWITH_ARITH_DEC=1 .
  make -j install/strip

  rm -rf * /usr/local/share /usr/local/man

  cjpeg -version
EOS



# Build libvips. Output is in /usr/local.
FROM build-mozjpeg AS build-vips
ARG VIPS_BUILD_DEPS="meson libgirepository1.0-dev libfftw3-dev libwebp-dev liborc-dev liblcms2-dev libpng-dev libexpat1-dev libglib2.0-dev libgif-dev libexif-dev libheif-dev"
ARG VIPS_URL
RUN <<EOS
  apt-get install -y --no-install-recommends $VIPS_BUILD_DEPS
  curl -L $VIPS_URL | tar --strip-components=1 -xJvf -

  meson build --prefix /usr/local --buildtype release --strip -Dcplusplus=false
  meson compile -C build
  meson install -C build

  rm -rf * /usr/local/share /usr/local/man

  ldconfig
  vips --version
EOS



# Build FFmpeg. Output is in /usr/local.
FROM build-base AS build-ffmpeg
ARG FFMPEG_URL
ARG FFMPEG_BUILD_DEPS="nasm libvpx-dev libdav1d-dev zlib1g-dev"
ARG FFMPEG_BUILD_OPTIONS="\
  --disable-ffplay --disable-network --disable-doc --disable-static --enable-shared \
  --enable-libvpx --enable-libdav1d --enable-zlib \
  --disable-muxers \
    --enable-muxer=mp4 --enable-muxer=webm --enable-muxer=image2 --enable-muxer=null \
  --disable-demuxers \
    --enable-demuxer=mov,mp4,m4a,3gp,3g2,mj2 --enable-demuxer=matroska,webm --enable-demuxer=image2 \
    --enable-demuxer=apng --enable-demuxer=gif \
  --disable-filters \
    --enable-filter=scale --enable-filter=thumbnail --enable-filter=silencedetect --enable-filter=ebur128 \
    --enable-filter=aresample --enable-filter=anull --enable-filter=null --enable-filter=copy \
  --disable-encoders \
    --enable-encoder=libvpx_vp8 --enable-encoder=libvpx_vp9 --enable-encoder=png --enable-encoder=null \
    --enable-encoder=wrapped_avframe --enable-encoder=pcm_s16le \
  --disable-decoders \
    --enable-decoder=vp8 --enable-decoder=vp9 --enable-decoder=h264 --enable-decoder=hevc --enable-decoder=libdav1d \
    --enable-decoder=mpeg4 --enable-decoder=mjpeg --enable-decoder=png --enable-decoder=apng --enable-decoder=gif \
    --enable-decoder=webp --enable-decoder=aac --enable-decoder=mp3 --enable-decoder=mp2 --enable-decoder=opus \
    --enable-decoder=vorbis --enable-decoder=ac3 \
  --disable-protocols \
    --enable-protocol=file \
  --disable-bsfs \
"

RUN <<EOS
  apt-get install -y --no-install-recommends $FFMPEG_BUILD_DEPS
  curl -L $FFMPEG_URL | tar --strip-components=1 -xzvf -

  ./configure $FFMPEG_BUILD_OPTIONS
  make -j install

  rm -rf * /usr/local/include /usr/local/share

  ldconfig
  ffmpeg -version
  ffprobe -version
EOS



# Build ExifTool. Output is in /usr/local.
FROM build-base AS build-exiftool
ARG EXIFTOOL_BUILD_DEPS="perl perl-modules-5.38 libarchive-zip-perl"
ARG EXIFTOOL_URL
RUN <<EOS
  apt-get install -y --no-install-recommends $EXIFTOOL_BUILD_DEPS
  curl -L $EXIFTOOL_URL | tar --strip-components=1 -xzvf -

  perl Makefile.PL
  make -j install

  rm -rf * /usr/local/man /usr/local/share/**/*.pod

  exiftool -ver
  perl -e 'require Compress::Zlib'
  perl -e 'require Archive::Zip'
  perl -e 'require Digest::MD5'
EOS



# Build OpenResty. Output is in /usr/local.
FROM build-base AS build-openresty
ARG OPENRESTY_URL
ARG OPENRESTY_BUILD_DEPS="libssl-dev libpcre3-dev zlib1g-dev"
ARG OPENRESTY_BUILD_OPTIONS="\
 --with-threads --with-compat --with-pcre-jit --with-file-aio \
 --with-http_gunzip_module --with-http_gzip_static_module \
 --with-http_realip_module --with-http_ssl_module \
 --with-http_stub_status_module --with-http_v2_module \
"

RUN <<EOS
  apt-get install -y --no-install-recommends $OPENRESTY_BUILD_DEPS
  curl -L $OPENRESTY_URL | tar --strip-components=1 -xzvf -

  ./configure -j$(nproc) --prefix=/usr/local $OPENRESTY_BUILD_OPTIONS
  make -j install

  find /usr/local -type f -executable -exec strip --strip-unneeded {} \;
  rm -rf * /usr/local/{site,pod,COPYRIGHT}

  openresty -version
EOS



# Install NodeJS. Output is in /usr/local.
FROM build-base AS build-node
ARG NODE_VERSION
RUN <<EOS
  apt-get install -y --no-install-recommends gpg python3
  rm -rf /usr/local/*

  curl https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor > /usr/share/keyrings/nodesource.gpg
  echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION nodistro main" > /etc/apt/sources.list.d/nodesource.list

  apt-get update
  apt-get download nodejs
  dpkg --instdir=/build --force-all --install ./nodejs*.deb
  mv -i usr/bin usr/lib /usr/local

  find /usr/local -type f -executable -exec strip --strip-unneeded {} \;
  rm -rf *

  node --version
EOS



# Build Ruby gems. Output is in /home/danbooru/bundle.
FROM build-ruby AS build-gems
WORKDIR /danbooru

RUN apt-get install -y --no-install-recommends libpq-dev ragel=6.10-4

COPY --chown=danbooru:danbooru lib/dtext_rb/ lib/dtext_rb/
USER danbooru

RUN <<EOS
  cd lib/dtext_rb
  bin/install
EOS

COPY --link Gemfile Gemfile.lock ./
RUN <<EOS
  BUNDLE_FROZEN=1 bundle install --no-cache --jobs $(nproc)

  cd $GEM_HOME
  find . -regextype egrep -regex '.*\.(o|a|c|h|hh|hpp|exe|java|md|po|log|out|gem|rdoc)$' -delete
  find . -regextype egrep -regex '^.*/(Change|CHANGE|NEWS|LICENSE|COPYING|LEGAL|AUTHORS|CONTRIBUTORS|THANK|README|INSTALL|NOTICE|TODO|.github).*$' -delete
  find . -type f -executable -exec strip --strip-unneeded {} \;
EOS



# Build Javascript and CSS assets. Output is in /danbooru/public/packs and /danbooru/node_modules.
FROM build-node AS build-assets
WORKDIR /danbooru

COPY --link package.json package-lock.json ./

RUN <<EOS
  mkdir -p node_modules public/packs
  chown danbooru:danbooru /danbooru node_modules public/packs
EOS

USER danbooru
RUN npm ci

COPY --link postcss.config.js babel.config.json ./
COPY --link config/shakapacker.yml ./config/
COPY --link config/webpack/ ./config/webpack/
COPY --link public/images ./public/images
COPY --link public/fonts ./public/fonts
COPY --link app/components/ ./app/components
COPY --link app/javascript/ ./app/javascript

RUN <<EOS
  npx webpack --mode production -c config/webpack/webpack.config.js
  rm -f public/packs/**/*.{gz,br}
EOS



# The base layer for the production and development layers. Contains everything but the /danbooru directory.
FROM base AS danbooru-base
WORKDIR /danbooru

COPY --link --from=build-ffmpeg /usr/local /usr/local
COPY --link --from=build-exiftool /usr/local /usr/local
COPY --link --from=build-openresty /usr/local /usr/local
COPY --link --from=build-vips /usr/local /usr/local
COPY --link --from=build-ruby /usr/local /usr/local
COPY --link --from=build-gems $GEM_HOME $GEM_HOME
COPY --link --from=build-assets /danbooru/public/packs /danbooru/public/packs

# http://jemalloc.net/jemalloc.3.html#tuning
ENV LD_PRELOAD=libjemalloc.so.2
ENV MALLOC_CONF=background_thread:true,narenas:2,dirty_decay_ms:1000,muzzy_decay_ms:0,tcache:false

# https://github.com/ruby/ruby/blob/master/doc/yjit/yjit.md
ENV RUBY_YJIT_ENABLE=1

# Disable libvips warning messages
ENV VIPS_WARNING=0

# https://github.com/shopify/bootsnap#environment-variables
ENV BOOTSNAP_CACHE_DIR=/home/danbooru/bootsnap
ENV BOOTSNAP_READONLY=true

ENV DOCKER=true

RUN <<EOS
  ldconfig

  mkdir -p /images
  chown danbooru:danbooru /danbooru /images /home/danbooru public/packs $GEM_HOME
EOS

ENTRYPOINT ["tini", "-g", "--"]
CMD ["bin/rails", "server"]



# The production layer. Contains the final /danbooru directory on top of the base Danbooru layer.
FROM danbooru-base AS production
USER danbooru

COPY --chown=danbooru:danbooru . /danbooru

RUN <<EOS
  mkdir -p public/data public/packs-dev
  ln -s packs public/packs-test
  ln -s /tmp tmp

  bundle exec bootsnap precompile --gemfile app test

  # Test that everything works
  vips --version
  ruby --version
  cjpeg -version
  ffmpeg -version
  ffprobe -version
  exiftool -ver
  openresty -version
  bin/good_job --help > /dev/null
  bin/rails runner -e production 'puts "#{Danbooru.config.app_name}/#{Rails.application.config.x.git_hash}"'
EOS

ARG DOCKER_IMAGE_REVISION=""
ARG DOCKER_IMAGE_BUILD_DATE=""
ENV DOCKER_IMAGE_REVISION=$DOCKER_IMAGE_REVISION
ENV DOCKER_IMAGE_BUILD_DATE=$DOCKER_IMAGE_BUILD_DATE



# The development layer. Contains the production layer, plus enables passwordless sudo and includes nodejs
# and node_modules so that JS/CSS files can be rebuilt.
FROM danbooru-base AS development

RUN <<EOS
  apt-get update
  apt-get install -y --no-install-recommends g++ make ragel=6.10-4 git sudo gpg socat

  groupadd admin -U danbooru
  passwd -d danbooru

  touch /home/danbooru/.sudo_as_admin_successful
EOS

COPY --link --from=build-node /usr/local /usr/local
COPY --link --from=build-assets /danbooru/node_modules /node_modules
COPY --link --from=production /home/danbooru/bootsnap /home/danbooru/bootsnap
COPY --link --from=production /danbooru /danbooru

RUN chown danbooru:danbooru /danbooru /node_modules /home/danbooru /home/danbooru/bootsnap /home/danbooru/.sudo_as_admin_successful

ARG DOCKER_IMAGE_REVISION=""
ARG DOCKER_IMAGE_BUILD_DATE=""
ENV DOCKER_IMAGE_REVISION=$DOCKER_IMAGE_REVISION
ENV DOCKER_IMAGE_BUILD_DATE=$DOCKER_IMAGE_BUILD_DATE

USER danbooru
