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
      // https://github.com/usabilityhub/rails-erb-loader
      test: /.erb$/,
      enforce: "pre",
      exclude: /node_modules/,
      loader: "rails-erb-loader",
      options: {
        runner: "bin/rails runner"
      }
    }, {
      test: /\.wasm$/,
      type: 'asset/resource',
      generator: {
        filename: 'js/[name][ext]'
      }
    }]
  },
});
