FactoryBot.define do
  factory :v2_version, class: "Version" do
    event { "created" }
    item do
      build(
        :v2_edition,
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
