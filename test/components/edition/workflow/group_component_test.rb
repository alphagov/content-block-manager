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

  let(:subschema_1) { stub("subschema_1", id: "embedded-1", block_type: "embedded-type-1", name: "first embedded types", group_order: 1) }
  let(:subschema_2) { stub("subschema_2", id: "embedded-3", block_type: "embedded-type-2", name: "second embedded types", group_order: 0) }
  let(:subschema_3) { stub("subschema_3", id: "embedded-6", block_type: "embedded-type-3", name: "third embedded types", group_order: 2) }

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
    summary_card_stub_1 = stub("SummaryCard", render_in: "<div>Summary card 1</div>")
    summary_card_stub_2 = stub("SummaryCard", render_in: "<div>Summary card 2</div>")

    Shared::EmbeddedObjects::SummaryCardComponent.expects(:new).with(
      object_title: "embedded-type-1-item-1",
      edition: edition,
      object_type: subschema_1.block_type,
      redirect_url: request.fullpath,
      object_count: 1,
    ).returns(summary_card_stub_1)
    Shared::EmbeddedObjects::SummaryCardComponent.expects(:new).with(
      object_title: "embedded-type-1-item-2",
      edition: edition,
      object_type: subschema_1.block_type,
      redirect_url: request.fullpath,
      object_count: 2,
    ).returns(summary_card_stub_1)

    Shared::EmbeddedObjects::SummaryCardComponent.expects(:new).with(
      object_title: "embedded-type-2-item-1",
      edition: edition,
      object_type: subschema_2.block_type,
      redirect_url: request.fullpath,
      object_count: 1,
    ).returns(summary_card_stub_2)
    Shared::EmbeddedObjects::SummaryCardComponent.expects(:new).with(
      object_title: "embedded-type-2-item-2",
      edition: edition,
      object_type: subschema_2.block_type,
      redirect_url: request.fullpath,
      object_count: 2,
    ).returns(summary_card_stub_2)
    Shared::EmbeddedObjects::SummaryCardComponent.expects(:new).with(
      object_title: "embedded-type-2-item-3",
      edition: edition,
      object_type: subschema_2.block_type,
      redirect_url: request.fullpath,
      object_count: 3,
    ).returns(summary_card_stub_2)

    render_inline component
  end
end
