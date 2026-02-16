require "record_tag_helper/helper"

class Document::Index::FilterOptionsComponent < ViewComponent::Base
  include ActionView::Helpers::RecordTagHelper

  def initialize(filters:, errors: nil)
    @filters = filters
    @errors = errors
  end

private

  def heading
    I18n.t("document.index.filter_options.heading")
  end

  def data_attributes
    {
      module: "ga4-search-tracker",
      ga4_search_type: "index-documents",
      ga4_search_url: helpers.documents_path,
      ga4_search_section: heading,
      ga4_search_input_name: "keyword",
    }
  end

  def items_for_block_type
    helpers.valid_schemas.map do |schema|
      {
        label: schema.block_type.humanize,
        value: schema.block_type,
        checked: @filters.any? && @filters[:block_type]&.include?(schema.block_type),
      }
    end
  end

  def all_organisations_option(selected_orgs)
    {
      text: "All organisations",
      value: "",
      selected: selected_orgs.compact.empty?,
    }
  end

  def taggable_organisations_options(selected_orgs)
    helpers.taggable_organisations_container(selected_orgs)
  end

  def options_for_lead_organisation(selected_orgs = [])
    [all_organisations_option(selected_orgs), taggable_organisations_options(selected_orgs)].flatten
  end
end
