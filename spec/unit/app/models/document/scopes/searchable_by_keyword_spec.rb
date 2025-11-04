RSpec.describe "SearchableByKeyword" do
  describe ".with_keyword" do
    it "should find documents with title containing keyword" do
      document_with_first_keyword = create(:document, :pension)
      _edition_with_first_keyword = create(:edition,
                                           :pension,
                                           document: document_with_first_keyword,
                                           details: { "email_address" => "hello@hello.com" },
                                           title: "klingons and such")
      document_without_first_keyword = create(:document, :pension)
      _edition_without_first_keyword = create(:edition, :pension, document: document_without_first_keyword,
                                                                  title: "this document is about muppets")

      expect(Document.with_keyword("klingons")).to eq([document_with_first_keyword])
    end

    it "should find documents with title containing keywords not in order" do
      document_with_first_keyword = create(:document, :pension)
      _edition_with_first_keyword = create(:edition,
                                           :pension,
                                           document: document_with_first_keyword,
                                           details: { "email_address" => "hello@hello.com" },
                                           title: "klingons and such")
      _document_without_first_keyword = create(:document, :pension)

      expect(Document.with_keyword("such klingons")).to eq([document_with_first_keyword])
    end

    it "should find documents with latest edition's details containing keyword" do
      document_with_first_keyword = create(:document, :pension)
      _edition_with_first_keyword = create(:edition,
                                           document: document_with_first_keyword,
                                           details: { "foo" => "Foo text", "bar" => "Bar text" },
                                           title: "example title")
      document_without_first_keyword = create(:document, :pension)
      _edition_without_first_keyword = create(:edition,
                                              document: document_without_first_keyword,
                                              details: { "something" => "something" },
                                              title: "this document is about muppets")

      expect(Document.with_keyword("foo bar")).to eq([document_with_first_keyword])
    end

    it "should find documents with instructions to publishers containing keyword" do
      document_with_first_keyword = create(:document, :pension)
      _edition_with_first_keyword = create(:edition,
                                           document: document_with_first_keyword,
                                           instructions_to_publishers: "foo",
                                           title: "example title")
      document_without_first_keyword = create(:document, :pension)
      _edition_without_first_keyword = create(:edition,
                                              document: document_without_first_keyword,
                                              instructions_to_publishers: "bar",
                                              title: "this document is about muppets")

      expect(Document.with_keyword("foo")).to eq([document_with_first_keyword])
    end

    it "should find documents with details or title containing keyword" do
      document_with_keyword_in_details = create(:document, :pension)
      _edition_with_keyword = create(:edition,
                                     document: document_with_keyword_in_details,
                                     details: { "title" => "foo text", "description" => "bar text" },
                                     title: "example title")
      document_with_keyword_in_title = create(:document, :pension)
      _edition_without_keyword = create(:edition,
                                        document: document_with_keyword_in_title,
                                        details: { "something" => "something" },
                                        title: "this document is about bar foo")

      expect(Document.with_keyword("foo bar")).to eq(
        [document_with_keyword_in_title, document_with_keyword_in_details],
      )
    end

    describe "search using embed_code" do
      let!(:pension_doc) { create(:document, :pension, content_id_alias: "my-pension") }
      let!(:_contact_doc) { create(:document, :contact, content_id_alias: "my-contact") }

      it "should find document using full embed_code" do
        expect(Document.with_keyword("{{embed:content_block_pension:my-pension}}")).to eq(
          [pension_doc],
        )
      end

      it "should find document using just the content_id_alias element of the embed code" do
        expect(Document.with_keyword("my-pension")).to eq(
          [pension_doc],
        )
      end
    end
  end
end
