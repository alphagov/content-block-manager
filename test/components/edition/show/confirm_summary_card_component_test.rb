require "test_helper"

class Edition::Show::ConfirmSummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

  let(:organisation) { build(:organisation, name: "Department for Example") }
  let(:document) { create(:document, :pension) }
  let(:edition) do
    build_stubbed(:edition, :pension,
                  title: "Some edition title",
                  details: { "interesting_fact" => "value of fact", "something" => { "else" => "value" } },
                  lead_organisation_id: organisation.id,
                  document: document)
  end
  let(:fields) do
    [
      stub("field", name: "interesting_fact"),
    ]
  end
  let(:schema) { stub(:schema, fields:) }
  let(:helper_stub) { stub(:helpers) }

  let(:component) do
    Edition::Show::ConfirmSummaryCardComponent.new(edition:)
  end

  before do
    document.expects(:schema).returns(schema)
    Organisation.stubs(:all).returns([organisation])
    component.stubs(:helpers).returns(helper_stub)
    helper_stub.stubs(:label_for_title).with(edition.block_type).returns("Translated title")
    helper_stub.stubs(:workflow_path).with(id: edition.id, step: :edit_draft).returns("/some-path")
  end

  it "it renders instructions to publishers" do
    edition.instructions_to_publishers = "some instructions"

    render_inline(Edition::Show::ConfirmSummaryCardComponent.new(
                    edition:,
                  ))

    assert_selector ".govuk-summary-list__key", text: "Instructions to publishers"
    assert_selector ".govuk-summary-list__value p", text: "some instructions"
  end

  it "renders a summary card component with the edition details to confirm" do
    document.stubs(:is_new_block?).returns(false)

    render_inline(component)

    assert_selector ".govuk-summary-list__row", count: 4

    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Translated title"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: "Some edition title"

    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Interesting fact"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "value of fact"

    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "Lead organisation"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: "Department for Example"

    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Instructions to publishers"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: "None"
  end
end
