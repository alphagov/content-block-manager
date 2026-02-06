class FactCheck::SubschemaGroupDiffComponent < ViewComponent::Base
  def initialize(block:, subschema:, combined_block_content:, embedded_object_titles:)
    @block = block
    @subschema = subschema
    @embedded_object_titles = embedded_object_titles
    @combined_block_content = combined_block_content
  end

  def label
    "#{subschema.name.singularize.capitalize} (#{embedded_object_titles.count})"
  end

  delegate :id, to: :subschema

  attr_reader :subschema, :block, :combined_block_content, :embedded_object_titles
end
