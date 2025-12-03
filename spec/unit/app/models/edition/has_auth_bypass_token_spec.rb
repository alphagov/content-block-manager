RSpec.describe Edition::HasAuthBypassToken do
  it "adds auth bypass id to a newly created edition" do
    auth_bypass_id = SecureRandom.uuid
    allow(SecureRandom).to receive(:uuid).and_return(auth_bypass_id)

    edition = create(:edition, document: create(:document, block_type: "pension"))
    expect(edition.auth_bypass_id).to eq(auth_bypass_id)
  end

  describe "#auth_bypass_token" do
    let(:secret) { "secret" }

    around do |example|
      ClimateControl.modify JWT_AUTH_SECRET: secret do
        example.run
      end
    end

    it "returns a token for an edition" do
      document = build(:document)
      edition = build(:edition, auth_bypass_id: SecureRandom.uuid, document:)

      expect(JWT).to receive(:encode).with(
        {
          "sub" => edition.auth_bypass_id,
          "content_id" => edition.content_id,
          "iat" => Time.zone.now.to_i,
          "exp" => 1.month.from_now.to_i,
        },
        secret,
        "HS256",
      ).and_return("token")

      expect(edition.auth_bypass_token).to eq("token")
    end
  end
end
