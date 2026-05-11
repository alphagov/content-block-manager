const { defineConfig, globalIgnores } = require('eslint/config')

const globals = require('globals')
const neostandard = require('neostandard')
const eslintConfigPrettier = require('eslint-config-prettier')

module.exports = defineConfig([
  ...neostandard({ noStyle: true }),
  eslintConfigPrettier,
  {
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.jasmine,
        GOVUK: 'readonly'
      }
    }
  },
  globalIgnores([
    'app/assets/javascripts/vendor/',
    'coverage/',
    'public/assets/content-block-manager/'
  ])
])
