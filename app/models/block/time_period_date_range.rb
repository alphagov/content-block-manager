module Block
  class TimePeriodDateRange < ApplicationRecord
    self.table_name = "block_time_period_date_ranges"

    belongs_to :edition, class_name: "Block::TimePeriodEdition"

    validates :start, presence: true
    validates :end, presence: true
    validate :end_date_after_start_date

    def to_details
      {
        "start" => {
          "date" => start.strftime("%Y-%m-%d"),
          "time" => start.strftime("%H:%M"),
        },
        "end" => {
          "date" => self.end.strftime("%Y-%m-%d"),
          "time" => self.end.strftime("%H:%M"),
        },
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
