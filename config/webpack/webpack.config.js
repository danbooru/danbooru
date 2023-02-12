const { webpackConfig: baseWebpackConfig, merge } = require("shakapacker");
const ESLintPlugin = require("eslint-webpack-plugin");
const StylelintPlugin = require("stylelint-webpack-plugin");
const path = require("path");

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

// XXX Transpile @alpinejs/morph with Babel to fix an issue with it not working in iOS <14.
// XXX Transpile alpinejs to fix an issue with it not working in Firefox <72 (use of nullish coalescing operator).
let babelRule = module.exports.module.rules.find(rule => rule.exclude?.source === "node_modules");
babelRule.exclude = /node_modules\/(?!(@alpinejs\/morph|alpinejs)\/).*/;
babelRule.include.push(path.resolve(__dirname, "../../node_modules/@alpinejs/morph"));
babelRule.include.push(path.resolve(__dirname, "../../node_modules/alpinejs"));

//RegExp.prototype.toJSON = RegExp.prototype.toString;
//console.log(JSON.stringify(module.exports, undefined, 2));
