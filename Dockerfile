ARG MOZJPEG_URL="https://github.com/mozilla/mozjpeg/archive/refs/tags/v4.1.1.tar.gz"
ARG VIPS_URL="https://github.com/libvips/libvips/releases/download/v8.14.1/vips-8.14.1.tar.xz"
ARG FFMPEG_URL="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n5.1.2.tar.gz"
ARG EXIFTOOL_URL="https://github.com/exiftool/exiftool/archive/refs/tags/12.50.tar.gz"
ARG OPENRESTY_URL="https://openresty.org/download/openresty-1.21.4.1.tar.gz"
ARG RUBY_URL="https://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.0.tar.gz"
ARG POSTGRESQL_CLIENT_VERSION="14"
ARG NODE_VERSION="18.x"



# The base layer for everything.
FROM ubuntu:22.10 AS base
RUN apt-get update



# The base layer for building dependencies. All builds take place inside /build.
FROM base AS build-base
WORKDIR /build
ARG COMMON_BUILD_DEPS="curl ca-certificates build-essential pkg-config git"
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $COMMON_BUILD_DEPS



# Build Ruby. Output is in /usr/local.
FROM build-base AS build-ruby
ARG RUBY_BUILD_DEPS="rustc libssl-dev libgmp-dev libyaml-dev libffi-dev libreadline-dev zlib1g-dev"
ARG RUBY_URL
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $RUBY_BUILD_DEPS && \
  curl -L $RUBY_URL | tar --strip-components=1 -xzvf - && \
  ./configure --prefix=/usr/local --enable-yjit --disable-install-doc && \
  make -j && \
  make install && \
  rm -rf /build/* && \
  ruby --version



# Build MozJPEG. Output is in /usr/local.
FROM build-base AS build-mozjpeg
ARG MOZJPEG_BUILD_DEPS="cmake nasm libpng-dev zlib1g-dev"
ARG MOZJPEG_URL
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $MOZJPEG_BUILD_DEPS && \
  curl -L $MOZJPEG_URL | tar --strip-components=1 -xzvf - && \
  mkdir build && \
  cd build && \
  cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
  make -j && \
  make install && \
  rm -rf /build/* && \
  cjpeg -version



# Build libvips. Output is in /usr/local.
FROM build-mozjpeg AS build-vips
ARG VIPS_BUILD_DEPS="meson libgirepository1.0-dev libfftw3-dev libwebp-dev liborc-dev liblcms2-dev libpng-dev libexpat1-dev libglib2.0-dev libgif-dev libexif-dev libheif-dev"
ARG VIPS_URL
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $VIPS_BUILD_DEPS && \
  curl -L $VIPS_URL | tar --strip-components=1 -xJvf - && \
  meson build --prefix /usr/local --buildtype release && \
  cd build && \
  meson compile && \
  meson install && \
  rm -rf /build/* && \
  ldconfig && \
  vips --version



# Build FFmpeg. Output is in /usr/local.
FROM build-base AS build-ffmpeg
ARG FFMPEG_BUILD_DEPS="nasm libvpx-dev libdav1d-dev zlib1g-dev"
ARG FFMPEG_URL
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $FFMPEG_BUILD_DEPS && \
  curl -L $FFMPEG_URL | tar --strip-components=1 -xzvf - && \
  ./configure --disable-ffplay --disable-network --disable-doc --enable-libvpx --enable-libdav1d --enable-zlib && \
  make -j && \
  cp ffmpeg ffprobe /usr/local/bin && \
  rm -rf /build/* && \
  ffmpeg -version && \
  ffprobe -version



# Build ExifTool. Output is in /usr/local.
FROM build-base AS build-exiftool
ARG EXIFTOOL_BUILD_DEPS="perl perl-modules libarchive-zip-perl"
ARG EXIFTOOL_URL
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $EXIFTOOL_BUILD_DEPS && \
  curl -L $EXIFTOOL_URL | tar --strip-components=1 -xzvf - && \
  perl Makefile.PL && \
  make -j install && \
  rm -rf /build/* && \
  exiftool -ver && \
  perl -e 'require Compress::Zlib' && \
  perl -e 'require Archive::Zip' && \
  perl -e 'require Digest::MD5'



# Build OpenResty. Output is in /usr/local.
FROM build-base AS build-openresty
ARG OPENRESTY_BUILD_DEPS="libssl-dev libpcre++-dev zlib1g-dev"
ARG OPENRESTY_URL
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $OPENRESTY_BUILD_DEPS && \
  curl -L $OPENRESTY_URL | tar --strip-components=1 -xzvf - && \
  ./configure -j$(nproc) --prefix=/usr/local \
    --with-threads --with-compat --with-pcre-jit --with-file-aio \
    --with-http_gunzip_module --with-http_gzip_static_module \
    --with-http_realip_module --with-http_ssl_module \
    --with-http_stub_status_module --with-http_v2_module && \
  make -j && \
  make install && \
  rm -rf /build/* && \
  openresty -version



# Install NodeJS. Output is in /usr/local.
FROM build-base AS build-node
ARG NODE_VERSION
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gnupg && \
  . /etc/lsb-release && \
  curl https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor > /usr/share/keyrings/nodesource.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/nodesource.list && \
  apt-get update && \
  apt-get download nodejs && \
  dpkg --instdir=/build --force-all --install ./nodejs*.deb && \
  rm -rf /usr/local/* && \
  cp -a usr/bin usr/lib /usr/local && \
  rm -rf /build/*



# Build Ruby gems. Output is in /build/vendor.
FROM build-ruby AS build-gems
ENV BUNDLE_DEPLOYMENT=1

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends libpq-dev libglib2.0-dev
COPY --link Gemfile Gemfile.lock ./
RUN \
  bundle install --jobs $(nproc) && \
  rm -rf vendor/cache vendor/bundle/ruby/*/cache && \
  find vendor -regextype egrep -regex '.*\.(o|c|h|md|log|out)$' -delete && \
  find vendor -regextype egrep -regex 'CHANGE|LICENSE|README' -delete



# Build the base Danbooru image. Pull in dependencies from previous layers and install runtime dependencies from apt-get.
FROM base AS danbooru-base
WORKDIR /danbooru
ARG POSTGRESQL_CLIENT_VERSION
ARG NODE_VERSION

ENV BUNDLE_DEPLOYMENT=1

COPY --link --from=build-mozjpeg /usr/local /usr/local
COPY --link --from=build-vips /usr/local /usr/local
COPY --link --from=build-ffmpeg /usr/local /usr/local
COPY --link --from=build-exiftool /usr/local /usr/local
COPY --link --from=build-openresty /usr/local /usr/local
COPY --link --from=build-ruby /usr/local /usr/local
COPY --link --from=build-node /usr/local /usr/local

RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    postgresql-client-${POSTGRESQL_CLIENT_VERSION} ca-certificates mkvtoolnix rclone openssl perl perl-modules libpq5 \
    libgmpxx4ldbl zlib1g libfftw3-3 libwebp7 libwebpmux3 libwebpdemux2 liborc-0.4.0 liblcms2-2 libpng16-16 libexpat1 \
    libglib2.0 libgif7 libexif12 libheif1 libvpx7 libdav1d6 libseccomp-dev libjemalloc2 libarchive13 libyaml-0-2 libffi8 \
    libreadline8 libarchive-zip-perl tini busybox less ncdu curl && \
  npm install -g yarn && \
  gem install foreman && \
  busybox --install -s && \
  apt-get purge -y --allow-remove-essential pkg-config e2fsprogs libglib2.0-bin libglib2.0-doc mount procps python3 tzdata && \
  apt-get autoremove -y && \
  rm -rf /var/lib /var/cache /var/log /usr/share/doc/* /usr/share/info/* /build



# Build Javascript and CSS assets. Output is in /danbooru/public/packs.
FROM danbooru-base AS build-assets

COPY --link .yarnrc.yml package.json yarn.lock ./
COPY --link .yarn/ ./.yarn/
RUN yarn install

COPY --link postcss.config.js babel.config.json Rakefile ./
COPY --link bin/rails bin/webpacker ./bin/
COPY --link config/application.rb config/boot.rb config/danbooru_default_config.rb config/webpacker.yml ./config/
COPY --link config/webpack/ ./config/webpack/
COPY --link public/images ./public/images
COPY --link public/fonts ./public/fonts
COPY --link app/components/ ./app/components/
COPY --link app/javascript/ ./app/javascript/

COPY --link Gemfile Gemfile.lock ./
COPY --link --from=build-gems /build/vendor /danbooru/vendor
RUN bin/rails assets:precompile



# Build the final layer. Pull in the compiled assets and gems on top of the base Danbooru layer.
FROM danbooru-base AS production

COPY --link --from=build-assets /danbooru/public/packs /danbooru/public/packs
COPY --link --from=build-gems /build/vendor /danbooru/vendor
COPY --link . /danbooru

# http://jemalloc.net/jemalloc.3.html#tuning
ENV LD_PRELOAD=libjemalloc.so.2
ENV MALLOC_CONF=background_thread:true,narenas:2,dirty_decay_ms:1000,muzzy_decay_ms:0,tcache:false

# https://github.com/ruby/ruby/blob/master/doc/yjit/yjit.md
ENV RUBY_YJIT_ENABLE=1

# Disable libvips warning messages
ENV VIPS_WARNING=0

ARG SOURCE_COMMIT
RUN \
  echo "$SOURCE_COMMIT" > REVISION && \
  ln -s /tmp tmp && \
  ln -s packs public/packs-test && \
  useradd --create-home --user-group danbooru

USER danbooru
ENTRYPOINT ["tini", "--"]
CMD ["bin/rails", "server"]

# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.source https://github.com/danbooru/danbooru
