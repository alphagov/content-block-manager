RSpec.describe CombinedEditionDetails do
  describe "#content" do
    let(:content) { described_class.new(published_details:, new_details:).content }

    context "when provided with simple flat details" do
      let(:published_details) { { "title" => "Old Title" } }
      let(:new_details) { { "title" => "New Title" } }

      it "should combine the hashes with a 'published' and 'new' key at the leaf nodes" do
        expect(content).to eq({ "title" =>
                                { "published" => "Old Title",
                                  "new" => "New Title" } })
      end

      context "when a key is only present in the published details" do
        let(:new_details) { {} }

        it "should include only the 'published' key for that field" do
          expect(content).to eq({ "title" =>
                                  { "published" => "Old Title" } })
        end
      end

      context "when a key is only present in the new details" do
        let(:published_details) { {} }

        it "should include only the 'published' key for that field" do
          expect(content).to eq({ "title" =>
                                  { "new" => "New Title" } })
        end
      end

      context "when published details is nil" do
        let(:published_details) { nil }

        it "should include only the 'published' key for that field" do
          expect(content).to eq({ "title" =>
                                    { "new" => "New Title" } })
        end
      end
    end

    context "when provided with nested details" do
      let(:published_details) do
        { "contact_links" =>
          { "contact-link" =>
              { "title" => "My Nice Contact link",
                "label" => "My Nice label",
                "url" => "https://nice.example.com" } } }
      end

      let(:new_details) do
        { "contact_links" =>
          { "contact-link" =>
              { "title" => "My Bad Contact link",
                "label" => "My Bad Label",
                "url" => "https://bad.example.com" } } }
      end

      it "should combine the hashes with a 'published' and 'new' key at the leaf nodes" do
        expect(content).to eq({ "contact_links" =>
                                { "contact-link" =>
                                  { "title" =>
                                    { "published" => "My Nice Contact link",
                                      "new" => "My Bad Contact link" },
                                    "label" =>
                                    { "published" => "My Nice label",
                                      "new" => "My Bad Label" },
                                    "url" =>
                                    { "published" => "https://nice.example.com",
                                      "new" => "https://bad.example.com" } } } })
      end

      context "when a key is only present in the published details" do
        let(:new_details) do
          { "contact_links" =>
            { "contact-link" =>
              { "title" => "My Bad Contact link",
                "url" => "https://bad.example.com" } } } # no label key
        end

        it "should include only the 'published' key for that field" do
          expect(content).to eq({ "contact_links" =>
                                  { "contact-link" =>
                                    { "title" =>
                                      { "published" => "My Nice Contact link",
                                        "new" => "My Bad Contact link" },
                                      "label" =>
                                      { "published" => "My Nice label" },
                                      "url" =>
                                      { "published" => "https://nice.example.com",
                                        "new" => "https://bad.example.com" } } } })
        end
      end

      context "when a key is only present in the new details" do
        let(:published_details) do
          { "contact_links" =>
            { "contact-link" =>
              { "label" => "My Nice label",
                "url" => "https://nice.example.com" } } } # no title key
        end

        it "should include only the 'new' key for that field" do
          expect(content).to eq({ "contact_links" =>
                                  { "contact-link" =>
                                    { "title" =>
                                      { "new" => "My Bad Contact link" },
                                      "label" =>
                                      { "published" => "My Nice label",
                                        "new" => "My Bad Label" },
                                      "url" =>
                                      { "published" => "https://nice.example.com",
                                        "new" => "https://bad.example.com" } } } })
        end
      end
    end

    context "when provided with arrays in the details" do
      let(:published_details) do
        { "telephone_numbers" => [{ "number" => "111", "label" => "before 1" }] }
      end
      let(:new_details) do
        { "telephone_numbers" => [{ "number" => "222", "label" => "after 1" }] }
      end

      it "should combine the arrays into an array of hashes with 'published' and 'new' keys" do
        expect(content).to eq({ "telephone_numbers" => [{ "number" => { "published" => "111",
                                                                        "new" => "222" },
                                                          "label" => { "published" => "before 1",
                                                                       "new" => "after 1" } }] })
      end

      context "when the new array is missing" do
        let(:new_details) { {} }

        it "should provide a combined structure containing only the published items inside the array" do
          expect(content).to eq({ "telephone_numbers" => [{ "number" => { "published" => "111" }, "label" => { "published" => "before 1" } }] })
        end
      end

      context "when the published array is missing" do
        let(:published_details) { {} }

        it "should provide a combined structure containing only the new items inside the array" do
          expect(content).to eq({ "telephone_numbers" => [{ "number" => { "new" => "222" }, "label" => { "new" => "after 1" } }] })
        end
      end

      context "when the published array contains more items than the new array" do
        let(:published_details) do
          { "telephone_numbers" =>
            [{ "number" => "111", "label" => "before 1" },
             { "number" => "112", "label" => "before 2" }] }
        end

        it "should provide an array with all of the items provided from both sides" do
          expect(content).to eq({ "telephone_numbers" =>
                                  [{ "number" => { "published" => "111", "new" => "222" }, "label" => { "published" => "before 1", "new" => "after 1" } },
                                   { "number" => { "published" => "112" }, "label" => { "published" => "before 2" } }] })
        end
      end

      context "when the new array contains more items than the published array" do
        let(:new_details) do
          { "telephone_numbers" =>
            [{ "number" => "222", "label" => "after 1" },
             { "number" => "223", "label" => "after 2" }] }
        end

        it "should provide an array with all of the items provided from both sides" do
          expect(content).to eq({ "telephone_numbers" =>
                                  [{ "number" => { "published" => "111", "new" => "222" }, "label" => { "published" => "before 1", "new" => "after 1" } },
                                   { "number" => { "new" => "223" }, "label" => { "new" => "after 2" } }] })
        end
      end

      context "when the arrays do not contain hashes" do
        let(:published_details) do
          { "telephone_numbers" => %w[111] }
        end
        let(:new_details) do
          { "telephone_numbers" => %w[222] }
        end

        it "should combine the arrays into an array of hashes with 'published' and 'new' keys" do
          expect(content).to eq({
            "telephone_numbers" => [
              { "published" => "111", "new" => "222" },
            ],
          })
        end
      end
    end
  end
end
