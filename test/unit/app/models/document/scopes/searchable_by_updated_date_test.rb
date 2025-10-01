require "test_helper"

class SearchableByUpdatedDateTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe ".last_updated_after" do
    test "finds documents updated from and including this date" do
      filter_date_time = 1.day.before(Time.zone.now)
      matching_document_1 = create(:document, :pension)
      _old_edition_1 = create(:edition, :pension, document: matching_document_1, updated_at: 4.days.before(Time.zone.now))
      latest_edition_1 = create(:edition, :pension, document: matching_document_1, updated_at: filter_date_time)
      matching_document_1.latest_edition = latest_edition_1
      matching_document_1.save!

      matching_document_2 = create(:document, :pension)
      _old_edition_2 = create(:edition, :pension, document: matching_document_2, updated_at: 12.days.before(Time.zone.now))
      latest_edition_2 = create(:edition, :pension, document: matching_document_2, updated_at: Time.zone.now)
      matching_document_2.latest_edition = latest_edition_2
      matching_document_2.save!

      not_matching_document = create(:document, :pension)
      not_matching_edition = create(:edition, :pension, document: not_matching_document, updated_at: 2.days.before(Time.zone.now))
      not_matching_document.latest_edition = not_matching_edition
      not_matching_document.save!

      assert_same_elements [matching_document_1, matching_document_2], Document.last_updated_after(filter_date_time)
    end
  end

  describe ".last_updated_before" do
    test "finds documents updated up to and including this date" do
      filter_date_time = 1.day.before(Time.zone.now)

      matching_document_1 = create(:document, :pension)
      _old_edition_1 = create(:edition, :pension, document: matching_document_1, updated_at: 4.days.before(Time.zone.now))
      latest_edition_1 = create(:edition, :pension, document: matching_document_1, updated_at: filter_date_time)
      matching_document_1.latest_edition = latest_edition_1
      matching_document_1.save!

      matching_document_2 = create(:document, :pension)
      _old_edition_2 = create(:edition, :pension, document: matching_document_2, updated_at: 2.days.before(Time.zone.now))
      latest_edition_2 = create(:edition, :pension, document: matching_document_2, updated_at: filter_date_time)
      matching_document_2.latest_edition = latest_edition_2
      matching_document_2.save!

      not_matching_document = create(:document, :pension)
      not_matching_edition = create(:edition, :pension, document: not_matching_document, updated_at: Time.zone.now)
      not_matching_document.latest_edition = not_matching_edition
      not_matching_document.save!

      assert_same_elements [matching_document_1, matching_document_2], Document.last_updated_before(filter_date_time)
    end
  end
end
