RSpec.describe Document::Scopes::SearchableByUpdatedDate do
  describe ".last_updated_after" do
    it "finds documents updated from and including this date" do
      filter_date_time = 1.day.before(Time.zone.now)
      matching_document_1 = create(:document, :pension)
      _old_edition_1 = create(:edition, :pension, document: matching_document_1, updated_at: 4.days.before(Time.zone.now))
      create(:edition, :pension, :published, document: matching_document_1, updated_at: filter_date_time)

      matching_document_2 = create(:document, :pension)
      _old_edition_2 = create(:edition, :pension, document: matching_document_2, updated_at: 12.days.before(Time.zone.now))
      create(:edition, :pension, :published, document: matching_document_2, updated_at: Time.zone.now)

      not_matching_document = create(:document, :pension)
      create(:edition, :pension, :published, document: not_matching_document, updated_at: 2.days.before(Time.zone.now))

      expect_elements_to_intersect(
        [matching_document_1, matching_document_2],
        Document.last_updated_after(filter_date_time),
      )
    end
  end

  describe ".last_updated_before" do
    it "finds documents updated up to and including this date" do
      filter_date_time = 1.day.before(Time.zone.now)

      matching_document_1 = create(:document, :pension)
      _old_edition_1 = create(:edition, :pension, document: matching_document_1, updated_at: 4.days.before(Time.zone.now))
      create(:edition, :pension, :published, document: matching_document_1, updated_at: filter_date_time)

      matching_document_2 = create(:document, :pension)
      _old_edition_2 = create(:edition, :pension, document: matching_document_2, updated_at: 2.days.before(Time.zone.now))
      create(:edition, :pension, :published, document: matching_document_2, updated_at: filter_date_time)

      not_matching_document = create(:document, :pension)
      create(:edition, :pension, :published, document: not_matching_document, updated_at: Time.zone.now)

      expect_elements_to_intersect(
        [matching_document_1, matching_document_2],
        Document.last_updated_before(filter_date_time),
      )
    end
  end
end
