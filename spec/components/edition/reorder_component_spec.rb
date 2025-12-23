RSpec.describe Edition::ReorderComponent, type: :component do
  include Rails.application.routes.url_helpers
  include FormHelper

  let(:edition) { build_stubbed(:edition) }
  let(:order) do
    %w[
      email_addresses.email_address_1
      email_addresses.email_address_2
      telephones.telephone_1
    ]
  end
  let(:default_order) { order }
  let(:redirect_path) { "/foo/bar" }
  let(:component) { described_class.new(edition:, order:, redirect_path:) }

  before do
    allow(edition).to receive(:default_order).and_return(default_order)
    allow(edition).to receive(:clone_without_blocks).and_return(double(:edition, render: "WITHOUT BLOCKS"))
    allow(edition).to receive(:clone_with_block).with("email_addresses.email_address_1").and_return(double(:edition, render: "email_addresses.email_address_1"))
    allow(edition).to receive(:clone_with_block).with("email_addresses.email_address_2").and_return(double(:edition, render: "email_addresses.email_address_2"))
    allow(edition).to receive(:clone_with_block).with("telephones.telephone_1").and_return(double(:edition, render: "telephones.telephone_1"))
  end

  it "renders each part of the edition within their own constituent parts" do
    render_inline component

    wrapper = page.find(".app-c-content-block-manager-reorder-component")
    expect(page).to have_css ".govspeak:nth-child(1)", text: "WITHOUT BLOCKS"

    items = wrapper.all(".app-c-content-block-manager-reorder-component__item")

    expect(items.count).to eq(3)

    expect(page).to have_css ".govspeak", text: "email_addresses.email_address_1"
    expect(page).to have_css ".govspeak", text: "email_addresses.email_address_2"
    expect(page).to have_css ".govspeak", text: "telephones.telephone_1"
  end

  it "renders up and down buttons with the correct paths" do
    render_inline component

    wrapper = page.find(".app-c-content-block-manager-reorder-component")
    items = wrapper.all(".app-c-content-block-manager-reorder-component__item")

    expect(items.count).to eq(3)

    expect(items[0]).not_to have_css "a", text: "Up"
    expect_wrapper_to_have_button(wrapper: items[0], label: "Down", order: %w[
      email_addresses.email_address_2
      email_addresses.email_address_1
      telephones.telephone_1
    ])

    expect_wrapper_to_have_button(wrapper: items[1], label: "Up", order: %w[
      email_addresses.email_address_2
      email_addresses.email_address_1
      telephones.telephone_1
    ])
    expect_wrapper_to_have_button(wrapper: items[1], label: "Down", order: %w[
      email_addresses.email_address_1
      telephones.telephone_1
      email_addresses.email_address_2
    ])

    expect_wrapper_to_have_button(wrapper: items[2], label: "Up", order: %w[
      email_addresses.email_address_1
      telephones.telephone_1
      email_addresses.email_address_2
    ])
    expect(items[2]).not_to have_css "a", text: "Down"
  end

  it "renders the cancel button with the redirect path" do
    render_inline component

    expect(page).to have_css "a[href='#{redirect_path}?preview=true']", text: "Cancel"
  end

  describe "when the edition contains blocks that are missing from the order" do
    let(:default_order) do
      order + %w[
        email_addresses.email_address_3
        email_addresses.email_address_4
        telephones.telephone_2
      ]
    end

    before do
      allow(edition).to receive(:clone_with_block).with("email_addresses.email_address_3").and_return(double(:edition, render: "email_addresses.email_address_3"))
      allow(edition).to receive(:clone_with_block).with("email_addresses.email_address_4").and_return(double(:edition, render: "email_addresses.email_address_4"))
      allow(edition).to receive(:clone_with_block).with("telephones.telephone_2").and_return(double(:edition, render: "telephones.telephone_2"))
    end

    it "renders the missing blocks" do
      render_inline component

      wrapper = page.find(".app-c-content-block-manager-reorder-component")
      items = wrapper.all(".app-c-content-block-manager-reorder-component__item")

      expect(items.count).to eq(6)

      expect(page).to have_css ".govspeak", text: "email_addresses.email_address_1"
      expect(page).to have_css ".govspeak", text: "email_addresses.email_address_2"
      expect(page).to have_css ".govspeak", text: "telephones.telephone_1"
      expect(page).to have_css ".govspeak", text: "email_addresses.email_address_3"
      expect(page).to have_css ".govspeak", text: "email_addresses.email_address_4"
      expect(page).to have_css ".govspeak", text: "telephones.telephone_2"
    end

    it "renders up and down buttons with the correct paths" do
      render_inline component

      wrapper = page.find(".app-c-content-block-manager-reorder-component")
      items = wrapper.all(".app-c-content-block-manager-reorder-component__item")

      expect(items.count).to eq(6)

      expect(items[0]).not_to have_css "a", text: "Up"
      expect_wrapper_to_have_button(wrapper: items[0], label: "Down", order: %w[
        email_addresses.email_address_2
        email_addresses.email_address_1
        telephones.telephone_1
        email_addresses.email_address_3
        email_addresses.email_address_4
        telephones.telephone_2
      ])

      expect_wrapper_to_have_button(wrapper: items[1], label: "Up", order: %w[
        email_addresses.email_address_2
        email_addresses.email_address_1
        telephones.telephone_1
        email_addresses.email_address_3
        email_addresses.email_address_4
        telephones.telephone_2
      ])
      expect_wrapper_to_have_button(wrapper: items[1], label: "Down", order: %w[
        email_addresses.email_address_1
        telephones.telephone_1
        email_addresses.email_address_2
        email_addresses.email_address_3
        email_addresses.email_address_4
        telephones.telephone_2
      ])

      expect_wrapper_to_have_button(wrapper: items[2], label: "Up", order: %w[
        email_addresses.email_address_1
        telephones.telephone_1
        email_addresses.email_address_2
        email_addresses.email_address_3
        email_addresses.email_address_4
        telephones.telephone_2
      ])
      expect_wrapper_to_have_button(wrapper: items[2], label: "Down", order: %w[
        email_addresses.email_address_1
        email_addresses.email_address_2
        email_addresses.email_address_3
        telephones.telephone_1
        email_addresses.email_address_4
        telephones.telephone_2
      ])

      expect_wrapper_to_have_button(wrapper: items[3], label: "Up", order: %w[
        email_addresses.email_address_1
        email_addresses.email_address_2
        email_addresses.email_address_3
        telephones.telephone_1
        email_addresses.email_address_4
        telephones.telephone_2
      ])
      expect_wrapper_to_have_button(wrapper: items[3], label: "Down", order: %w[
        email_addresses.email_address_1
        email_addresses.email_address_2
        telephones.telephone_1
        email_addresses.email_address_4
        email_addresses.email_address_3
        telephones.telephone_2
      ])

      expect_wrapper_to_have_button(wrapper: items[4], label: "Up", order: %w[
        email_addresses.email_address_1
        email_addresses.email_address_2
        telephones.telephone_1
        email_addresses.email_address_4
        email_addresses.email_address_3
        telephones.telephone_2
      ])
      expect_wrapper_to_have_button(wrapper: items[4], label: "Down", order: %w[
        email_addresses.email_address_1
        email_addresses.email_address_2
        telephones.telephone_1
        email_addresses.email_address_3
        telephones.telephone_2
        email_addresses.email_address_4
      ])

      expect_wrapper_to_have_button(wrapper: items[5], label: "Up", order: %w[
        email_addresses.email_address_1
        email_addresses.email_address_2
        telephones.telephone_1
        email_addresses.email_address_3
        telephones.telephone_2
        email_addresses.email_address_4
      ])
      expect(items[5]).not_to have_css "a", text: "Down"
    end
  end

  it "renders the ga4 attributes" do
    render_inline component

    expect(page).to have_css "form[data-module='ga4-form-tracker']"

    form_attributes = ga4_data_attributes(edition:, section: "reorder")[:data][:ga4_form]
    expect(page).to have_css "form[data-ga4-form='#{form_attributes.to_json}']"
  end

  def expect_wrapper_to_have_button(wrapper:, label:, order:)
    href = order_edit_edition_path(edition, order:, redirect_path:)
    expect(wrapper).to have_css "a[href='#{href}']", text: label
  end
end
