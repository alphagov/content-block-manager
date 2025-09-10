require "test_helper"

class OrganisationValidatorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  it "validates the presence of a lead organisation" do
    document = build(:document, :pension)
    edition = build(:edition, lead_organisation_id: nil, document:)

    assert_equal false, edition.valid?

    assert_equal(
      [I18n.t("activerecord.errors.models.edition.blank", attribute: "Lead organisation")],
      edition.errors.full_messages,
    )
  end
end
