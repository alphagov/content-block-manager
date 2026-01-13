class Outcome < ApplicationRecord
  validates :type, presence: true
  belongs_to :edition
  belongs_to :creator, class_name: "User"
end
