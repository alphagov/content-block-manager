require "test_helper"

class EditionHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL

  include ERB::Util
  include EditionHelper

  let(:edition) do
    build(:edition,
          updated_at: Time.zone.now - 2.days,
          scheduled_publication: Time.zone.now + 3.days)
  end

  describe "#published_date" do
    it "calls the time tag helper with the `updated_at` value of the edition" do
      tag.expects(:time).with(
        edition.updated_at.to_fs(:long_ordinal_with_at),
        class: "date",
        datetime: edition.updated_at.iso8601,
        lang: "en",
      ).returns("STUB")

      assert_equal "STUB", published_date(edition)
    end
  end

  describe "#scheduled_date" do
    it "calls the time tag helper with the `scheduled_publication` value of the edition" do
      tag.expects(:time).with(
        edition.scheduled_publication.to_fs(:long_ordinal_with_at),
        class: "date",
        datetime: edition.scheduled_publication.iso8601,
        lang: "en",
      ).returns("STUB")

      assert_equal "STUB", scheduled_date(edition)
    end
  end

  describe "#formatted_instructions_to_publishers" do
    test "it adds line breaks and links to instructions to publishers" do
      edition.instructions_to_publishers = "
        Hello
        There
        Here is a link: https://example.com
      "
      expected = "
      <p class=\"govuk-!-margin-top-0\">
        Hello <br />
        There <br />
        Here is a link: <a href=\"https://example.com\" class=\"govuk-link\" target=\"_blank\" rel=\"noopener\">https://example.com</a> <br />
      </p>
      "

      assert_equal expected.squish, formatted_instructions_to_publishers(edition).squish
    end
  end
end
