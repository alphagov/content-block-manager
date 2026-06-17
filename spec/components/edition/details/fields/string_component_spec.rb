RSpec.describe Edition::Details::Fields::StringComponent, type: :component do
  let(:edition) { build(:edition, :pension) }
  let(:field) { build("field", name: "email_address", is_required?: true, default_value: nil, label: "Email address") }
  let(:schema) { double(:schema, block_type: "schema") }

  let(:context) do
    Edition::Details::Fields::Context.new(edition:, field:, schema:)
  end

  let(:described_class) { Edition::Details::Fields::StringComponent }
  let(:component) { described_class.new(context) }

  it_behaves_like "a field component", field_type: "input"

  context "when an input prefix is defined" do
    before do
      expect(context).to receive(:input_prefix).and_return("£")
    end

    it "should render the input prefix" do
      render_inline component

      expect(page).to have_content "£"
    end
  end
end
