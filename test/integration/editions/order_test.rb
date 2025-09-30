require "test_helper"
require "capybara/rails"

class Editions::OrderTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers
  include IntegrationTestHelpers

  let(:user) { create(:user) }
  let(:details) do
    {
      "telephones" => {
        "telephone_1" => {
          "something" => "here",
        },
      },
      "addresses" => {
        "address_1" => {
          "something" => "here",
        },
      },
      "email_addresses" => {
        "email_address_1" => {
          "something" => "here",
        },
        "email_address_2" => {
          "something" => "here",
        },
      },
      "contact_links" => {
        "contact_link_1" => {
          "something" => "here",
        },
      },
    }
  end

  let(:document) { create(:document) }
  let(:edition) { create(:edition, document:, details:) }
  let(:subschemas) do
    [
      stub(:subschema, id: "email_addresses", block_type: "email_addresses", group_order: 1),
      stub(:subschema, id: "telephones", block_type: "telephones", group_order: 2),
      stub(:subschema, id: "addresses", block_type: "addresses", group_order: 3),
      stub(:subschema, id: "contact_links", block_type: "contact_links", group_order: 4),
    ]
  end
  let(:schema) { stub(:schema, subschemas: subschemas, body: {}) }

  before do
    login_as(user)
    document.stubs(:schema).returns(schema)
    Schema.stubs(:find_by_block_type).returns(schema)
  end

  describe "#edit" do
    it "returns a default order if the edition does not have a custom order set" do
      get order_edit_edition_path(edition)

      assert_equal assigns(:order), %w[
        email_addresses.email_address_1
        email_addresses.email_address_2
        telephones.telephone_1
        addresses.address_1
        contact_links.contact_link_1
      ]
    end

    it "returns an order if the edition has a custom order set" do
      edition.details["order"] = %w[
        telephones.telephone_1
        email_addresses.email_address_1
        contact_links.contact_link_1
        email_addresses.email_address_2
        addresses.address_1
      ]
      edition.save!

      get order_edit_edition_path(edition)

      assert_equal assigns(:order), edition.details["order"]
    end

    it "returns an order if a custom order is set in the params" do
      order = %w[
        email_addresses.email_address_1
        telephones.telephone_1
        contact_links.contact_link_1
        email_addresses.email_address_2
        addresses.address_1
      ]

      get order_edit_edition_path(edition, order:)
      assert_equal assigns(:order), order
    end

    it "sets the redirect_path from the referrer" do
      referrer = "http://example.com/referrers/here"

      get order_edit_edition_path(edition), headers: { "HTTP_REFERER" => referrer }
      assert_equal assigns(:redirect_path), referrer
    end

    it "sets the redirect_path from the params if present" do
      referrer = "http://example.com/referrers/here"

      get order_edit_edition_path(edition, redirect_path: referrer), headers: { "HTTP_REFERER" => "http://example.com/referrers/something/else" }
      assert_equal assigns(:redirect_path), referrer
    end
  end

  describe "#update" do
    it "updates the order" do
      order = %w[
        telephones.telephone_1
        email_addresses.email_address_1
        contact_links.contact_link_1
        email_addresses.email_address_2
        addresses.address_1
      ]

      put order_update_edition_path(edition), params: { order: }

      edition.reload

      assert_equal edition.details["order"], order
    end
  end
end
