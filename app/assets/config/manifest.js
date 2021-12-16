// This is the config file for Sprockets. Danbooru doesn't use Sprockets, but
// we still need this file anyway because the derailed_benchmarks gem doesn't
// work without it. derailed_benchmarks does `require "rails/all"`, which loads
// Sprockets, which fails if this config file isn't present.
//
// https://github.com/rails/sprockets-rails/issues/444
// https://github.com/zombocom/derailed_benchmarks
{}
