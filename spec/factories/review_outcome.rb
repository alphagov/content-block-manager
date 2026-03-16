FactoryBot.define do
  factory :review_outcome, class: "ReviewOutcome" do
    skipped { false }
    creator { build(:user) }
    performer { "Someone" }
    edition { build(:edition, document: build(:document)) }
  end
end
