class Document::Index::V2::SummaryCardComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
  end

private

  attr_reader :document

  def rows
    [
      title_item,
      description_item,
      organisation_item,
    ].compact
  end

  def title_item
    {
      key: helpers.label_for_title(document.block_type),
      value: document.title,
    }
  end

  def description_item
    {
      key: "Description",
      value: edition.description,
    }
  end

  def organisation_item
    {
      key: "Lead organisation",
      value: edition.lead_organisation.name,
    }
  end

  def title
    document.title
  end

  def summary_card_actions
    [
      {
        label: "View",
        href: "",
      },
    ]
  end

  def edition
    @edition = document.most_recent_edition
  end
end
