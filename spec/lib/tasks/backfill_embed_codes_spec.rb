RSpec.describe "backfill_embed_codes", type: task do
  require "rake"

  let(:task) { Rake::Task["backfill_embed_codes"] }

  let(:doc_1) do
    instance_double(
      Document,
      built_embed_code: "{{embed:content_block_contact:block-1}}",
      update_column: true,
    )
  end

  let(:doc_2) do
    instance_double(
      Document,
      built_embed_code: "{{embed:content_block_contact:block-2}}",
      update_column: true,
    )
  end

  let(:documents_in_batches) do
    double("AR batches").tap do |d|
      allow(d).to receive(:find_each).and_yield(doc_1).and_yield(doc_2)
    end
  end

  before do
    allow(Document).to receive(:where).and_return(documents_in_batches)
  end

  after { task.reenable }

  it "sets each document's #embed_code with its #built_embed_code, bypassing callbacks etc" do
    task.execute

    expect(doc_1).to have_received(:update_column).with(
      :embed_code, "{{embed:content_block_contact:block-1}}"
    )
    expect(doc_2).to have_received(:update_column).with(
      :embed_code, "{{embed:content_block_contact:block-2}}"
    )
  end

  context "when an error is encountered" do
    let(:error) do
      ActiveRecord::RecordNotUnique.new("duplicate key value violates unique constraint")
    end

    let(:document) do
      instance_double(
        Document,
        id: 123,
        content_id_alias: "my-block",
        built_embed_code: "{{embed:content_block_contact:my-block}}",
      )
    end

    let(:documents_in_batches) do
      double("AR batches").tap do |d|
        allow(d).to receive(:find_each).and_yield(document)
      end
    end

    before do
      allow(document).to receive(:update_column).and_raise(error)
      allow(GovukError).to receive(:notify)
    end

    it "logs the error and some useful details using GovukError" do
      task.execute

      expect(GovukError).to have_received(:notify).with(
        error,
        level: :error,
        extras: {
          document_id: 123,
          content_id_alias: "my-block",
          built_embed_code: "{{embed:content_block_contact:my-block}}",
        },
      )
    end
  end
end
