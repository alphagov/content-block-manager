RSpec.describe Edition::Details::EmbeddedObjects::CancelComponent, type: :component do
  context "when a redirect_url is supplied" do
    let(:back_link) { double("back_link") }

    let(:component) do
      described_class.new(
        back_link: back_link,
        redirect_url: "/redirect/to/location",
      )
    end

    it "links to the given redirect_url" do
      render_inline component

      expect(page).to have_css("a[href='/redirect/to/location']")
    end
  end

  context "when a redirect_url is NOT supplied" do
    let(:back_link) { "/link/back" }

    let(:component) do
      described_class.new(
        back_link: back_link,
        redirect_url: nil,
      )
    end

    it "links to the given back_link" do
      render_inline component

      expect(page).to have_css("a[href='/link/back']")
    end
  end
end
