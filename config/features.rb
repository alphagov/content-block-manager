require_relative "../lib/content_block_manager"

Flipflop.configure do
  # Strategies will be used in the order listed here.
  strategy :active_record, hidden: !Rails.env.development?
  strategy :cookie
  strategy :default

  # Other strategies:
  #
  # strategy :sequel
  # strategy :redis
  #
  # strategy :query_string
  # strategy :session
  #
  # strategy :my_strategy do |feature|
  #   # ... your custom code here; return true/false/nil.
  # end

  # Declare your features, e.g:
  #
  # feature :world_domination,
  #   default: true,
  #   description: "Take over the world."
  feature :show_all_content_block_types,
          description: "Show all applicable content block types in Content Block Manager",
          default: ContentBlockManager.integration_or_staging? || !Rails.env.production?

  feature :ga4_form_tracking,
          description: "Add GA4 form tracking to Content Block Manager",
          default: ContentBlockManager.integration_or_staging? || !Rails.env.production?
end
