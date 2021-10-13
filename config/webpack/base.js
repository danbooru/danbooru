const { webpackConfig, merge } = require('@rails/webpacker')

module.exports = merge(webpackConfig, {
//  output: {
//    library: "Danbooru",
//  },
  resolve: {
    alias: {
      "jquery": "jquery/src/jquery.js",
      "react": "preact/compat",
      "react-dom": "preact/compat",
    }
  },
  module: {
    rules: [{
      test: /\.wasm$/,
      type: 'asset/resource',
      generator: {
        filename: 'js/[name][ext]'
      }
    }]
  },
});
