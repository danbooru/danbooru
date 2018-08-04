const { environment } = require('@rails/webpacker')
const erb =  require('./loaders/erb')
const webpack = require('webpack');

environment.loaders.append('scss.erb', {
  test: /\.scss\.erb$/,
  enforce: 'pre',
  exclude: /node_modules/,
  use: [
    'style-loader',
    'postcss-loader',
    'sass-loader',
    'rails-erb-loader'
  ]
});

environment.loaders.append('erb', erb);

environment.config.externals = {
  jquery: "jQuery"
}

environment.config.output.library = ["Danbooru", "[name]"];

module.exports = environment
