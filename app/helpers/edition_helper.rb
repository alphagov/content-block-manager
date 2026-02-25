module EditionHelper
  def updated_date(edition)
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

  def date_range_from_params(edition_param_details)
    date_range = edition_param_details["date_range"]

    start_date_time = DateTimeConverter.from_object(date_object: date_range, field_name: "start")
    end_date_time = DateTimeConverter.from_object(date_object: date_range, field_name: "end")

    { "date_range" =>
      { "start" =>
        { "date" => start_date_time.to_date_string,
          "time" => start_date_time.to_time_string },
        "end" =>
        { "date" => end_date_time.to_date_string,
          "time" => end_date_time.to_time_string } } }
  rescue NoMethodError
    {}
  end

private

  def label_for_state(edition)
    I18n.t("edition.states.label_extended.#{edition.state}",
           user: edition.creator.name,
           date: updated_date(edition),
           default: nil)
  end
end
