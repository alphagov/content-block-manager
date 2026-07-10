module Block
  class TimePeriodEdition < Edition
    has_one :date_range, class_name: "Block::TimePeriodDateRange", foreign_key: :edition_id, dependent: :destroy

    accepts_nested_attributes_for :date_range
  end
end
