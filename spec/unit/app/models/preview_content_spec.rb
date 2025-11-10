RSpec.describe PreviewContent do
  let(:title) { "Ministry of Example" }
  let(:html) { "<p>Ministry of Example</p>" }
  let(:instances_count) { "2" }
  let(:preview_content) { build(:preview_content, title:, instances_count:, html:) }

  it "returns title, html and instances count" do
    expect(title).to eq(preview_content.title)
    expect(html).to eq(preview_content.html)
    expect(instances_count).to eq(preview_content.instances_count)
  end

  describe ".for_content_id" do
    let(:host_content_id) { SecureRandom.uuid }
    let(:preview_content_id) { SecureRandom.uuid }
    let(:host_title) { "Test" }
    let(:host_base_path) { "/test" }
    let(:document) do
      build(:document, :pension, content_id: preview_content_id)
    end
    let(:block_to_preview) do
      build(:edition, :pension, document:, details: { "email_address" => "new@new.com" }, id: 1)
    end
    let(:metadata_response) do
      double(:response, parsed_content: { "instances" => 2 })
    end
    let(:preview_response) { double(:preview_response, call: html) }
    let(:html) { "SOME_HTML" }

    describe "when a locale is not provided" do
      before do
        stub_publishing_api_has_item(content_id: host_content_id, title: host_title, base_path: host_base_path)
        allow(Services.publishing_api).to receive(:get_host_content_item_for_content_id)
                .with(block_to_preview.document.content_id, host_content_id, { locale: "en" })
                .and_return(metadata_response)
      end

      it "returns the title of host document" do
        expect(GeneratePreviewHtml).to receive(:new)
                                                .with(content_id: host_content_id,
                                                      edition: block_to_preview,
                                                      base_path: host_base_path,
                                                      locale: "en")
                                                .and_return(preview_response)

        preview_content = PreviewContent.for_content_id(
          content_id: host_content_id,
          edition: block_to_preview,
        )

        expect(preview_content.title).to eq(host_title)
        expect(preview_content.instances_count).to eq(2)
        expect(preview_content.html).to eq(html)
      end

      it "allows a base_path to be provided" do
        base_path = "/something/different"

        expect(GeneratePreviewHtml).to receive(:new)
                                                .with(content_id: host_content_id,
                                                      edition: block_to_preview,
                                                      base_path:,
                                                      locale: "en")
                                                .and_return(preview_response)

        PreviewContent.for_content_id(
          content_id: host_content_id,
          edition: block_to_preview,
          base_path:,
        )
      end
    end

    describe "when a locale is provided" do
      before do
        stub_publishing_api_has_item(content_id: host_content_id, title: host_title, base_path: host_base_path, locale: "cy")
        allow(Services.publishing_api).to receive(:get_host_content_item_for_content_id)
                .with(block_to_preview.document.content_id, host_content_id, { locale: "cy" })
                .and_return(metadata_response)
      end

      it "returns the title of host document" do
        expect(GeneratePreviewHtml).to receive(:new)
                                                .with(content_id: host_content_id,
                                                      edition: block_to_preview,
                                                      base_path: host_base_path,
                                                      locale: "cy")
                                                .and_return(preview_response)

        preview_content = PreviewContent.for_content_id(
          content_id: host_content_id,
          edition: block_to_preview,
          base_path: nil,
          locale: "cy",
        )

        expect(preview_content.title).to eq(host_title)
        expect(preview_content.instances_count).to eq(2)
        expect(preview_content.html).to eq(html)
      end
    end
  end
end
