RSpec.describe BlockPreview::PreviewDetailsComponent, type: :component do
  let(:edition) { build(:edition, :pension, details: { "email_address": "example@example.com" }) }
  let(:block) { build(:content_block, edition:) }
  let(:preview_content) { double(:preview_content, instances_count: 2) }

  it "returns a list of details for preview content" do
    render_inline(
      described_class.new(
        block:,
        preview_content:,
      ),
    )

    expect(page).to have_css "li", count: 2
    expect(page).to have_css "li", text: "Email address: example@example.com"
    expect(page).to have_css "li", text: "Instances: 2"
  end

  context "when there are subschemas in the edition's details" do
    let(:edition) do
      build(:edition, :pension, details: {
        "description": "Basic state pension",
        "rates": {
          "rate1":
            { "title": "rate1", "amount": "£100.5", "frequency": "a week", "description": "" },
          "rate2":
            { "title": "rate2", "amount": "£11.1", "frequency": "a month", "description": "1111" },
        },
      })
    end
    it "returns a list of details for preview content" do
      render_inline(
        described_class.new(
          block:,
          preview_content:,
        ),
      )

      expect(page).to have_css "li", count: 2
      expect(page).to have_css "li", text: "Description: Basic state pension"
      expect(page).to have_css "li", text: "Instances: 2"
    end
  end
end
