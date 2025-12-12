RSpec.describe Editions::OrderController, type: :request do
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
      double(:subschema, id: "email_addresses", block_type: "email_addresses", group_order: 1),
      double(:subschema, id: "telephones", block_type: "telephones", group_order: 2),
      double(:subschema, id: "addresses", block_type: "addresses", group_order: 3),
      double(:subschema, id: "contact_links", block_type: "contact_links", group_order: 4),
    ]
  end
  let(:schema) { double(:schema, subschemas: subschemas, body: {}) }

  before do
    login_as(user)
    allow(document).to receive(:schema).and_return(schema)
    allow(Schema).to receive(:find_by_block_type).and_return(schema)
  end

  describe "#edit" do
    it "returns the default order if the edition does not have a custom order set" do
      get order_edit_edition_path(edition)

      expect(assigns(:order)).to eq(edition.default_order)
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

      expect(assigns(:order)).to eq(edition.details["order"])
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
      expect(assigns(:order)).to eq(order)
    end

    it "sets the redirect_path from the referrer" do
      referrer = "http://example.com/referrers/here"

      get order_edit_edition_path(edition), headers: { "HTTP_REFERER" => referrer }
      expect(assigns(:redirect_path)).to eq(referrer)
    end

    it "sets the redirect_path from the params if present" do
      referrer = "http://example.com/referrers/here"

      get order_edit_edition_path(edition, redirect_path: referrer), headers: { "HTTP_REFERER" => "http://example.com/referrers/something/else" }
      expect(assigns(:redirect_path)).to eq(referrer)
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

      put order_update_edition_path(edition), params: { order:, redirect_path: root_path }

      edition.reload

      expect(order).to eq(edition.details["order"])

      expect(response).to redirect_to("#{root_path}?preview=true")
    end
  end
end
