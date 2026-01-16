class FactCheck::DefaultBlockComponent < ViewComponent::Base
  def initialize(current_edition:, published_edition:)
    super()
    @current_edition = current_edition
    @published_edition = published_edition
    @document = current_edition.document
  end

private

  attr_reader :current_edition, :published_edition, :document

  def calculate_diff
    Nokodiff.diff(current_edition.render, published_edition.render)
  end

  def block_content
    content_tag(:div, class: "govspeak compare-editions") do
      calculate_diff
    end
  end
end
