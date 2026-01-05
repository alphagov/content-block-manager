class Outcome < ApplicationRecord
  belongs_to :edition
  belongs_to :creator, class_name: "User"
end
