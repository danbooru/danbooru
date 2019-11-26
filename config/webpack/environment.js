const { environment } = require('@rails/webpacker')
const erb =  require('./loaders/erb')
const webpack = require('webpack');

environment.loaders.append('erb', erb);

environment.config.output.library = ["Danbooru"];

environment.config.externals = {
  jquery: "jQuery"
}

module.exports = environment
