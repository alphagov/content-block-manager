require "test_helper"

class ContentBlockManager::OrganisationValidatorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  it "validates the presence of a lead organisation" do
    document = build(:content_block_document, :pension)
    content_block_edition = build(:content_block_edition, lead_organisation_id: nil, document:)

    assert_equal false, content_block_edition.valid?

    assert_equal [I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.blank", attribute: "Lead organisation")], content_block_edition.errors.full_messages
  end
end
