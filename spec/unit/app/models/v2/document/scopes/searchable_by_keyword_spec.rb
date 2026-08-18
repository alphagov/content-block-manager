RSpec.describe "SearchableByKeyword" do
  describe ".where_keyword" do
    it "should find documents with title containing keyword" do
      document_with_first_keyword = create(:v2_document)
      _edition_with_first_keyword = create(:v2_time_period_edition,
                                           document: document_with_first_keyword,
                                           title: "klingons and such")
      document_without_first_keyword = create(:v2_document)
      _edition_without_first_keyword = create(:v2_time_period_edition, document: document_without_first_keyword,
                                                                       title: "this document is about muppets")

      expect(V2::Document.where_keyword("klingons")).to eq([document_with_first_keyword])
    end

    it "should find documents with title containing keywords not in order" do
      document_with_first_keyword = create(:v2_document)
      _edition_with_first_keyword = create(:v2_time_period_edition,
                                           document: document_with_first_keyword,
                                           title: "klingons and such")
      _document_without_first_keyword = create(:v2_document)

      expect(V2::Document.where_keyword("such klingons")).to eq([document_with_first_keyword])
    end

    it "should find documents with instructions to publishers containing keyword" do
      document_with_first_keyword = create(:v2_document)
      _edition_with_first_keyword = create(:v2_time_period_edition,
                                           document: document_with_first_keyword,
                                           instructions_to_publishers: "foo",
                                           title: "example title")
      document_without_first_keyword = create(:v2_document)
      _edition_without_first_keyword = create(:v2_time_period_edition,
                                              document: document_without_first_keyword,
                                              instructions_to_publishers: "bar",
                                              title: "this document is about muppets")

      expect(V2::Document.where_keyword("foo")).to eq([document_with_first_keyword])
    end

    describe "search using embed_code" do
      let!(:document) { create(:v2_document, block_type: "time_period", content_id_alias: "my-document") }
      let!(:another_document) { create(:v2_document, block_type: "time_period", content_id_alias: "another-document") }

      it "should find document using full embed_code" do
        expect(V2::Document.where_keyword("{{embed:content_block_time_period:my-document}}")).to eq(
          [document],
        )
      end

      it "should find document using just the content_id_alias element of the embed code" do
        expect(V2::Document.where_keyword("my-document")).to eq(
          [document],
        )
      end
    end
  end
end
