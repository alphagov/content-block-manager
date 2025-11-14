module EditionHelper
  def published_date(edition)
    tag.time(
      edition.updated_at.to_fs(:long_ordinal_with_at),
      class: "date",
      datetime: edition.updated_at.iso8601,
      lang: "en",
    )
  end

  def scheduled_date(edition)
    tag.time(
      edition.scheduled_publication.to_fs(:long_ordinal_with_at),
      class: "date",
      datetime: edition.scheduled_publication.iso8601,
      lang: "en",
    )
  end

  def formatted_instructions_to_publishers(edition)
    if edition.instructions_to_publishers.present?
      simple_format(
        auto_link(edition.instructions_to_publishers, html: { class: "govuk-link", target: "_blank", rel: "noopener" }),
        { class: "govuk-!-margin-top-0" },
        { sanitize_options: { attributes: %w[href class target rel] } },
      )
    else
      "None"
    end
  end

  def current_state_label(edition)
    label = label_for_state(edition)
    return label.html_safe if label

    raise ArgumentError, "No status label found for #{edition.state}"
  end

private

  def label_for_state(edition)
    case edition.state
    when "scheduled"
      "Scheduled for publication at #{scheduled_date(edition)}"
    when "published"
      "Published on #{published_date(edition)} by #{edition.creator.name}"
    when "draft"
      "Drafted on #{published_date(edition)} by #{edition.creator.name}"
    when "awaiting_2i"
      "Sent for 2i review on #{published_date(edition)} by #{edition.creator.name}"
    when "superseded"
      "Superseded on #{published_date(edition)}"
    end
  end
end
