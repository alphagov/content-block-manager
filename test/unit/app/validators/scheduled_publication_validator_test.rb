require "test_helper"

class ScheduledPublicationValidatorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:document) { build(:document, :pension) }
  let(:edition) { build(:edition, document: document, state: "scheduled") }

  it "validates if scheduled_publication is blank" do
    edition.scheduled_publication = nil

    assert_equal false, edition.valid?

    assert_equal [I18n.t("activerecord.errors.models.edition.attributes.scheduled_publication.blank")], edition.errors.full_messages
  end

  it "validates if scheduled_publication is in the past" do
    edition.scheduled_publication = Time.zone.now - 2.days

    assert_equal false, edition.valid?

    assert_equal [I18n.t("activerecord.errors.models.edition.attributes.scheduled_publication.future_date")], edition.errors.full_messages
  end

  it "is valid if a future date is set" do
    edition.scheduled_publication = Time.zone.now + 2.days

    assert_equal true, edition.valid?
  end
end
