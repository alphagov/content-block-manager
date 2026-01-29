# Ensure helpers are included in cucumber tests
ActiveSupport.on_load(:action_view) do
  include TranslationHelper
end
