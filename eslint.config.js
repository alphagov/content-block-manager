const { defineConfig, globalIgnores } = require('eslint/config')

const globals = require('globals')
const js = require('@eslint/js')

const { FlatCompat } = require('@eslint/eslintrc')

const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all
})

module.exports = defineConfig([
  {
    extends: compat.extends('standard', 'prettier'),

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
