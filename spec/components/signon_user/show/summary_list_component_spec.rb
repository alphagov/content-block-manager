RSpec.describe SignonUser::Show::SummaryListComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:organisation) { build(:signon_user_organisation, name: "Department for Example") }
  let(:user) do
    build(
      :signon_user,
      name: "John Smith",
      email: "john.smith@example.com",
      organisation:,
    )
  end

  it "renders a Govuk User correctly" do
    render_inline(described_class.new(user:))

    expect(page).to have_css ".govuk-summary-list__row", count: 3

    expect(page).to have_css ".govuk-summary-list__key", text: "Name"
    expect(page).to have_css ".govuk-summary-list__value", text: user.name

    expect(page).to have_css ".govuk-summary-list__key", text: "Email"
    expect(page).to have_css ".govuk-summary-list__value", text: user.email

    expect(page).to have_css ".govuk-summary-list__key", text: "Organisation"
    expect(page).to have_css ".govuk-summary-list__value", text: user.organisation.name
  end
end
