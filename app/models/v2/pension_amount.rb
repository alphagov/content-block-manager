module V2
  class PensionAmount < ApplicationRecord
    belongs_to :edition, class_name: "V2::PensionEdition"

    validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  end
end
