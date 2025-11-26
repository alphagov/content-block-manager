RSpec.describe Shared::SchedulePublishingComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:document) { create(:document, :pension) }
  let(:edition) { create(:edition, :pension, document: document) }
  let(:params) { {} }
  let(:context) { "Some context" }
  let(:back_link) { "/back-link" }
  let(:form_url) { "/form-url" }

  let(:rescheduling_component) do
    described_class.new(
      edition:,
      params:,
      context:,
      back_link:,
      form_url:,
      is_rescheduling: true,
    )
  end

  let(:component) do
    described_class.new(
      edition:,
      params:,
      context:,
      back_link:,
      form_url:,
      is_rescheduling: false,
    )
  end

  describe "when edition is being rescheduled" do
    it "renders the cancel button with back link" do
      render_inline(rescheduling_component)

      expect(page).to have_css "a[href='#{back_link}']", text: "Cancel"
    end
  end

  describe "when edition is not being rescheduled" do
    it "renders the cancel button with delete form" do
      render_inline(component)

      expect(page).to have_css ".govuk-button", text: "Cancel"
      expect(page).to have_css "form[action='#{edition_path(
        edition,
        redirect_path: document_path(document),
      )}']"
    end
  end

  describe "when the edition already has a publish date set" do
    let(:params) do
      {
        "scheduled_at" => {
          "scheduled_publication(1i)" => "2022",
          "scheduled_publication(2i)" => "2",
          "scheduled_publication(3i)" => "3",
          "scheduled_publication(4i)" => "1",
          "scheduled_publication(5i)" => "2",
        },
      }
    end

    it "prepopulates the date fields" do
      render_inline(component)

      expect(page).to have_css "input[name='scheduled_at[scheduled_publication(1i)]'][value='#{params['scheduled_at']['scheduled_publication(1i)']}']"
      expect(page).to have_css "input[name='scheduled_at[scheduled_publication(2i)]'][value='#{params['scheduled_at']['scheduled_publication(2i)']}']"
      expect(page).to have_css "input[name='scheduled_at[scheduled_publication(3i)]'][value='#{params['scheduled_at']['scheduled_publication(3i)']}']"

      expect(page).to have_css "select[name='scheduled_at[scheduled_publication(4i)]'] option[value='0#{params['scheduled_at']['scheduled_publication(4i)']}'][selected='selected']"
      expect(page).to have_css "select[name='scheduled_at[scheduled_publication(5i)]'] option[value='0#{params['scheduled_at']['scheduled_publication(5i)']}'][selected='selected']"
    end
  end

  describe "when the params have date attributes set" do
    let(:scheduled_publication) { Time.zone.now + 1.month }
    let(:edition) { create(:edition, :pension, document: document, scheduled_publication:) }

    it "prepopulates the date fields" do
      render_inline(component)

      expect(page).to have_css "input[name='scheduled_at[scheduled_publication(1i)]'][value='#{scheduled_publication.year}']"
      expect(page).to have_css "input[name='scheduled_at[scheduled_publication(2i)]'][value='#{scheduled_publication.month}']"
      expect(page).to have_css "input[name='scheduled_at[scheduled_publication(3i)]'][value='#{scheduled_publication.day}']"

      expect(page).to have_css "select[name='scheduled_at[scheduled_publication(4i)]'] option[value='#{scheduled_publication.hour}'][selected='selected']"
      expect(page).to have_css "select[name='scheduled_at[scheduled_publication(5i)]'] option[value='#{scheduled_publication.min}'][selected='selected']"
    end
  end

  describe "when data attributes are passed" do
    let(:component) do
      described_class.new(
        edition:,
        params:,
        context:,
        back_link:,
        form_url:,
        is_rescheduling: false,
        data_attributes: { data: { test: "test" } },
      )
    end

    it "renders the data attributes" do
      render_inline(component)

      expect(page).to have_css "form[data-test='test']"
    end
  end
end
