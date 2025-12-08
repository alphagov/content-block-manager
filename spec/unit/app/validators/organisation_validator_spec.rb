RSpec.describe OrganisationValidator do
  it "validates the presence of a lead organisation" do
    document = build(:document, :pension)
    edition = build(:edition, lead_organisation_id: nil, document:)

    expect(edition).to be_invalid
    expect(edition.errors.full_messages).to eq([I18n.t("activerecord.errors.models.edition.blank", attribute: "Lead organisation")])
  end
end
