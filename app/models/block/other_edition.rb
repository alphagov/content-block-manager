module Block
  # Stub edition class for testing STI scoping behavior
  class OtherEdition < Edition
    def details
      { type: "other" }
    end
  end
end
