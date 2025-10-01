require "test_helper"
require "capybara/rails"

class DocumentsTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers
  include IntegrationTestHelpers

  let(:organisation) { build(:organisation) }

  setup do
    logout
    user = create(:user)
    login_as(user)

    Organisation.stubs(:all).returns([organisation])
  end

  describe "#index" do
    let(:document) { create(:document, :contact) }

    before do
      stub_request_for_schema(document.block_type, fields: [stub(:field, name: "email_address")])
    end

    it "only returns the latest edition when multiple editions exist for a document" do
      first_edition = create(
        :edition,
        :contact,
        details: { "email_address" => "first_edition@example.com" },
        document: document,
        lead_organisation_id: organisation.id,
      )
      second_edition = create(
        :edition,
        :contact,
        details: { "email_address" => "second_edition@example.com" },
        document: document,
        lead_organisation_id: organisation.id,
      )

      visit documents_path

      assert_no_text first_edition.details["email_address"]
      assert_text second_edition.details["email_address"]
    end

    it "only returns documents with a latest edition" do
      document.latest_edition = create(
        :edition,
        :contact,
        details: { "email_address" => "live_edition@example.com" },
        document: document,
        lead_organisation_id: organisation.id,
      )
      _document_without_latest_edition = create(:document, :contact, sluggable_string: "no latest edition")

      visit documents_path({ lead_organisation: "" })

      assert_text document.latest_edition.details["email_address"]
      assert_text "1 result"
    end

    describe "when no filter params are specified" do
      it "sets the filter to 'all organisations' by default" do
        visit documents_path

        assert_current_path root_path({ lead_organisation: "" })
      end
    end

    describe "when there are filter params provided" do
      it "does not change the params" do
        visit documents_path({ lead_organisation: organisation.id })

        assert_current_path documents_path({ lead_organisation: organisation.id })
      end
    end
  end

  describe "#new" do
    let(:schemas) { build_list(:schema, 1, body: { "properties" => {} }) }

    it "lists all schemas" do
      Schema.expects(:all).returns(schemas)

      visit new_document_path

      assert_text "Select a content block"
    end
  end

  describe "#new_document_options_redirect" do
    let(:schemas) { build_list(:schema, 1, body: { "properties" => {} }) }

    before do
      Schema.stubs(:all).returns(schemas)
    end

    it "shows an error message when block type is empty" do
      post new_document_options_redirect_documents_path
      follow_redirect!

      assert_equal new_document_path, path
      assert_equal I18n.t("activerecord.errors.models/document.attributes.block_type.blank"), flash[:error]
    end

    it "redirects when the block type is specified" do
      block_type = schemas[0].block_type
      Schema.stubs(:find_by_block_type).returns(schemas[0])

      post new_document_options_redirect_documents_path, params: { block_type: }
      follow_redirect!

      assert_equal new_edition_path(block_type:), path
    end
  end

  describe "#show" do
    let(:edition) { create(:edition, :contact, lead_organisation_id: organisation.id) }
    let(:document) { edition.document }

    before do
      stub_request_for_schema(document.block_type)
    end

    it "returns information about the document" do
      stub_publishing_api_has_embedded_content_for_any_content_id(
        results: [],
        total: 0,
        order: HostContentItem::DEFAULT_ORDER,
      )

      visit document_path(document)

      assert_text document.title
    end

    it_returns_embedded_content do
      visit document_path(document)
    end
  end

  describe "#content_id" do
    it "returns 404 if the document doesn't exist" do
      visit content_id_path("123")
      assert_text "Could not find Content Block with Content ID 123"
    end
  end
end
