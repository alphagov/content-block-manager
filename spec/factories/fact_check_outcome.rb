FactoryBot.define do
  factory :fact_check_outcome, class: "FactCheckOutcome" do
    skipped { false }
    creator { build(:user) }
    performer { "Someone" }
    edition { build(:edition, document: build(:document)) }
  end
end
