class ReviewOutcome < Outcome
  belongs_to :performer, class_name: "User", optional: true
end
