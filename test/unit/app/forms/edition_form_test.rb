require "test_helper"

class EditionFormTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  include Rails.application.routes.url_helpers

  let(:schema) { build(:schema, :pension, body: { "properties" => { "foo" => "", "bar" => "" } }) }
  let(:result) do
    EditionForm.for(
      edition:,
      schema:,
    )
  end

  describe "when initialized for an edition with an existing document and live edition" do
    let(:document) { build(:document, :pension, id: 123, latest_edition_id: "5b271577-3d3d-475d-986a-246d8c4063a3") }
    let(:edition) { build(:edition, :pension, document: document) }

    let(:result) do
      EditionForm.for(
        edition:,
        schema:,
      )
    end

    it "initializes with the correct attributes from the schema" do
      expected_attributes = { "foo" => nil, "bar" => nil }

      assert_equal edition, result.edition
      assert_equal schema, result.schema
      assert_equal expected_attributes, result.attributes
    end

    it "sets the correct title" do
      assert_equal I18n.t("edition.update.title", block_type: "pension"), result.title
    end

    it "sets the correct urls" do
      assert_equal document_path(id: edition.document.id), result.back_path
      assert_equal document_editions_path(document_id: edition.document.id), result.url
    end

    it "sets the correct form method" do
      assert_equal :post, result.form_method
    end

    describe "when the errors include a sluggable_string error" do
      before do
        document.sluggable_string = nil
        edition.title = nil
        edition.valid?
      end

      it "removes the error from the object" do
        assert_equal 1, result.edition.errors.count
        assert_not_includes result.edition.errors.map(&:attribute), "document.sluggable_string".to_sym
      end
    end
  end

  describe "when initialized for an edition without an existing document" do
    let(:edition) { build(:edition, :pension, document: nil) }

    let(:result) do
      EditionForm.for(
        edition:,
        schema:,
      )
    end

    it "initializes with the correct attributes from the schema" do
      expected_attributes = { "foo" => nil, "bar" => nil }

      assert_equal edition, result.edition
      assert_equal schema, result.schema
      assert_equal expected_attributes, result.attributes
    end

    it "sets the correct title" do
      assert_equal I18n.t("edition.create.title", block_type: "pension"), result.title
    end

    it "sets the correct urls" do
      assert_equal new_document_path, result.back_path
      assert_equal editions_path, result.url
    end

    it "sets the correct form method" do
      assert_equal :post, result.form_method
    end

    describe "when the errors include a sluggable_string error" do
      before do
        edition.title = nil
        edition.document = build(:document, :pension, sluggable_string: nil)
        edition.valid?
      end

      it "removes the error from the object" do
        assert_equal 1, result.edition.errors.count
        assert_not_includes result.edition.errors.map(&:attribute), "document.sluggable_string".to_sym
      end
    end
  end

  describe "edit form" do
    let(:document) { build_stubbed(:document, :pension) }
    let(:edition) { build_stubbed(:edition, :pension, document: document) }

    let(:result) do
      EditionForm::Edit.new(
        edition:,
        schema:,
      )
    end

    it "initializes with the correct attributes from the schema" do
      expected_attributes = { "foo" => nil, "bar" => nil }

      assert_equal edition, result.edition
      assert_equal schema, result.schema
      assert_equal expected_attributes, result.attributes
    end

    it "sets the correct title" do
      assert_equal I18n.t("edition.update.title", block_type: "pension"), result.title
    end

    it "sets the correct urls" do
      assert_equal document_path(edition.document), result.back_path
      assert_equal workflow_path(edition, step: "edit_draft"), result.url
    end

    it "sets the correct form method" do
      assert_equal :put, result.form_method
    end

    describe "when the errors include a sluggable_string error" do
      before do
        edition.title = nil
        edition.document = build(:document, :pension, sluggable_string: nil)
        edition.valid?
      end

      it "removes the error from the object" do
        assert_equal 1, result.edition.errors.count
        assert_not_includes result.edition.errors.map(&:attribute), "document.sluggable_string".to_sym
      end
    end
  end
end
