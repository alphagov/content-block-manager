require "test_helper"

class Edition::ReorderComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

  let(:edition) { build_stubbed(:edition) }
  let(:order) do
    %w[
      email_addresses.email_address_1
      email_addresses.email_address_2
      telephones.telephone_1
    ]
  end
  let(:redirect_path) { "/foo/bar" }
  let(:component) { Edition::ReorderComponent.new(edition:, order:, redirect_path:) }

  before do
    edition.stubs(:clone_without_blocks).returns(stub(:edition, render: "WITHOUT BLOCKS"))
    edition.stubs(:clone_with_block).with("email_addresses.email_address_1").returns(stub(:edition, render: "email_addresses.email_address_1"))
    edition.stubs(:clone_with_block).with("email_addresses.email_address_2").returns(stub(:edition, render: "email_addresses.email_address_2"))
    edition.stubs(:clone_with_block).with("telephones.telephone_1").returns(stub(:edition, render: "telephones.telephone_1"))
  end

  it "renders each part of the edition within their own constituent parts" do
    render_inline component

    wrapper = page.find(".app-c-content-block-manager-reorder-component")
    wrapper.assert_selector ".govspeak:nth-child(1)", text: "WITHOUT BLOCKS"

    items = wrapper.all(".app-c-content-block-manager-reorder-component__item")

    assert_equal 3, items.count

    items[0].assert_selector ".govspeak", text: "email_addresses.email_address_1"
    items[1].assert_selector ".govspeak", text: "email_addresses.email_address_2"
    items[2].assert_selector ".govspeak", text: "telephones.telephone_1"
  end

  it "renders up and down buttons with the correct paths" do
    render_inline component

    wrapper = page.find(".app-c-content-block-manager-reorder-component")
    items = wrapper.all(".app-c-content-block-manager-reorder-component__item")

    assert_equal 3, items.count

    items[0].assert_no_selector "a", text: "Up"
    assert_button_exists(wrapper: items[0], label: "Down", order: %w[
      email_addresses.email_address_2
      email_addresses.email_address_1
      telephones.telephone_1
    ])

    assert_button_exists(wrapper: items[1], label: "Up", order: %w[
      email_addresses.email_address_2
      email_addresses.email_address_1
      telephones.telephone_1
    ])
    assert_button_exists(wrapper: items[1], label: "Down", order: %w[
      email_addresses.email_address_1
      telephones.telephone_1
      email_addresses.email_address_2
    ])

    assert_button_exists(wrapper: items[2], label: "Up", order: %w[
      email_addresses.email_address_1
      telephones.telephone_1
      email_addresses.email_address_2
    ])
    items[2].assert_no_selector "a", text: "Down"
  end

  it "renders the cancel button with the redirect path" do
    render_inline component

    assert_selector "a[href='#{redirect_path}?preview=true']", text: "Cancel"
  end

  def assert_button_exists(wrapper:, label:, order:)
    href = order_edit_edition_path(edition, order:, redirect_path:)
    wrapper.assert_selector "a[href='#{href}']", text: label
  end
end
