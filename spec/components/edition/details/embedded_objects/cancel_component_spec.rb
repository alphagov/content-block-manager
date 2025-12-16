RSpec.describe Edition::Details::EmbeddedObjects::CancelComponent, type: :component do
  context "when a redirect_url is supplied" do
    let(:edition) { double("edition") }
    let(:subschema) { double("subschema") }

    let(:component) do
      described_class.new(
        edition: edition,
        subschema: subschema,
        redirect_url: "/redirect/to/location",
      )
    end

    it "links to the given redirect_url" do
      render_inline component

      expect(page).to have_css("a[href='/redirect/to/location']")
    end
  end

  context "when a redirect_url is NOT supplied" do
    let(:edition) { double("edition", id: 123) }
    let(:subschema) { double("subschema", block_type: "contact_link") }

    let(:component) do
      described_class.new(
        edition: edition,
        subschema: subschema,
        redirect_url: nil,
      )
    end

    it "links to the (embedded) workflow step for the given subschema block type" do
      render_inline component

      expect(page).to have_css("a[href='/editions/123/workflow/embedded_contact_link']")
    end
  end
end
