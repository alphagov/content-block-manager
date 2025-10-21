require "test_helper"

class Document::Show::EmbeddedObjects::BlocksComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:items) do
    {
      "foo" => "bar",
      "fizz" => "buzz",
    }
  end
  let(:object_type) { "something" }
  let(:object_title) { "else" }

  let(:edition) { build(:edition, :pension) }
  let(:document) { build(:document, :pension) }

  let(:schema) { stub("schema", block_type: "schema") }
  let(:subschema) do
    stub("subschema",
         embeddable_as_block?: embeddable_as_block,
         block_type: "subschema",
         hidden_field?: false)
  end
  let(:schema_name) { "schema_name" }

  before do
    document.stubs(:schema).returns(schema)
    document.stubs(:latest_edition).returns(edition)
    schema.stubs(:subschema).with(object_type).returns(subschema)
  end

  let(:component) do
    Document::Show::EmbeddedObjects::BlocksComponent.new(
      items:,
      object_type:,
      schema_name:,
      object_title:,
      document:,
    )
  end

  describe "when the block type is not embeddable as a block" do
    let(:embeddable_as_block) { false }

    it "renders a summary card" do
      render_inline component

      assert_selector ".app-c-embedded-objects-blocks-component .govuk-summary-list__row", count: 2

      expect_summary_list_row(test_id: "else_foo", key: "Foo", value: "bar", embed_code_suffix: "foo")
      expect_summary_list_row(test_id: "else_fizz", key: "Fizz", value: "buzz", embed_code_suffix: "fizz")
    end

    it "calls key_to_label with the correct parameters for attribute rows" do
      component.expects(:key_to_label).with("foo", schema_name, object_type).returns("Foo")
      component.expects(:key_to_label).with("fizz", schema_name, object_type).returns("Fizz")

      render_inline component
    end

    it "includes embed code and details in the row's data attrs along with name of JS module to be invoked" do
      render_inline component

      %w[foo fizz].each do |portion|
        row = ".govuk-summary-list__row[data-testid='else_#{portion}']"
        embed_code = "[data-embed-code='{{embed:content_block_pension:/something/else/#{portion}}}']"
        embed_code_details_for_hidden_accessibility_info = "[data-embed-code-details='something/else/#{portion}']"
        js_module = "[data-module='copy-embed-code']"

        assert_selector(row)
        assert_selector("#{row}#{embed_code}")
        assert_selector("#{row}#{embed_code_details_for_hidden_accessibility_info}")
        assert_selector("#{row}#{js_module}")
      end
    end

    it "adds the correct class to the wrapper" do
      render_inline component

      assert_selector ".app-c-embedded-objects-blocks-component"
      refute_selector ".app-c-embedded-objects-blocks-component.app-c-embedded-objects-blocks-component--with-block"
    end

    it "does not render the details" do
      render_inline component

      refute_selector ".app-c-embedded-objects-blocks-component__details-wrapper"
    end

    describe "when items contain an array" do
      let(:items) do
        {
          "things" => %w[foo bar],
        }
      end

      it "renders a summary card" do
        render_inline component

        assert_selector ".app-c-embedded-objects-blocks-component .govuk-summary-list__row", count: 2

        expect_summary_list_row(test_id: "else_things/0", key: "Thing 1", value: "foo", embed_code_suffix: "things/0")
        expect_summary_list_row(test_id: "else_things/1", key: "Thing 2", value: "bar", embed_code_suffix: "things/1")
      end

      it "calls key_to_label with the correct parameters for array items" do
        component.expects(:key_to_label).with("things/0", schema_name, object_type).returns("Thing 1")
        component.expects(:key_to_label).with("things/1", schema_name, object_type).returns("Thing 2")

        render_inline component
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

      it "renders a summary card" do
        render_inline component

        assert_selector ".app-c-embedded-objects-blocks-component .govuk-summary-list__row", count: 4

        assert_selector ".gem-c-summary-card[title='Thing 1']" do |summary_card|
          expect_summary_list_row(test_id: "else_things/0/title", key: "Title", value: "Title 1", embed_code_suffix: "things/0/title", parent_container: summary_card)
          expect_summary_list_row(test_id: "else_things/0/value", key: "Value", value: "Value 1", embed_code_suffix: "things/0/value", parent_container: summary_card)
        end

        assert_selector ".gem-c-summary-card[title='Thing 2']" do |summary_card|
          expect_summary_list_row(test_id: "else_things/1/title", key: "Title", value: "Title 2", embed_code_suffix: "things/1/title", parent_container: summary_card)
          expect_summary_list_row(test_id: "else_things/1/value", key: "Value", value: "Value 2", embed_code_suffix: "things/1/value", parent_container: summary_card)
        end
      end

      it "calls key_to_label with the correct parameters for nested items" do
        component.expects(:key_to_label).with("title", schema_name, "#{object_type}.things").returns("Title").twice
        component.expects(:key_to_label).with("value", schema_name, "#{object_type}.things").returns("Value").twice

        render_inline component
      end

      context "when a field is configured to be 'hidden', e.g. it's an internal flag" do
        before do
          subschema.stubs(:hidden_field?)
                   .with(field_name: "value", nested_object_key: "things")
                   .returns(true)
        end

        it "is not displayed" do
          render_inline component

          assert_selector ".app-c-embedded-objects-blocks-component .govuk-summary-list__row", count: 2

          assert_selector ".gem-c-summary-card[title='Thing 1']" do
            refute_selector "[data-testid='else_things/0/value}']"
          end

          assert_selector ".gem-c-summary-card[title='Thing 2']" do
            refute_selector "[data-testid='else_things/1/value}']"
          end
        end

        it "calls key_to_label only for visible fields" do
          component.expects(:key_to_label).with("title", schema_name, "#{object_type}.things").returns("Title").twice
          component.expects(:key_to_label).with("value", schema_name, "#{object_type}.things").never

          render_inline component
        end
      end
    end
  end

  describe "when the block type is embeddable as a block" do
    let(:embeddable_as_block) { true }

    before do
      edition.expects(:render).with(
        document.embed_code_for_field("#{object_type}/#{object_title}"),
      ).returns("BLOCK_RESPONSE")
    end

    it "returns the block inside the summary card" do
      render_inline component

      assert_selector ".app-c-embedded-objects-blocks-component .govuk-summary-card" do |wrapper|
        wrapper.assert_selector ".govuk-summary-card__title", text: "Something block"

        wrapper.assert_selector ".govuk-summary-list__row", count: 1

        expect_summary_list_row(test_id: "else", key: "Something", value: "BLOCK_RESPONSE")
      end
    end

    it "shows the details component with the attributes in a summary list" do
      render_inline component

      assert_selector ".app-c-embedded-objects-blocks-component__details-wrapper" do |wrapper|
        wrapper.assert_selector ".govuk-details__summary-text", text: "All #{object_type} attributes"
        wrapper.assert_selector ".govuk-details__text", visible: false do |details|
          details.assert_selector ".app-c-embedded-objects-blocks-component__details-text",
                                  text: "These are all the #{object_type} attributes that make up the #{object_type}. You can use any available embed code for each attribute separately in your content if required.",
                                  visible: false

          details.assert_selector ".app-c-embedded-objects-blocks-component__details-summary-list", visible: false do |summary_list|
            summary_list.assert_selector ".govuk-summary-list__row", count: 2, visible: false

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

      assert_selector ".app-c-embedded-objects-blocks-component__details-wrapper" do |wrapper|
        wrapper.assert_selector "summary[aria-label='else']" do |summary|
          summary.assert_selector ".govuk-details__summary-text", text: "All something attributes"
        end
      end
    end

    it "calls key_to_label with the correct parameters for attribute rows in details" do
      component.expects(:key_to_label).with("foo", schema_name, object_type).returns("Foo")
      component.expects(:key_to_label).with("fizz", schema_name, object_type).returns("Fizz")

      render_inline component
    end

    it "adds the correct class to the wrapper" do
      render_inline component

      assert_selector ".app-c-embedded-objects-blocks-component.app-c-embedded-objects-blocks-component--with-block"
    end

    describe "when items contain an array" do
      let(:items) do
        {
          "things" => %w[foo bar],
        }
      end

      it "renders a summary card" do
        render_inline component

        assert_selector ".app-c-embedded-objects-blocks-component__details-summary-list", visible: false do |summary_list|
          summary_list.assert_selector ".govuk-summary-list__row", count: 2, visible: false

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

      it "calls key_to_label with the correct parameters for array items in details" do
        component.expects(:key_to_label).with("things/0", schema_name, object_type).returns("Thing 1")
        component.expects(:key_to_label).with("things/1", schema_name, object_type).returns("Thing 2")

        render_inline component
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

      it "renders a summary card" do
        render_inline component

        assert_selector ".app-c-embedded-objects-blocks-component__details-summary-list", visible: false do |summary_list|
          summary_list.assert_selector ".gem-c-summary-card[title='Thing 1']", visible: false do |summary_card|
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

          summary_list.assert_selector ".gem-c-summary-card[title='Thing 2']", visible: false do |summary_card|
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

      it "calls key_to_label with the correct parameters for nested items in details" do
        component.expects(:key_to_label).with("title", schema_name, "#{object_type}.things").returns("Title").twice
        component.expects(:key_to_label).with("value", schema_name, "#{object_type}.things").returns("Value").twice

        render_inline component
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
    parent_container.assert_selector "[data-testid='#{test_id}']", visible: visible do |row|
      row.assert_selector ".govuk-summary-list__key", text: key, visible: visible
      row.assert_selector ".govuk-summary-list__value", visible: visible do |col|
        col.assert_selector ".app-c-embedded-objects-blocks-component__content.govspeak", text: value, visible: visible
        col.assert_selector ".app-c-embedded-objects-blocks-component__embed-code", text: document.embed_code_for_field([object_type, object_title, embed_code_suffix].compact.join("/")), visible: visible
      end
    end
  end
end
