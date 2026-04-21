module Edition::ValidatesDetails
  extend ActiveSupport::Concern

  DETAILS_PREFIX = "details_".freeze

  included do
    validates_with DetailsValidator

    def self.human_attribute_name(attr, options = {})
      if attr.starts_with?(DETAILS_PREFIX)
        key = attr.to_s.delete_prefix(DETAILS_PREFIX)
        key.humanize
      else
        super attr, options
      end
    end
  end

  # When an error is raised about a field within the details hash
  # we have to prefix it. This overrides the default `read_attribute_for_validation`
  # method, and reads it from the details hash if the attribute name
  # is prefixed
  def read_attribute_for_validation(attr)
    if attr.starts_with?(DETAILS_PREFIX)
      key = attr.to_s.delete_prefix(DETAILS_PREFIX)
      details&.fetch(key, nil)
    else
      super(attr)
    end
  end
end
