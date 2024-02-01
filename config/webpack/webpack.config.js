const { globalMutableWebpackConfig: baseWebpackConfig, merge } = require("shakapacker");

module.exports = merge({}, baseWebpackConfig, {
//  output: {
//    library: "Danbooru",
//  },
  resolve: {
    alias: {
      "jquery": "jquery/src/jquery.js",
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
