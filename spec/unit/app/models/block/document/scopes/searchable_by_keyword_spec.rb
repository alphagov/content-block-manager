RSpec.describe "SearchableByKeyword" do
  describe ".with_keyword" do
    it "should find documents with title containing keyword" do
      document_with_first_keyword = create(:block_document)
      _edition_with_first_keyword = create(:block_time_period_edition,
                                           document: document_with_first_keyword,
                                           title: "klingons and such")
      document_without_first_keyword = create(:block_document)
      _edition_without_first_keyword = create(:block_time_period_edition, document: document_without_first_keyword,
                                                                          title: "this document is about muppets")

      expect(Block::Document.with_keyword("klingons")).to eq([document_with_first_keyword])
    end

    it "should find documents with title containing keywords not in order" do
      document_with_first_keyword = create(:block_document)
      _edition_with_first_keyword = create(:block_time_period_edition,
                                           document: document_with_first_keyword,
                                           title: "klingons and such")
      _document_without_first_keyword = create(:block_document)

      expect(Block::Document.with_keyword("such klingons")).to eq([document_with_first_keyword])
    end

    it "should find documents with latest edition's description containing keyword" do
      document_with_first_keyword = create(:block_document)
      _edition_with_first_keyword = create(:block_time_period_edition,
                                           document: document_with_first_keyword,
                                           description: "foo bar",
                                           title: "example title")
      document_without_first_keyword = create(:block_document)
      _edition_without_first_keyword = create(:block_time_period_edition,
                                              document: document_without_first_keyword,
                                              description: "something",
                                              title: "this document is about muppets")

      expect(Block::Document.with_keyword("foo bar")).to eq([document_with_first_keyword])
    end

    it "should find documents with instructions to publishers containing keyword" do
      document_with_first_keyword = create(:block_document)
      _edition_with_first_keyword = create(:block_time_period_edition,
                                           document: document_with_first_keyword,
                                           instructions_to_publishers: "foo",
                                           title: "example title")
      document_without_first_keyword = create(:block_document)
      _edition_without_first_keyword = create(:block_time_period_edition,
                                              document: document_without_first_keyword,
                                              instructions_to_publishers: "bar",
                                              title: "this document is about muppets")

      expect(Block::Document.with_keyword("foo")).to eq([document_with_first_keyword])
    end

    it "should find documents with description or title containing keyword" do
      document_with_keyword_in_description = create(:block_document)
      _edition_with_keyword = create(:block_time_period_edition,
                                     document: document_with_keyword_in_description,
                                     description: "foo text",
                                     title: "example title")
      document_with_keyword_in_title = create(:block_document)
      _edition_without_keyword = create(:block_time_period_edition,
                                        document: document_with_keyword_in_title,
                                        description: "something",
                                        title: "this document is about text foo")

      expect(Block::Document.with_keyword("foo text")).to eq(
        [document_with_keyword_in_description, document_with_keyword_in_title],
      )
    end

    describe "search using embed_code" do
      let!(:document) { create(:block_document, block_type: "time_period", content_id_alias: "my-document") }
      let!(:another_document) { create(:block_document, block_type: "time_period", content_id_alias: "another-document") }

      it "should find document using full embed_code" do
        expect(Block::Document.with_keyword("{{embed:content_block_time_period:my-document}}")).to eq(
          [document],
        )
      end

      it "should find document using just the content_id_alias element of the embed code" do
        expect(Block::Document.with_keyword("my-document")).to eq(
          [document],
        )
      end
    end
  end
end
