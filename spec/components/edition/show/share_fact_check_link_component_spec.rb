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
      end
    end
  end
end
