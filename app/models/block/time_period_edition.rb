module Block
  class TimePeriodEdition < Edition
    has_one :date_range, class_name: "Block::TimePeriodDateRange", foreign_key: :edition_id, dependent: :destroy, inverse_of: :edition

    accepts_nested_attributes_for :date_range

    def details
      {
        "description" => description,
        "date_range" => date_range&.to_details,
      }.compact
    end
  end
end
