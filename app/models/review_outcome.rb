class ReviewOutcome < Outcome
  belongs_to :reviewer, class_name: "User", optional: true
end
