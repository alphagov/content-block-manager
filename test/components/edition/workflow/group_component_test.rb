require "test_helper"

class Edition::Workflow::GroupComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:details) do
    {
      "embedded-type-1" => {
        "embedded-type-1-item-1" => {},
        "embedded-type-1-item-2" => {},
      },
      "embedded-type-2" => {
        "embedded-type-2-item-1" => {},
        "embedded-type-2-item-2" => {},
        "embedded-type-2-item-3" => {},
      },
      "embedded-type-3" => {},
    }
  end
  let(:edition) { build(:edition, :pension, details:) }

  let(:subschema_1) { stub("subschema_1", id: "embedded-type-1", block_type: "embedded-type-1", name: "first embedded types", group_order: 1) }
  let(:subschema_2) { stub("subschema_2", id: "embedded-type-1", block_type: "embedded-type-2", name: "second embedded types", group_order: 0) }
  let(:subschema_3) { stub("subschema_3", id: "embedded-type-3", block_type: "embedded-type-3", name: "third embedded types", group_order: 2) }

  let(:subschemas) do
    [
      subschema_1,
      subschema_2,
      subschema_3,
    ]
  end

  let(:component) do
    Edition::Workflow::GroupComponent.new(
      edition:,
      subschemas:,
    )
  end

  let(:request) { stub(:request, fullpath: "/foo/bar") }

  before do
    component.stubs(:request).returns(request)
  end

  it "should render a tab for each subschema that has content" do
    summary_card_stub_1 = stub("SummaryCard")
    summary_card_stub_2 = stub("SummaryCard")

    Shared::EmbeddedObjects::SummaryCardComponent.expects(:with_collection).with(
      %w[embedded-type-1-item-1 embedded-type-1-item-2],
      edition: edition,
      object_type: subschema_1.block_type,
      redirect_url: request.fullpath,
    ).returns(summary_card_stub_1)

    Shared::EmbeddedObjects::SummaryCardComponent.expects(:with_collection).with(
      %w[embedded-type-2-item-1 embedded-type-2-item-2 embedded-type-2-item-3],
      edition: edition,
      object_type: subschema_2.block_type,
      redirect_url: request.fullpath,
    ).returns(summary_card_stub_2)

    component.expects(:render).with(summary_card_stub_1).returns("summary_card_1_body")
    component.expects(:render).with(summary_card_stub_2).returns("summary_card_2_body")

    component.expects(:render).with("govuk_publishing_components/components/tabs", {
      tabs: [
        {
          id: subschema_2.id,
          label: "Second embedded type (3)",
          content: "summary_card_2_body",
        },
        {
          id: subschema_1.id,
          label: "First embedded type (2)",
          content: "summary_card_1_body",
        },
      ],
    })

    render_inline component
  end

  context "when there are multiple block types, each with more than one instance" do
    let(:details) do
      {
        "addresses" => {
          "main-address" => {},
          "other-address" => {},
        },
        "telephones" => {
          "office-number" => {},
          "home-number" => {},
          "overseas-number" => {},
        },
      }
    end

    let(:address_subschema) do
      stub("addresses", {
        id: "addresses",
        block_type: "addresses",
        name: "Addresses",
        group_order: 1,
        fields: [],
      })
    end

    let(:phone_subschema) do
      stub("telephones", {
        id: "telephones",
        block_type: "telephones",
        name: "Telephones",
        group_order: 0,
        fields: [],
      })
    end

    let(:subschemas) { [address_subschema, phone_subschema] }
    let(:schema) { stub(:schema) }
    let(:document) { stub(:document, schema: schema) }
    let(:edition) { build(:edition, :pension, details: details, id: 1) }

    before do
      schema.stubs(:subschema).with("addresses").returns(address_subschema)
      schema.stubs(:subschema).with("telephones").returns(phone_subschema)
      edition.stubs(:document).returns(document)
    end

    describe "the headings" do
      it "should be unique" do
        render_inline component

        h2_tags_text = page.find_all("h2.govuk-summary-card__title").map { |e| e.text.strip }

        assert_equal  ["Telephone details 1",
                       "Telephone details 2",
                       "Telephone details 3",
                       "Address details 1",
                       "Address details 2"],
                      h2_tags_text
      end

      it "should be sequentially numbered within each block type" do
        render_inline component

        telephone_heading_numbers = page.find_all(".govuk-tabs__panel#telephones h2.govuk-summary-card__title")
                                      .map { |e| e.text.strip[-1].to_i }

        address_heading_numbers = page.find_all(".govuk-tabs__panel#addresses h2.govuk-summary-card__title")
                                    .map { |e| e.text.strip[-1].to_i }

        assert_equal([1, 2, 3], telephone_heading_numbers)
        assert_equal([1, 2], address_heading_numbers)
      end
    end
  end
end
