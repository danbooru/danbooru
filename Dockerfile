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
ARG FFMPEG_URL="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n6.0.1.tar.gz"
ARG EXIFTOOL_URL="https://github.com/exiftool/exiftool/archive/refs/tags/12.56.tar.gz"
ARG OPENRESTY_URL="https://openresty.org/download/openresty-1.25.3.1.tar.gz"
ARG RUBY_URL="https://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.1.tar.gz"
ARG NODE_VERSION="20.x"
ARG UBUNTU_VERSION="24.04"


# The base layer for everything.
FROM ubuntu:$UBUNTU_VERSION AS base
SHELL ["/bin/bash", "-xeuo", "pipefail", "-O", "globstar", "-O", "dotglob", "-c"]
ENV DEBIAN_FRONTEND="noninteractive"
RUN <<EOS
  apt-get update
  rm -rf /usr/local/*
EOS



# The base layer for building dependencies. All builds take place inside /build.
FROM base AS build-base
WORKDIR /build
ARG COMMON_BUILD_DEPS="curl ca-certificates build-essential pkg-config git"
RUN apt-get install -y --no-install-recommends $COMMON_BUILD_DEPS



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
ARG EXIFTOOL_BUILD_DEPS="perl perl-modules libarchive-zip-perl"
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
  apt-get install -y --no-install-recommends gnupg

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



# Build Ruby gems. Output is in /usr/local.
FROM build-ruby AS build-gems

RUN apt-get install -y --no-install-recommends libpq-dev libglib2.0-dev
COPY --link Gemfile Gemfile.lock ./
RUN <<EOS
  bundle install --system --no-cache --jobs $(nproc)

  find /usr/local/lib/ruby/gems -regextype egrep -regex '.*\.(o|a|c|h|hh|hpp|exe|java|md|po|log|out|gem)$' -delete
  find /usr/local/lib/ruby/gems -regextype egrep -regex '^.*/(Change|CHANGE|NEWS|LICENSE|COPYING|LEGAL|AUTHORS|CONTRIBUTORS|THANK|README|INSTALL|NOTICE|TODO).*$' -delete
  find /usr/local/lib/ruby/gems -type f -executable -exec strip --strip-unneeded {} \;

  rm -rf *
EOS


# Build the base Danbooru image. Pull in dependencies from previous layers and install runtime dependencies from apt-get.
FROM base AS danbooru-base
WORKDIR /danbooru
ARG NODE_VERSION

COPY --link --from=build-vips /usr/local /usr/local
COPY --link --from=build-ruby /usr/local /usr/local
COPY --link --from=build-node /usr/local /usr/local

RUN <<EOS
  apt-get install -y --no-install-recommends \
    postgresql-client ca-certificates mkvtoolnix rclone openssl perl perl-modules libpq5 libpcre3 \
    libgmpxx4ldbl zlib1g libfftw3-bin libwebp7 libwebpmux3 libwebpdemux2 liborc-0.4.0 liblcms2-2 libpng16-16 libexpat1 \
    libglib2.0 libgif7 libexif12 libheif1 libvpx8 libdav1d7 libseccomp-dev libjemalloc2 libarchive13 libyaml-0-2 libffi8 \
    libreadline8 libarchive-zip-perl tini busybox less ncdu curl

  npm install -g yarn
  gem install --no-document foreman

  apt-get purge -y --allow-remove-essential pkg-config e2fsprogs libglib2.0-bin libglib2.0-doc mount procps python3 tzdata
  apt-get autoremove -y
  rm -rf /var/{lib,cache,log} /usr/share/{doc,info}/* /build

  busybox --install -s
EOS



# Build Javascript and CSS assets. Output is in /danbooru/public/packs.
FROM danbooru-base AS build-assets

COPY --link .yarnrc.yml package.json yarn.lock ./
COPY --link .yarn/ ./.yarn/
RUN yarn install

COPY --link postcss.config.js babel.config.json Rakefile ./
COPY --link bin/rails bin/shakapacker bin/shakapacker-dev-server ./bin/
COPY --link config/application.rb config/boot.rb config/danbooru_default_config.rb config/shakapacker.yml ./config/
COPY --link config/webpack/ ./config/webpack/
COPY --link public/images ./public/images
COPY --link public/fonts ./public/fonts
COPY --link app/components/ ./app/components/
COPY --link app/javascript/ ./app/javascript/

COPY --link Gemfile Gemfile.lock ./
COPY --link --from=build-gems /usr/local /usr/local
RUN RAILS_ENV=production bin/rails assets:precompile



# Build the final layer. Pull in the compiled assets and gems on top of the base Danbooru layer.
FROM danbooru-base AS production

COPY --link --from=build-ffmpeg /usr/local /usr/local
COPY --link --from=build-exiftool /usr/local /usr/local
COPY --link --from=build-openresty /usr/local /usr/local

COPY --link --from=build-assets /danbooru/public/packs /danbooru/public/packs
COPY --link --from=build-gems /usr/local /usr/local
COPY --link . /danbooru

# http://jemalloc.net/jemalloc.3.html#tuning
ENV LD_PRELOAD=libjemalloc.so.2
ENV MALLOC_CONF=background_thread:true,narenas:2,dirty_decay_ms:1000,muzzy_decay_ms:0,tcache:false

# https://github.com/ruby/ruby/blob/master/doc/yjit/yjit.md
ENV RUBY_YJIT_ENABLE=1

# Disable libvips warning messages
ENV VIPS_WARNING=0

ARG SOURCE_COMMIT=""
RUN <<EOS
  echo $SOURCE_COMMIT > REVISION
  ln -s /tmp tmp
  ln -s packs public/packs-test
  userdel ubuntu
  useradd --user-group danbooru --home-dir /tmp
  mkdir -p public/data /images
  chown danbooru:danbooru public/data /images
  ldconfig

  # Test that everything works
  vips --version
  node --version
  ruby --version
  cjpeg -version
  ffmpeg -version
  ffprobe -version
  exiftool -ver
  openresty -version
  bin/rails runner -e production 'puts "#{Danbooru.config.app_name}/#{Rails.application.config.x.git_hash}"'
EOS

USER danbooru
ENTRYPOINT ["tini", "--"]
CMD ["bin/rails", "server"]

# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.source https://github.com/danbooru/danbooru
