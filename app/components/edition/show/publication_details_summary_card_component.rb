class Edition::Show::PublicationDetailsSummaryCardComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

private

  attr_reader :edition

  def title
    "Publication details"
  end

  def rows
    [
      status_item,
    ]
  end

  def summary_card_actions
    [
      {
        label: "Edit",
        href: helpers.workflow_path(id: edition.id, step: :schedule_publishing),
      },
    ]
  end

  def scheduled_value
    I18n.l(edition.scheduled_publication, format: :long_ordinal)
  end

  def status_item
    if edition.scheduled_publication
      {
        key: "Scheduled date and time",
        value: scheduled_value,
      }
    else
      {
        key: "Publish date",
        value: I18n.l(Time.zone.today, format: :long_ordinal),
      }
    end
  end
end
