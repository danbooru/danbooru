const { environment } = require('@rails/webpacker')
const erb =  require('./loaders/erb')
const webpack = require('webpack');

environment.loaders.append('erb', erb);

environment.config.output.library = ["Danbooru"];

environment.config.set("resolve.alias", {
  "jquery": "jquery/src/jquery.js",
  "react": "preact/compat",
  "react-dom": "preact/compat",
});

module.exports = environment
