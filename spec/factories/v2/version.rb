FactoryBot.define do
  factory :v2_version, class: "V2::Version" do
    event { "created" }
    item do
      build(
        :v2_time_period_edition,
        document: build(
          :v2_document,
          block_type: "time_period",
        ),
      )
    end
    whodunnit { build(:user).id }
    state {}
  end
end
