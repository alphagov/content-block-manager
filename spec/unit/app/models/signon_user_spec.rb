RSpec.describe SignonUser do
  describe ".with_uuids" do
    let(:signon_api_stub) { double }

    before do
      expect(Services).to receive(:signon_api_client).and_return(signon_api_stub)
    end

    it "returns an empty array when no UUIDs are provided" do
      expect(signon_api_stub).to receive(:get_users).with(uuids: []).and_return([])

      result = SignonUser.with_uuids([])

      expect(result).to eq([])
    end

    it "fetches users for a given list of UUIDs" do
      uuids = [SecureRandom.uuid, SecureRandom.uuid]
      api_response = [
        {
          "uid" => uuids[0],
          "name" => "Someone",
          "email" => "someone@example.com",
        },
        {
          "uid" => uuids[1],
          "name" => "Someone else",
          "email" => "someoneelse@example.com",
          "organisation" => {
            "content_id" => SecureRandom.uuid,
            "name" => "Organisation",
            "slug" => "organisation",
          },
        },
      ]
      expect(signon_api_stub).to receive(:get_users).with(uuids:).and_return(api_response)

      result = SignonUser.with_uuids(uuids)

      expect(api_response[0]["uid"]).to eq(result[0].uid)
      expect(api_response[0]["name"]).to eq(result[0].name)
      expect(api_response[0]["email"]).to eq(result[0].email)
      expect(result[0].organisation).to be_nil

      expect(api_response[1]["uid"]).to eq(result[1].uid)
      expect(api_response[1]["name"]).to eq(result[1].name)
      expect(api_response[1]["email"]).to eq(result[1].email)
      expect(api_response[1]["organisation"]["content_id"]).to eq(result[1].organisation.content_id)
      expect(api_response[1]["organisation"]["name"]).to eq(result[1].organisation.name)
      expect(api_response[1]["organisation"]["slug"]).to eq(result[1].organisation.slug)
    end
  end
end
