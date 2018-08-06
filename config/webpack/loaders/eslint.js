module.exports = {
  enforce: 'pre',
  test: /\.(js)$/i,
  exclude: /node_modules|vendor/,
  loader: 'eslint-loader',
  options: {
    cache: true,
    emitWarning: true,
  }
}
