module Block
  class TimePeriodDateRange < ApplicationRecord
    belongs_to :edition, class_name: "Block::TimePeriodEdition"

    validates :start, presence: true
    validates :end, presence: true
    validate :end_date_after_start_date

    def to_details
      {
        "start" => start,
        "end" => self.end,
      }
    end

  private

    def end_date_after_start_date
      return if self.end.blank? || start.blank?

      if self.end <= start
        errors.add(:end, "must be after start date")
      end
    end
  end
end
