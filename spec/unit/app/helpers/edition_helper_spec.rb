RSpec.describe EditionHelper, type: :helper do
  include ERB::Util
  include EditionHelper

  let(:edition) do
    build(:edition,
          updated_at: Time.zone.now - 2.days,
          scheduled_publication: Time.zone.now + 3.days)
  end

  describe "#updated_date" do
    it "calls the time tag helper with the `updated_at` value of the edition" do
      allow(tag).to receive(:time).with(
        edition.updated_at.to_fs(:long_ordinal_with_at),
        class: "date",
        datetime: edition.updated_at.iso8601,
        lang: "en",
      ).and_return("STUB")

      expect(updated_date(edition)).to eq("STUB")
    end
  end

  describe "#scheduled_date" do
    it "calls the time tag helper with the `scheduled_publication` value of the edition" do
      allow(tag).to receive(:time).with(
        edition.scheduled_publication.to_fs(:long_ordinal_with_at),
        class: "date",
        datetime: edition.scheduled_publication.iso8601,
        lang: "en",
      ).and_return("STUB")

      expect(scheduled_date(edition)).to eq("STUB")
    end
  end

  describe "#formatted_instructions_to_publishers" do
    it "it adds line breaks and links to instructions to publishers" do
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

      expect(formatted_instructions_to_publishers(edition).squish).to eq(expected.squish)
    end
  end

  describe "#current_state_label" do
    Edition.new.available_states.each do |state|
      context "when the Edition has a the '#{state}' state" do
        let(:edition) { build(:edition, state: state, scheduled_publication: Time.zone.now) }

        it "should return a string label" do
          expect { current_state_label(edition) }.not_to raise_error
          expect(current_state_label(edition)).to be_a(String)
        end
      end
    end

    context "when the Edition has an unknown state" do
      let(:edition) { build(:edition, state: "ready_to_publish") }

      it "should raise an error" do
        expect { current_state_label(edition) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#date_range_from_params" do
    context "when called with empty details" do
      let(:details) { {} }

      it "should return an empty date range" do
        expect(date_range_from_params(details)).to eq({})
      end
    end

    context "when called with details which don't contain a date range as input" do
      let(:details) { { "foo" => "bar" } }

      it "should return an empty date range" do
        expect(date_range_from_params(details)).to eq({})
      end
    end

    context "when called with a date range in the rails array format" do
      let(:details) do
        { "date_range" =>
          {
            "start(1i)" => "2025",
            "start(2i)" => "04",
            "start(3i)" => "06",
            "start(4i)" => "00",
            "start(5i)" => "00",
            "end(1i)" => "2026",
            "end(2i)" => "04",
            "end(3i)" => "05",
            "end(4i)" => "23",
            "end(5i)" => "59",
          } }
      end

      it "should return the date range in the format we store in the model" do
        expect(date_range_from_params(details)).to eq({
          "date_range" => {
            "start" => {
              "date" => "2025-04-06",
              "time" => "00:00",
            },
            "end" => {
              "date" => "2026-04-05",
              "time" => "23:59",
            },
          },
        })
      end
    end
  end
end
