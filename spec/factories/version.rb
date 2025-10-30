FactoryBot.define do
  factory :content_block_version, class: "Version" do
    event { "created" }
    item do
      build(
        :edition,
        document: build(
          :document,
          block_type: "pension",
        ),
      )
    end
    whodunnit { build(:user).id }
    state {}
  end
end
