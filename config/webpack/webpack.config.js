const { globalMutableWebpackConfig: baseWebpackConfig, merge } = require("shakapacker");
const ESLintPlugin = require("eslint-webpack-plugin");
const StylelintPlugin = require("stylelint-webpack-plugin");

const isDevelopment = process.env.NODE_ENV === "development";

module.exports = merge({}, baseWebpackConfig, {
//  output: {
//    library: "Danbooru",
//  },
  resolve: {
    alias: {
      "jquery": "jquery/src/jquery.js",
    }
  },
  plugins: [
    isDevelopment && new ESLintPlugin({
      cache: true,
      threads: true,
      emitWarning: true
    }),
    isDevelopment && new StylelintPlugin({
      context: "app/javascript/src/styles",
      threads: true,
    }),
  ].filter(Boolean),
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
