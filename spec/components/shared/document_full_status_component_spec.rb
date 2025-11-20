RSpec.describe Shared::DocumentFullStatusComponent, type: :component do
  let(:dave) { create(:user, name: "dave") }
  let(:edition) { double(:edition) }
  let(:document) { double(Document, most_recent_edition: edition) }
  let(:component) { described_class.new(document: document) }

  before do
    allow(edition).to receive(:updated_at).and_return(Time.zone.at(0))
    allow(edition).to receive(:state).and_return("awaiting_2i")
    allow(edition).to receive(:creator).and_return(dave)
    render_inline(component)
  end

  context "when rendering the component" do
    it "should contain a tag with the Edition's status" do
      expect(page).to have_css(".govuk-tag[title='Status: Awaiting 2i']")
    end

    it "should contain a status line with the correct status text" do
      expect(page).to have_text("Sent for 2i review on 1 January 1970 at 1:00am by dave")
    end
  end
end
