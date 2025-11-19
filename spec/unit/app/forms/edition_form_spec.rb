RSpec.describe EditionForm do
  include Rails.application.routes.url_helpers

  let(:schema) { build(:schema, :pension, body: { "properties" => { "foo" => "", "bar" => "" } }) }
  let(:result) do
    EditionForm.for(
      edition:,
      schema:,
    )
  end

  describe "EditionForm.for(edition:, schema:)" do
    describe "when initialized for an edition whose document already has a published edition" do
      before do
        allow(document).to receive(:has_published_edition?).and_return(true)
      end

      let(:document) { build(:document, :pension, id: 123) }
      let(:edition) { build(:edition, :pension, document: document) }

      let(:result) do
        EditionForm.for(
          edition:,
          schema:,
        )
      end

      it "initializes with the correct attributes from the schema" do
        expected_attributes = { "foo" => nil, "bar" => nil }
        aggregate_failures do
          expect(result.edition).to eq(edition)
          expect(result.schema).to eq(schema)
          expect(result.attributes).to eq(expected_attributes)
        end
      end

      it "sets the title to the 'Edit' variant" do
        expect(result.title).to eq("Edit pension")
      end

      it "sets the #url to the document_editions path" do
        expect(result.url).to eq(document_editions_path(document_id: edition.document.id))
      end

      it "sets the #back_path to the document_path" do
        expect(result.back_path).to eq(document_path(id: edition.document.id))
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

        aggregate_failures do
          expect(result.edition).to eq(edition)
          expect(result.schema).to eq(schema)
          expect(result.attributes).to eq(expected_attributes)
        end
      end

      it "sets the title to the 'Create' variant" do
        expect(result.title).to eq("Create pension")
      end

      it "sets the #url to the editions path" do
        expect(result.url).to eq(editions_path)
      end

      it "sets the #back_path to the new document path" do
        expect(result.back_path).to eq(new_document_path)
      end

      it "sets the form method to POST" do
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
  end

  describe "EditionForm::Edit" do
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

    it "sets the form method to PUT" do
      expect(result.form_method).to eq(:put)
    end

    context "when a further edition is being made" do
      before do
        allow(document).to receive(:is_new_block?).and_return(false)
      end

      it "sets the title to the 'Edit' variant when Document#is_new_block? is false" do
        expect(result.title).to eq("Edit pension")
      end

      it "sets the urls to the 'Edit' variant when Document#is_new_block? is false" do
        expect(result.back_path).to eq(document_path(edition.document))
        expect(result.url).to eq(workflow_path(edition, step: "edit_draft"))
      end

      it "returns a title in the 'Edit' style" do
        expect(result.title).to eq("Edit pension")
      end

      it "returns a back_path to the documents index" do
        expect(result.back_path).to eq(document_path(document))
      end
    end

    context "when the first edition is being made" do
      before do
        allow(document).to receive(:is_new_block?).and_return(true)
      end

      it "sets the title to the 'Create' variant when Document#is_new_block? is true" do
        expect(result.title).to eq("Create pension")
      end

      it "sets the urls to the 'Create' variant when Document#is_new_block? is true" do
        expect(result.back_path).to eq(new_document_path)
        expect(result.url).to eq(workflow_path(edition, step: "edit_draft"))
      end
    end

    context "when the errors include a sluggable_string error" do
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
end
