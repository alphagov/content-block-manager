RSpec.describe Edition::Show::EmbeddedObjects::BlocksComponent, type: :component do
  let(:items) do
    {
      "foo" => "bar",
      "fizz" => "buzz",
    }
  end
  let(:object_type) { "something" }
  let(:object_title) { "else" }

  let(:document) { build(:document, :pension) }
  let(:edition) { build(:edition, :pension, document: document) }

  let(:schema) { double("schema", block_type: "schema") }
  let(:subschema) do
    double("subschema",
           embeddable_as_block?: embeddable_as_block,
           block_type: "subschema")
  end
  let(:schema_name) { "schema_name" }

  let(:foo_field) { build(:field, label: "Foo") }
  let(:fizz_field) { build(:field, label: "Fizz") }

  before do
    allow(document).to receive(:schema).and_return(schema)
    allow(schema).to receive(:subschema).with(object_type).and_return(subschema)
    allow(subschema).to receive(:field).with("foo").and_return(foo_field)
    allow(subschema).to receive(:field).with("fizz").and_return(fizz_field)
  end

  let(:component) do
    described_class.new(
      items:,
      object_type:,
      schema_name:,
      object_title:,
      edition: edition,
    )
  end

  describe "when the block type is not embeddable as a block" do
    let(:embeddable_as_block) { false }

    it "renders a summary card" do
      render_inline component

      expect(page).to have_css ".app-c-embedded-objects-blocks-component .govuk-summary-list__row", count: 2

      expect_summary_list_row(test_id: "else_foo", key: "Foo", value: "bar", embed_code_suffix: "foo")
      expect_summary_list_row(test_id: "else_fizz", key: "Fizz", value: "buzz", embed_code_suffix: "fizz")
    end

    it "includes embed code and details in the row's data attrs along with name of JS module to be invoked" do
      render_inline component

      %w[foo fizz].each do |portion|
        row = ".govuk-summary-list__row[data-testid='else_#{portion}']"
        embed_code = "[data-embed-code='{{embed:content_block_pension:/something/else/#{portion}}}']"
        embed_code_details_for_hidden_accessibility_info = "[data-embed-code-details='something/else/#{portion}']"
        js_module = "[data-module='copy-embed-code']"

        expect(page).to have_css(row)
        expect(page).to have_css("#{row}#{embed_code}")
        expect(page).to have_css("#{row}#{embed_code_details_for_hidden_accessibility_info}")
        expect(page).to have_css("#{row}#{js_module}")
      end
    end

    it "adds the correct class to the wrapper" do
      render_inline component

      expect(page).to have_css ".app-c-embedded-objects-blocks-component"
      expect(page).to_not have_css ".app-c-embedded-objects-blocks-component.app-c-embedded-objects-blocks-component--with-block"
    end

    it "does not render the details" do
      render_inline component

      expect(page).to_not have_css ".app-c-embedded-objects-blocks-component__details-wrapper"
    end

    describe "when items contain an array" do
      let(:items) do
        {
          "things" => %w[foo bar],
        }
      end

      let(:things_field) { build(:field, label: "Things") }

      before do
        allow(subschema).to receive(:field).with("things").and_return(things_field)
      end

      it "renders a summary card" do
        render_inline component

        expect(page).to have_css ".app-c-embedded-objects-blocks-component .govuk-summary-list__row", count: 2

        expect_summary_list_row(test_id: "else_things/0", key: "Thing 1", value: "foo", embed_code_suffix: "things/0")
        expect_summary_list_row(test_id: "else_things/1", key: "Thing 2", value: "bar", embed_code_suffix: "things/1")
      end
    end

    describe "when items contain an array of objects" do
      let(:items) do
        {
          "things" => [
            {
              "title" => "Title 1",
              "value" => "Value 1",
            },
            {
              "title" => "Title 2",
              "value" => "Value 2",
            },
          ],
        }
      end

      let(:field) { build(:field, hidden?: false, title: "Thing") }
      let(:title_field) { build(:field, hidden?: false, label: "Title") }
      let(:value_field) { build(:field, hidden?: false, label: "Value") }

      before do
        allow(subschema).to receive(:field).with("things").and_return(field)
        allow(field).to receive(:nested_field).with("title").and_return(title_field)
        allow(field).to receive(:nested_field).with("value").and_return(value_field)
      end

      it "renders a summary card" do
        render_inline component

        expect(page).to have_css ".app-c-embedded-objects-blocks-component .govuk-summary-list__row", count: 4

        expect(page).to have_css ".gem-c-summary-card[title='Thing 1']" do |summary_card|
          expect_summary_list_row(test_id: "else_things/0/title", key: "Title", value: "Title 1", embed_code_suffix: "things/0/title", parent_container: summary_card)
          expect_summary_list_row(test_id: "else_things/0/value", key: "Value", value: "Value 1", embed_code_suffix: "things/0/value", parent_container: summary_card)
        end

        expect(page).to have_css ".gem-c-summary-card[title='Thing 2']" do |summary_card|
          expect_summary_list_row(test_id: "else_things/1/title", key: "Title", value: "Title 2", embed_code_suffix: "things/1/title", parent_container: summary_card)
          expect_summary_list_row(test_id: "else_things/1/value", key: "Value", value: "Value 2", embed_code_suffix: "things/1/value", parent_container: summary_card)
        end
      end

      context "when a field is configured to be 'hidden', e.g. it's an internal flag" do
        let(:value_field) { build(:field, hidden?: true) }

        it "is not displayed" do
          render_inline component

          expect(page).to have_css ".app-c-embedded-objects-blocks-component .govuk-summary-list__row", count: 2

          expect(page).to have_css ".gem-c-summary-card[title='Thing 1']" do
            expect(page).to_not have_css "[data-testid='else_things/0/value}']"
          end

          expect(page).to have_css ".gem-c-summary-card[title='Thing 2']" do
            expect(page).to_not have_css "[data-testid='else_things/1/value}']"
          end
        end
      end
    end
  end

  describe "when the block type is embeddable as a block" do
    let(:embeddable_as_block) { true }

    before do
      expect(edition).to receive(:render).with(
        document.embed_code_for_field("#{object_type}/#{object_title}"),
      ).and_return("BLOCK_RESPONSE")
    end

    it "returns the block inside the summary card" do
      render_inline component

      expect(page).to have_css ".app-c-embedded-objects-blocks-component .govuk-summary-card" do |_wrapper|
        expect(page).to have_css ".govuk-summary-card__title", text: "Something block"

        expect(page).to have_css ".govuk-summary-list__row", count: 1

        expect_summary_list_row(test_id: "else", key: "Something", value: "BLOCK_RESPONSE")
      end
    end

    it "shows the details component with the attributes in a summary list" do
      render_inline component

      expect(page).to have_css ".app-c-embedded-objects-blocks-component__details-wrapper" do |wrapper|
        expect(wrapper).to have_css ".govuk-details__summary-text", text: "All #{object_type} attributes"
        expect(wrapper).to have_css ".govuk-details__text", visible: false do |details|
          expect(details).to have_css ".app-c-embedded-objects-blocks-component__details-text",
                                      text: "These are all the #{object_type} attributes that make up the #{object_type}. You can use any available embed code for each attribute separately in your content if required.",
                                      visible: false

          expect(details).to have_css ".app-c-embedded-objects-blocks-component__details-summary-list", visible: false do |summary_list|
            expect(summary_list).to have_css ".govuk-summary-list__row", count: 2, visible: false

            expect_summary_list_row(
              test_id: "else_foo",
              key: "Foo",
              value: "bar",
              embed_code_suffix: "foo",
              visible: false,
              parent_container: summary_list,
            )

            expect_summary_list_row(
              test_id: "else_fizz",
              key: "Fizz",
              value: "buzz",
              embed_code_suffix: "fizz",
              visible: false,
              parent_container: summary_list,
            )
          end
        end
      end
    end

    it "uses aria-label to distinguish the link to 'all attributes' of _else_ object of type _something_" do
      render_inline component

      expect(page).to have_css ".app-c-embedded-objects-blocks-component__details-wrapper" do |wrapper|
        expect(wrapper).to have_css "summary[aria-label='else']" do |wrapper|
          expect(wrapper).to have_css ".govuk-details__summary-text", text: "All something attributes"
        end
      end
    end

    it "adds the correct class to the wrapper" do
      render_inline component

      expect(page).to have_css ".app-c-embedded-objects-blocks-component.app-c-embedded-objects-blocks-component--with-block"
    end

    describe "when items contain an array" do
      let(:items) do
        {
          "things" => %w[foo bar],
        }
      end

      let(:things_field) { build(:field, label: "Things") }

      before do
        allow(subschema).to receive(:field).with("things").and_return(things_field)
      end

      it "renders a summary card" do
        render_inline component

        expect(page).to have_css ".app-c-embedded-objects-blocks-component__details-summary-list", visible: false do |summary_list|
          expect(summary_list).to have_css ".govuk-summary-list__row", count: 2, visible: false

          expect_summary_list_row(
            test_id: "else_things/0",
            key: "Thing 1",
            value: "foo",
            embed_code_suffix: "things/0",
            visible: false,
            parent_container: summary_list,
          )

          expect_summary_list_row(
            test_id: "else_things/1",
            key: "Thing 2",
            value: "bar",
            embed_code_suffix: "things/1",
            visible: false,
            parent_container: summary_list,
          )
        end
      end
    end

    describe "when items contain an array of objects" do
      let(:items) do
        {
          "things" => [
            {
              "title" => "Title 1",
              "value" => "Value 1",
            },
            {
              "title" => "Title 2",
              "value" => "Value 2",
            },
          ],
        }
      end

      let(:field) { build(:field, hidden?: false, title: "Thing") }
      let(:title_field) { build(:field, hidden?: false, label: "Title") }
      let(:value_field) { build(:field, hidden?: false, label: "Value") }

      before do
        allow(subschema).to receive(:field).with("things").and_return(field)
        allow(field).to receive(:nested_field).with("title").and_return(title_field)
        allow(field).to receive(:nested_field).with("value").and_return(value_field)
      end

      it "renders a summary card" do
        render_inline component

        expect(page).to have_css ".app-c-embedded-objects-blocks-component__details-summary-list", visible: false do |summary_list|
          expect(summary_list).to have_css ".gem-c-summary-card[title='Thing 1']", visible: false do |summary_card|
            expect_summary_list_row(
              test_id: "else_things/0/title",
              key: "Title",
              value: "Title 1",
              embed_code_suffix: "things/0/title",
              visible: false,
              parent_container: summary_card,
            )

            expect_summary_list_row(
              test_id: "else_things/0/value",
              key: "Value",
              value: "Value 1",
              embed_code_suffix: "things/0/value",
              visible: false,
              parent_container: summary_card,
            )
          end

          expect(summary_list).to have_css ".gem-c-summary-card[title='Thing 2']", visible: false do |summary_card|
            expect_summary_list_row(
              test_id: "else_things/1/title",
              key: "Title",
              value: "Title 2",
              embed_code_suffix: "things/1/title",
              visible: false,
              parent_container: summary_card,
            )

            expect_summary_list_row(
              test_id: "else_things/1/value",
              key: "Value",
              value: "Value 2",
              embed_code_suffix: "things/1/value",
              visible: false,
              parent_container: summary_card,
            )
          end
        end
      end
    end
  end

  def expect_summary_list_row(
    test_id:,
    key:,
    value:,
    embed_code_suffix: nil,
    visible: true,
    parent_container: page
  )
    expect(parent_container).to have_css "[data-testid='#{test_id}']", visible: visible do |row|
      expect(row).to have_css ".govuk-summary-list__key", text: key, visible: visible
      expect(row).to have_css ".govuk-summary-list__value", visible: visible do |col|
        expect(col).to have_css ".app-c-embedded-objects-blocks-component__content.govspeak", text: value, visible: visible
        expect(col).to have_css ".app-c-embedded-objects-blocks-component__embed-code", text: document.embed_code_for_field([object_type, object_title, embed_code_suffix].compact.join("/")), visible: visible
      end
    end
  end
end
