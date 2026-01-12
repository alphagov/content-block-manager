class ReviewOutcome < Outcome
  def performer
    performer_identifier
  end

  def performer=(performer)
    self.performer_identifier = performer
  end
end
