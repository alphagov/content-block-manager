RSpec.describe Shared::CancelAndDeleteButtonComponent, type: :component do
  let(:url) { "/url" }

  let(:cancel_and_delete_component) do
    described_class.new(url:)
  end

  it "renders the delete form with given url" do
    render_inline(cancel_and_delete_component)

    expect(page).to have_css "form[action='#{url}']" do |form|
      expect(form).to have_css "button[value='delete']", text: "Cancel"
    end
  end
end
