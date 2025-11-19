RSpec.describe EditionForm do
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

      expect(result.edition).to eq(edition)
      expect(result.schema).to eq(schema)
      expect(result.attributes).to eq(expected_attributes)
    end

    it "sets the correct title" do
      expect(result.title).to eq(I18n.t("edition.update.title", block_type: "pension"))
    end

    it "sets the correct urls" do
      expect(result.back_path).to eq(document_path({ id: edition.document.id }))
      expect(result.url).to eq(document_editions_path({ document_id: edition.document.id }))
    end

    it "sets the correct form method" do
      expect(result.form_method).to eq(:post)
    end

    describe "when the errors include a sluggable_string error" do
      before do
        document.sluggable_string = nil
        edition.title = nil
        edition.valid?
      end

      it "removes the error from the object" do
        expect(result.edition.errors.count).to eq(1)
        expect(result.edition.errors.map(&:attribute)).not_to include("document.sluggable_string".to_sym)
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

      expect(result.edition).to eq(edition)
      expect(result.schema).to eq(schema)
      expect(result.attributes).to eq(expected_attributes)
    end

    it "sets the correct title" do
      expect(result.title).to eq(I18n.t("edition.create.title", block_type: "pension"))
    end

    it "sets the correct urls" do
      expect(result.back_path).to eq(new_document_path)
      expect(result.url).to eq(editions_path)
    end

    it "sets the correct form method" do
      expect(result.form_method).to eq(:post)
    end

    describe "when the errors include a sluggable_string error" do
      before do
        edition.title = nil
        edition.document = build(:document, :pension, sluggable_string: nil)
        edition.valid?
      end

      it "removes the error from the object" do
        expect(result.edition.errors.count).to eq(1)
        expect(result.edition.errors.map(&:attribute)).not_to include("document.sluggable_string".to_sym)
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

      expect(result.edition).to eq(edition)
      expect(result.schema).to eq(schema)
      expect(result.attributes).to eq(expected_attributes)
    end

    it "sets the correct title" do
      expect(result.title).to eq(I18n.t("edition.update.title", block_type: "pension"))
    end

    it "sets the correct urls" do
      expect(result.back_path).to eq(document_path(edition.document))
      expect(result.url).to eq(workflow_path(edition, { step: "edit_draft" }))
    end

    it "sets the correct form method" do
      expect(result.form_method).to eq(:put)
    end

    describe "when the errors include a sluggable_string error" do
      before do
        edition.title = nil
        edition.document = build(:document, :pension, sluggable_string: nil)
        edition.valid?
      end

      it "removes the error from the object" do
        expect(result.edition.errors.count).to eq(1)
        expect(result.edition.errors.map(&:attribute)).not_to include("document.sluggable_string".to_sym)
      end
    end

    describe "when editing a new block" do
      before do
        allow(document).to receive(:is_new_block?).and_return(true)
      end

      describe "#title" do
        it "returns a title for the create action" do
          expect(result.title).to eq(I18n.t("edition.create.title", block_type: "pension"))
        end
      end

      describe "#back_path" do
        it "returns the documents index path" do
          expect(result.back_path).to eq(new_document_path)
        end
      end
    end
  end
end
