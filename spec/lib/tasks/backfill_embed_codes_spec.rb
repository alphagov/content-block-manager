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
end
