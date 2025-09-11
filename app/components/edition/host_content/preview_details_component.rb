class Edition::HostContent::PreviewDetailsComponent < ViewComponent::Base
  def initialize(edition:, preview_content:)
    @edition = edition
    @preview_content = preview_content
  end

private

  def list_items
    [*details_items.compact, instances_item]
  end

  def details_items
    @edition.details.map do |key, value|
      next unless value.is_a?(String)

      { key: key.humanize, value: }
    end
  end

  def instances_item
    { key: "Instances", value: @preview_content.instances_count }
  end
end
