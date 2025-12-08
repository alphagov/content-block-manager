RSpec.describe ScheduledPublicationValidator do
  let(:document) { build(:document, :pension) }
  let(:edition) { build(:edition, document: document, state: "scheduled") }

  it "validates if scheduled_publication is blank" do
    edition.scheduled_publication = nil

    expect(edition).to be_invalid

    expect(edition.errors.full_messages).to eq([I18n.t("activerecord.errors.models.edition.attributes.scheduled_publication.blank")])
  end

  it "validates if scheduled_publication is in the past" do
    edition.scheduled_publication = Time.zone.now - 2.days

    expect(edition).to be_invalid

    expect(edition.errors.full_messages).to eq([I18n.t("activerecord.errors.models.edition.attributes.scheduled_publication.future_date")])
  end

  it "is valid if a future date is set" do
    edition.scheduled_publication = Time.zone.now + 2.days

    expect(edition).to be_valid
  end
end
