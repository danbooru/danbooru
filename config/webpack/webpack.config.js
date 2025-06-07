const { generateWebpackConfig } = require("shakapacker");

module.exports = generateWebpackConfig({
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

// XXX Hack to force sass-loader to use the modern API to avoid deprecation warnings.
// https://sass-lang.com/documentation/breaking-changes/legacy-js-api/
let sassRule = module.exports.module.rules.find(rule => /sass/.test(rule.test));
let sassLoader = sassRule.use.find(loader => /sass-loader/.test(loader.loader));
sassLoader.options.api = "modern";
