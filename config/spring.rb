# This file configures Spring, the Rails application preloader.
#
# @see https://github.com/rails/spring

%w[
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
].each { |path| Spring.watch(path) }
