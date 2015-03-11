FROM debian:wheezy

ENV RUBY_VERSION 2.1.5
ENV GITHUB_INSTALL https://raw.githubusercontent.com/r888888888/danbooru/master/script/install
ENV POSTGRESQL_VERSION 9.1

RUN apt-get update
RUN apt-get -y \
  install \
  build-essential \
  automake \
  libssl-dev \
  libxml2-dev \
  libxslt-dev \
  ncurses-dev \
  sudo \
  libreadline-dev \
  flex \
  bison \
  ragel \
  memcached \
  libmemcache-dev \
  git \
  curl \
  libcurl4-openssl-dev \
  imagemagick \
  libmagickcore-dev \
  libmagickwand-dev \
  sendmail-bin \
  sendmail \
  postgresql \
  postgresql-contrib \
  libpq-dev \
  nginx \
  ssh \
  openssh-server \
  supervisor
RUN useradd -m danbooru
RUN chsh -s /bin/bash danbooru
RUN usermod -G danbooru,sudo danbooru

USER danbooru
RUN git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
RUN touch ~/.bash_profile
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
RUN echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
RUN mkdir -p ~/.rbenv/plugins
RUN git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN ["/bin/bash", "-l", "-c", "rbenv install $RUBY_VERSION"]
RUN ["/bin/bash", "-l", "-c", "rbenv global $RUBY_VERSION"]
RUN mkdir ~/.danbooru
RUN openssl rand -hex 32 > ~/.danbooru/secret_token
RUN openssl rand -hex 32 > ~/.danbooru/session_secret_key
RUN chmod 600 ~/.danbooru/*
RUN ["/bin/bash", "-l", "-c", "gem install --no-ri --no-rdoc bundler"]

USER root
ADD $GITHUB_INSTALL/postgresql_hba_conf /etc/postgresql/$POSTGRESQL_VERSION/main/pg_hba.conf
RUN chmod 644 /etc/postgresql/$POSTGRESQL_VERSION/main/pg_hba.conf
ADD $GITHUB_INSTALL/nginx.danbooru.conf /etc/nginx/conf.d/danbooru.conf
RUN chmod 644 /etc/nginx/conf.d/danbooru.conf
RUN sed -i -e "s/__hostname__/$HOSTNAME/g" /etc/nginx/conf.d/danbooru.conf
ADD $GITHUB_INSTALL/danbooru_logrotate_conf /etc/logrotate.d/danbooru.conf
RUN chmod 644 /etc/logrotate.d/danbooru.conf
ADD $GITHUB_INSTALL/supervisord_conf /etc/supervisord.conf
RUN /etc/init.d/postgresql start && sudo -u postgres createuser -s danbooru && /etc/init.d/postgresql stop
RUN /etc/init.d/postgresql start && sudo -u danbooru createdb danbooru2 && /etc/init.d/postgresql stop

USER danbooru
RUN git clone git://github.com/r888888888/danbooru.git ~/danbooru
RUN ["/bin/bash", "-l", "-c", "cd ~/danbooru && bundle install"]
ADD $GITHUB_INSTALL/danbooru_local_config.rb.templ ~/danbooru/config/danbooru_local_config.rb
ADD $GITHUB_INSTALL/database.yml.templ ~/danbooru/config/database.yml

CMD supervisord -c /etc/supervisord.conf
