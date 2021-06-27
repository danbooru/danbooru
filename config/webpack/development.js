// @see https://github.com/webpack-contrib/eslint-webpack-plugin

process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const { merge } = require('@rails/webpacker')
const webpackConfig = require('./base');
const ESLintPlugin = require('eslint-webpack-plugin');

module.exports = merge(webpackConfig, {
  plugins: [
    new ESLintPlugin({
      cache: true,
      threads: true,
      emitWarning: true
    })
  ]
});
