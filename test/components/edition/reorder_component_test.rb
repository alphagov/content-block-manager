require "test_helper"

class Edition::ReorderComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:edition) { build_stubbed(:edition) }
  let(:order) do
    %w[
      email_addresses.email_address_1
      email_addresses.email_address_2
      telephones.telephone_1
    ]
  end
  let(:component) { Edition::ReorderComponent.new(edition:, order:) }

  before do
    edition.stubs(:clone_without_blocks).returns(stub(:edition, render: "WITHOUT BLOCKS"))
    edition.stubs(:clone_with_block).with("email_addresses.email_address_1").returns(stub(:edition, render: "email_addresses.email_address_1"))
    edition.stubs(:clone_with_block).with("email_addresses.email_address_2").returns(stub(:edition, render: "email_addresses.email_address_2"))
    edition.stubs(:clone_with_block).with("telephones.telephone_1").returns(stub(:edition, render: "telephones.telephone_1"))
  end

  it "renders each part of the edition within their own constituent parts" do
    render_inline component

    assert_selector ".app-c-content-block-manager-reorder-component" do |wrapper|
      wrapper.assert_selector ".govspeak:nth-child(1)", text: "WITHOUT BLOCKS"

      wrapper.assert_selector ".app-c-content-block-manager-reorder-component__item:nth-child(2)" do |item|
        item.assert_selector ".govspeak", text: "email_addresses.email_address_1"
      end

      wrapper.assert_selector ".app-c-content-block-manager-reorder-component__item:nth-child(3)" do |item|
        item.assert_selector ".govspeak", text: "email_addresses.email_address_2"
      end

      wrapper.assert_selector ".app-c-content-block-manager-reorder-component__item:nth-child(4)" do |item|
        item.assert_selector ".govspeak", text: "telephones.telephone_1"
      end
    end
  end
end
