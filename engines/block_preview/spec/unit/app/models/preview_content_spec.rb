RSpec.describe BlockPreview::PreviewContent do
  let(:host_content_id) { SecureRandom.uuid }
  let(:preview_content_id) { SecureRandom.uuid }
  let(:host_title) { "Test" }
  let(:host_base_path) { "/test" }
  let(:locale) { "en" }
  let(:state) { "published" }
  let(:base_path) { nil }
  let(:html) { "SOME_HTML" }
  let(:instances_count) { 2 }

  let(:document) do
    build(:document, :pension, content_id: preview_content_id)
  end

  let(:edition) do
    build(:edition, :pension, document:, details: { "email_address" => "new@new.com" }, id: 1)
  end

  let(:block_to_preview) do
    build(:content_block, edition:)
  end

  let(:auth_bypass_id) { SecureRandom.uuid }

  let(:content_item_response) do
    instance_double(GdsApi::Response, parsed_content: { "title" => host_title, "base_path" => host_base_path, "auth_bypass_ids" => [auth_bypass_id] })
  end

  let(:metadata_response) do
    instance_double(GdsApi::Response, parsed_content: { "instances" => instances_count })
  end

  let(:preview_html_response) { instance_double(BlockPreview::PreviewHtml, to_s: html) }

  subject(:preview_content) do
    described_class.new(
      content_id: host_content_id,
      block: block_to_preview,
      base_path:,
      locale:,
      state:,
    )
  end

  before do
    allow(Public::Services.publishing_api).to receive(:get_content)
      .and_return(content_item_response)

    allow(Public::Services.publishing_api).to receive(:get_host_content_item_for_content_id)
      .and_return(metadata_response)
  end

  describe "#state" do
    it "is publicly readable" do
      expect(preview_content.state).to eq("published")
    end

    context "when the state is draft" do
      let(:state) { "draft" }

      it "returns the normalized state" do
        expect(preview_content.state).to eq("draft")
      end
    end

    context "when the state is invalid" do
      let(:state) { "archived" }

      it "raises an ArgumentError" do
        expect { preview_content }.to raise_error(ArgumentError, "state must be one of: published, draft")
      end
    end

    context "when the state is nil" do
      let(:state) { nil }

      it "raises an ArgumentError" do
        expect { preview_content }.to raise_error(ArgumentError, "state must be one of: published, draft")
      end
    end
  end

  describe "#title" do
    it "returns the title from the host content item" do
      expect(preview_content.title).to eq(host_title)
    end

    it "memoizes the fetched content item" do
      2.times { preview_content.title }

      expect(Public::Services.publishing_api).to have_received(:get_content).once
    end

    it "makes a request for content from the live content store" do
      preview_content.title

      expect(Public::Services.publishing_api).to have_received(:get_content).with(host_content_id, { locale:, content_store: "live" })
    end

    context "when locale and state are provided" do
      let(:locale) { "cy" }
      let(:state) { "draft" }

      it "makes a request for content from the draft content store" do
        preview_content.title
        expect(Public::Services.publishing_api).to have_received(:get_content).with(host_content_id, { locale:, content_store: "draft" })
      end
    end
  end

  describe "#instances_count" do
    it "returns the number of host content item instances" do
      expect(preview_content.instances_count).to eq(instances_count)
    end

    it "memoizes the fetched metadata" do
      2.times { preview_content.instances_count }

      expect(Public::Services.publishing_api).to have_received(:get_host_content_item_for_content_id).once
    end

    it "makes a request for published content" do
      preview_content.instances_count

      expect(Public::Services.publishing_api).to have_received(:get_host_content_item_for_content_id).with(block_to_preview.content_id, host_content_id, { locale: "en", state: "published" })
    end

    context "when `locale` is `cy` and `state` is `draft`" do
      let(:locale) { "cy" }
      let(:state) { "draft" }

      it "makes a request for `draft` content in the `cy` locale" do
        preview_content.instances_count

        expect(Public::Services.publishing_api).to have_received(:get_host_content_item_for_content_id).with(block_to_preview.content_id, host_content_id, { locale: "cy", state: "draft" })
      end
    end
  end

  describe "#html" do
    before do
      allow(BlockPreview::PreviewHtml).to receive(:new).and_return(preview_html_response)
    end

    context "when the locale is empty" do
      let(:locale) { "" }

      it "defaults the locale to 'en'" do
        preview_content.html
        expect(BlockPreview::PreviewHtml).to have_received(:new).with(hash_including(locale: "en"))
      end
    end

    it "builds preview html using the host content base path by default" do
      expect(preview_content.html).to eq(html)

      expect(BlockPreview::PreviewHtml).to have_received(:new).with(
        content_id: host_content_id,
        block: block_to_preview,
        base_path: host_base_path,
        locale: "en",
        state: "published",
        auth_bypass_id:,
      )
    end

    context "when a base path is provided" do
      let(:base_path) { "/something/different" }

      it "prefers the provided base path" do
        preview_content.html

        expect(BlockPreview::PreviewHtml).to have_received(:new).with(
          content_id: host_content_id,
          block: block_to_preview,
          base_path: base_path,
          locale: "en",
          state: "published",
          auth_bypass_id:,
        )
      end
    end

    context "when a locale and state are provided" do
      let(:locale) { "cy" }
      let(:state) { "draft" }

      it "forwards them to the preview renderer" do
        preview_content.html

        expect(BlockPreview::PreviewHtml).to have_received(:new).with(
          content_id: host_content_id,
          block: block_to_preview,
          base_path: host_base_path,
          locale: "cy",
          state: "draft",
          auth_bypass_id:,
        )
      end
    end

    it "memoizes the rendered html" do
      2.times { preview_content.html }

      expect(BlockPreview::PreviewHtml).to have_received(:new).once
      expect(Public::Services.publishing_api).to have_received(:get_content).once
    end
  end
end
