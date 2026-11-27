module V2
  class PensionEdition < Edition
    has_one :pension_amount, class_name: "V2::PensionAmount", foreign_key: :edition_id, dependent: :destroy

    accepts_nested_attributes_for :pension_amount

    delegate :amount, to: :pension_amount, allow_nil: true

    def to_details
      {
        "description" => description,
        "amount" => amount&.to_fs(:rounded, precision: 2),
      }.compact
    end
  end
end
