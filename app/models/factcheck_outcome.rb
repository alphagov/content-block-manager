class FactcheckOutcome < Outcome
  def reviewer
    reviewer_identifier
  end

  def reviewer=(reviewer)
    self.reviewer_identifier = reviewer
  end
end
