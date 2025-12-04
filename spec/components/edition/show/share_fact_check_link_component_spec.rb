RSpec.describe Edition::Show::ShareFactCheckLinkComponent, type: :component do
  let(:document) { build(:document, :pension, content_id_alias: "content-id-alias") }
  let(:edition) { build_stubbed(:edition, :pension, document: document) }

  it "renders the share link" do
    render_inline(described_class.new(edition: edition))

    within(".govuk-details") do |details|
      details.within(".govuk-details__summary") do |summary|
        expect(summary).to have_text("Share factcheck link")
      end

      details.within(".govuk-details__text") do |text|
        text.within("div[data-module='copy-to-clipboard']") do |copy_module|
          expect(copy_module).to have_css("input[value='#{fact_check_url_with_token(edition)}']")
        end

        text.within("form[action=#{update_fact_check_preview_link_edition_path(edition)}]") do
          expect(page).to have_css("button[type='submit']", text: "Reset preview link")
        end
      end
    end
  end

  it "renders a form to update the preview link" do
    render_inline(described_class.new(edition: edition))

    within(".govuk-details__text") do |text|
      text.within("form[action=#{update_fact_check_preview_link_edition_path(edition)}]") do
        expect(page).to have_css("button[type='submit']", text: "Reset preview link")
      end
    end
  end

  it "does not render the details component as open by default" do
    render_inline(described_class.new(edition: edition))

    expect(page).not_to have_css(".govuk-details[open]")
  end

  context "when open is set to true" do
    before do
      render_inline(described_class.new(edition: edition, open: true))
    end

    it "renders the details component as open" do
      render_inline(described_class.new(edition: edition))

      expect(page).not_to have_css(".govuk-details[open]")
    end
  end
end
