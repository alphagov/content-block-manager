RSpec.describe HostContentItem::Items do
  let(:items) { build_list(:host_content_item, 5) }
  let(:total) { 12 }
  let(:total_pages) { 2 }
  let(:rollup) { build(:rollup) }
  let(:host_content_items) { build(:host_content_items, items:, total:, total_pages:, rollup:) }

  it "delegates array methods to items" do
    ([].methods - Object.methods).each do |method|
      expect(host_content_items.respond_to?(method)).to be(true)
    end

    host_content_items.each_with_index do |item, i|
      expect(items[i]).to eq(item)
    end
  end

  it "returns page count values" do
    expect(total).to eq(host_content_items.total)
    expect(total_pages).to eq(host_content_items.total_pages)
  end
end
