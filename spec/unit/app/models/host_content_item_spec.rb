RSpec.describe HostContentItem do
  describe ".for_document" do
    let(:described_class) { HostContentItem }

    let(:target_content_id) { SecureRandom.uuid }

    let(:host_content_id) { SecureRandom.uuid }

    let(:last_edited_by_editor_id) { SecureRandom.uuid }

    let(:rollup) { build(:rollup) }

    let(:response_body) do
      {
        "content_id" => SecureRandom.uuid,
        "total" => 111,
        "total_pages" => 12,
        "rollup" => rollup.to_h,
        "results" => [
          {
            "title" => "foo",
            "base_path" => "/foo",
            "document_type" => "something",
            "publishing_app" => "publisher",
            "last_edited_by_editor_id" => last_edited_by_editor_id,
            "last_edited_at" => "2023-01-01T08:00:00.000Z",
            "unique_pageviews" => 123,
            "instances" => 1,
            "host_content_id" => host_content_id,
            "host_locale" => "en",
            "primary_publishing_organisation" => {
              "content_id" => SecureRandom.uuid,
              "title" => "bar",
              "base_path" => "/bar",
            },
          },
        ],
      }
    end

    let(:editor) { build(:signon_user, uid: last_edited_by_editor_id) }

    let(:fake_api_response) do
      GdsApi::Response.new(
        double("http_response", code: 200, body: response_body.to_json),
      )
    end
    let(:publishing_api_mock) { double("GdsApi::PublishingApi") }
    let(:document) { double("document", content_id: target_content_id) }

    before do
      expect(Public::Services).to receive(:publishing_api).and_return(publishing_api_mock)
      allow(SignonUser).to receive(:with_uuids).and_return([editor])
    end

    it "calls the Publishing API for the content which embeds the target" do
      expect(publishing_api_mock).to receive(:get_host_content_for_content_id)
                         .with(target_content_id, { order: described_class::DEFAULT_ORDER })
                         .and_return(fake_api_response)

      described_class.for_document(document)
    end

    it "supports pagination" do
      expect(publishing_api_mock).to receive(:get_host_content_for_content_id)
                         .with(target_content_id, { page: 1, order: described_class::DEFAULT_ORDER })
                         .and_return(fake_api_response)

      described_class.for_document(document, page: 1)
    end

    it "supports sorting" do
      expect(publishing_api_mock).to receive(:get_host_content_for_content_id)
                         .with(target_content_id, { order: "-abc" })
                         .and_return(fake_api_response)

      described_class.for_document(document, order: "-abc")
    end

    it "calls the editor finder with the correct argument" do
      expect(publishing_api_mock).to receive(:get_host_content_for_content_id).and_return(fake_api_response)
      expect(SignonUser).to receive(:with_uuids).with([last_edited_by_editor_id]).and_return([editor])

      described_class.for_document(document)
    end

    it "returns items" do
      expect(publishing_api_mock).to receive(:get_host_content_for_content_id).and_return(fake_api_response)

      result = described_class.for_document(document)

      expected_publishing_organisation = {
        "content_id" => response_body["results"][0]["primary_publishing_organisation"]["content_id"],
        "title" => response_body["results"][0]["primary_publishing_organisation"]["title"],
        "base_path" => response_body["results"][0]["primary_publishing_organisation"]["base_path"],
      }

      expect(response_body["total"]).to eq(result.total)
      expect(response_body["total_pages"]).to eq(result.total_pages)

      expect(rollup.views).to eq(result.rollup.views)
      expect(rollup.locations).to eq(result.rollup.locations)
      expect(rollup.instances).to eq(result.rollup.instances)
      expect(rollup.organisations).to eq(result.rollup.organisations)

      expect(response_body["results"][0]["title"]).to eq(result[0].title)
      expect(response_body["results"][0]["base_path"]).to eq(result[0].base_path)
      expect(response_body["results"][0]["document_type"]).to eq(result[0].document_type)
      expect(response_body["results"][0]["publishing_app"]).to eq(result[0].publishing_app)
      expect(editor).to eq(result[0].last_edited_by_editor)
      expect(Time.zone.parse(response_body["results"][0]["last_edited_at"])).to eq(result[0].last_edited_at)
      expect(response_body["results"][0]["unique_pageviews"]).to eq(result[0].unique_pageviews)
      expect(response_body["results"][0]["instances"]).to eq(result[0].instances)
      expect(response_body["results"][0]["host_content_id"]).to eq(result[0].host_content_id)
      expect(response_body["results"][0]["host_locale"]).to eq(result[0].host_locale)

      expect(expected_publishing_organisation).to eq(result.[](0).publishing_organisation)
    end

    describe "when last_edited_by_editor_id is nil" do
      let(:last_edited_by_editor_id) { nil }

      it "returns nil for last_edited_by_editor" do
        expect(publishing_api_mock).to receive(:get_host_content_for_content_id).and_return(fake_api_response)

        expect(SignonUser).to receive(:with_uuids).never

        result = described_class.for_document(document)

        expect(result[0].last_edited_by_editor).to be_nil
      end
    end

    it "returns an error if the content that embeds the target can't be loaded" do
      allow(publishing_api_mock).to receive(:get_host_content_for_content_id).and_raise(
        GdsApi::HTTPErrorResponse.new(
          500,
          "An internal error message",
          "error" => { "message" => "Some backend error" },
        ),
      )

      expect { described_class.for_document(document) }.to raise_error(GdsApi::HTTPErrorResponse)
    end
  end

  describe "#last_edited_at" do
    it "translates to a TimeWithZone object" do
      last_edited_at = 4.days.ago
      host_content_item = build(:host_content_item, last_edited_at: last_edited_at.to_s)

      expect(host_content_item.last_edited_at).to be_an_instance_of(ActiveSupport::TimeWithZone)
      expect(last_edited_at).to eq(host_content_item.last_edited_at)
    end
  end
end
