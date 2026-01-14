RSpec.describe Edition::Show::EmbeddedObjects::Blocks::NestedBlockComponent, type: :component do
  let(:items) do
    {
      "foo" => "bar",
      "fizz" => "buzz",
    }
  end
  let(:field) { double("field", title: "Nested Field", name: "nested_field") }
  let(:document) { build(:document, :pension) }
  let(:embed_code_prefix) { "prefix" }
  let(:items_counter) { nil }

  let(:foo_field) { double("foo_field", label: "Foo", name: "foo", hidden?: false, govspeak_enabled?: false) }
  let(:fizz_field) { double("fizz_field", label: "Fizz", name: "fizz", hidden?: false, govspeak_enabled?: false) }

  before do
    allow(field).to receive(:nested_field).with("foo").and_return(foo_field)
    allow(field).to receive(:nested_field).with("fizz").and_return(fizz_field)
    allow_any_instance_of(described_class).to receive(:translated_value) { |_instance, _name, value| value }
  end

  let(:component) do
    described_class.new(
      items:,
      field:,
      document:,
      embed_code_prefix:,
      items_counter:,
    )
  end

  it "renders a summary card with rows for flat items" do
    render_inline component

    expect(page).to have_css ".gem-c-summary-card"
    expect(page).to have_css ".govuk-summary-list__row", count: 2

    expect_summary_list_row(test_id: "prefix/foo", key: "Foo", value: "bar", embed_code_suffix: "foo")
    expect_summary_list_row(test_id: "prefix/fizz", key: "Fizz", value: "buzz", embed_code_suffix: "fizz")
  end

  context "when items_counter is provided" do
    let(:items_counter) { 0 }

    before do
      allow(field).to receive(:title).and_return("Nested Fields")
    end

    it "renders the title with the counter" do
      render_inline component

      expect(page).to have_css ".govuk-summary-card__title", text: "Nested Field 1"
    end

    it "includes the counter in embed codes" do
      render_inline component

      expect_summary_list_row(test_id: "prefix/0/foo", key: "Foo", value: "bar", embed_code_suffix: "0/foo")
    end
  end

  context "when a field is hidden" do
    let(:fizz_field) { double("fizz_field", label: "Fizz", name: "fizz", hidden?: true) }

    it "does not render the hidden field" do
      render_inline component

      expect(page).to have_css ".govuk-summary-list__row", count: 1
      expect(page).to_not have_css "[data-testid='prefix/fizz']"
    end
  end

  context "when govspeak is enabled for a field" do
    let(:foo_field) { double("foo_field", label: "Foo", name: "foo", hidden?: false, govspeak_enabled?: true) }

    it "renders govspeak content" do
      allow_any_instance_of(described_class).to receive(:render_govspeak).with("bar").and_return("<strong>bar</strong>".html_safe)

      render_inline component

      expect(page).to have_css ".app-c-embedded-objects-blocks-component__content.govspeak", text: "bar"
      expect(page).to have_css "strong", text: "bar"
    end
  end

  context "when there are nested items (hashes)" do
    let(:items) do
      {
        "foo" => "bar",
        "nested" => {
          "child" => "value",
        },
      }
    end
    let(:nested_field) { double("nested_field", title: "Child Field", name: "nested") }
    let(:child_field) { double("child_field", label: "Child", name: "child", hidden?: false, govspeak_enabled?: false) }

    before do
      allow(field).to receive(:nested_field).with("nested").and_return(nested_field)
      allow(nested_field).to receive(:nested_field).with("child").and_return(child_field)
    end

    it "renders recursively" do
      render_inline component

      expect_summary_list_row(test_id: "prefix/foo", key: "Foo", value: "bar", embed_code_suffix: "foo")

      expect(page).to have_css ".app-c-embedded-objects-blocks-component--nested"
      expect(page).to have_css ".gem-c-summary-card[title='Child Field']"
      expect_summary_list_row(test_id: "prefix/nested/child", key: "Child", value: "value", embed_code_suffix: "nested/child")
    end
  end

  context "when there are nested items (arrays of hashes)" do
    let(:items) do
      {
        "things" => [
          { "name" => "One" },
          { "name" => "Two" },
        ],
      }
    end
    let(:things_field) { double("things_field", title: "Things", name: "things") }
    let(:name_field) { double("name_field", label: "Name", name: "name", hidden?: false, govspeak_enabled?: false) }

    before do
      allow(field).to receive(:nested_field).with("things").and_return(things_field)
      allow(things_field).to receive(:nested_field).with("name").and_return(name_field)
    end

    it "renders recursively for each item in the collection" do
      render_inline component

      expect(page).to have_css ".gem-c-summary-card[title='Thing 1']"
      expect(page).to have_css ".gem-c-summary-card[title='Thing 2']"

      expect_summary_list_row(test_id: "prefix/things/0/name", key: "Name", value: "One", embed_code_suffix: "things/0/name")
      expect_summary_list_row(test_id: "prefix/things/1/name", key: "Name", value: "Two", embed_code_suffix: "things/1/name")
    end
  end

private

  def expect_summary_list_row(test_id:, key:, value:, embed_code_suffix:)
    expect(page).to have_css "[data-testid='#{test_id}']" do |row|
      expect(row).to have_css ".govuk-summary-list__key", text: key
      expect(row).to have_css ".govuk-summary-list__value" do |col|
        expect(col).to have_css ".app-c-embedded-objects-blocks-component__content.govspeak", text: value
        expect(col).to have_css ".app-c-embedded-objects-blocks-component__embed-code", text: document.embed_code_for_field("#{embed_code_prefix}/#{embed_code_suffix}")
      end
    end
  end
end
