const webpack = require("webpack");
const CompressionPlugin = require("compression-webpack-plugin");
const { generateWebpackConfig } = require("shakapacker");

module.exports = generateWebpackConfig({
//  output: {
//    library: "Danbooru",
//  },
  plugins: [
    // Most of our modules use a bare `$` without importing it. jQuery's packaged
    // build doesn't define window.$ (only the unbundled src/ build we used to alias
    // to did), so resolve `$` through the module graph instead of a global.
    new webpack.ProvidePlugin({
      $: ["jquery", "default"],
      jQuery: ["jquery", "default"],
    }),
  ],
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

// In production, Shakapacker precompresses assets with both gzip and brotli. Use gzip only, because brotli doubles the
// build time and nginx only serves the .gz files, and also compress .wasm files.
if (module.exports.plugins.some(plugin => plugin instanceof CompressionPlugin)) {
  module.exports.plugins = module.exports.plugins.filter(plugin => !(plugin instanceof CompressionPlugin));
  module.exports.plugins.push(new CompressionPlugin({ test: /\.(js|css|html|json|ico|svg|eot|otf|ttf|map|wasm)$/ }));
}
