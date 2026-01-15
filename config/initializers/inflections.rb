# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "BSL"
  inflect.plural(/(thing)([\s_])taxed/i, '\1s\2taxed')
  inflect.singular(/(thing)s([\s_])taxed/i, '\1\2taxed')
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym "RESTful"
# end
