RSpec.describe Edition::HasAuthBypassToken do
  it "adds auth bypass id to a newly created edition" do
    auth_bypass_id = SecureRandom.uuid
    allow(SecureRandom).to receive(:uuid).and_return(auth_bypass_id)

    edition = create(:edition, document: create(:document, block_type: "pension"))
    expect(edition.auth_bypass_id).to eq(auth_bypass_id)
  end
end
