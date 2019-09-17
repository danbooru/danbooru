module.exports = {
  plugins: [
    require('postcss-import'),
    require('postcss-flexbugs-fixes'),
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009'
      },
      // https://github.com/csstools/postcss-preset-env#importfrom
      importFrom: [
        'app/javascript/src/styles/base/040_colors.css'
      ],
      stage: 3
    })
  ]
}
