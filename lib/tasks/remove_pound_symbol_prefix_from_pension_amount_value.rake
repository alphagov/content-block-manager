namespace :data_migration do
  desc "Remove pound symbol prefix from Pension#amount values"
  task remove_pound_symbol_prefix_from_pension_amount_value: :environment do
    log = proc { |str|
      timestamp = Time.current.strftime("%F %T")
      line = "#{timestamp} > #{str}"
      puts line unless Rails.env.test?
      Rails.logger.info(line)
    }

    log.call("Removing pound symbol prefix from Pension#amount values")
    editions = Edition.joins(:document).where(document: { block_type: "pension" })

    log.call("#{editions.count} editions of type Pension found")

    editions.each do |edition|
      rates = edition.details["rates"]
      updated_any_rate = false

      next unless rates

      rates.each do |_, rate|
        amount = rate["amount"]

        next unless amount&.start_with?("£")

        log.call("Converting edition #{edition.id}: #{edition.title} (#{rate['amount']} #{rate['frequency']})")

        rate["amount"] = amount.delete_prefix("£")
        updated_any_rate = true
      end

      next unless updated_any_rate

      edition.details["rates"] = rates
      edition.save!(validate: false)
      log.call(" -> Edition #{edition.id} successfully updated.")

      edition.details["rates"].each do |_, rate|
        log.call("Edition #{edition.id} final rate value: #{rate['amount']} #{rate['frequency']}")
      end
    end
  end
end
