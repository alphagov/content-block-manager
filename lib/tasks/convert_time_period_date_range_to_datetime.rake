namespace :data_migration do
  desc "Convert TimePeriod#date_range to datetime format"
  task convert_time_period_date_range_to_datetime: :environment do
    log = proc { |str|
      timestamp = Time.current.strftime("%F %T")
      line = "#{timestamp} > #{str}"
      puts line unless Rails.env.test?
      Rails.logger.info(line)
    }

    log.call("Converting TimePeriod#date_range to datetime")
    editions = Edition.joins(:document).where(document: { block_type: "time_period" })

    log.call("#{editions.count} editions of type TimePeriod found")

    editions_to_convert = editions.filter do |edition|
      !edition.details.dig("date_range", "start").is_a?(String) &&
        edition.details.dig("date_range", "start", "date")
    end

    log.call("#{editions_to_convert.count} of those have their date_range in the old format")

    editions_to_convert.each do |edition|
      log.call("Converting edition #{edition.id}: #{edition.title} (#{edition.details['date_range']})")

      new_format_start = DateAndTime::Converter.from_strings(
        date: edition.details.dig("date_range", "start", "date"),
        time: edition.details.dig("date_range", "start", "time"),
      )

      new_format_end = DateAndTime::Converter.from_strings(
        date: edition.details.dig("date_range", "end", "date"),
        time: edition.details.dig("date_range", "end", "time"),
      )

      edition.details["date_range"]["start"] = new_format_start.to_iso8601
      edition.details["date_range"]["end"] = new_format_end.to_iso8601
      edition.save!(validate: false)

      edition.reload

      log.call(" -> converted (#{edition.details['date_range']})")
    end
  end
end
