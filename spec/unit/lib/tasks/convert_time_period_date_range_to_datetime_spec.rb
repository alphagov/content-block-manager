RSpec.describe "data_migration:convert_time_period_date_range_to_datetime" do
  let(:task) { Rake::Task["data_migration:convert_time_period_date_range_to_datetime"] }

  let!(:document) { create(:document, block_type: :time_period) }

  after do
    task.reenable
  end

  describe "when there are editions with #date_range in both old and new forms" do
    let!(:edition_new_format) do
      create(
        :edition,
        document: document,
        title: "Time period (new format)",
        details: { "date_range" => {
          "start" => "2026-04-06T00:00:00+01:00",
          "end" => "2027-04-05T23:59:00+01:00",
        } },
      )
    end

    let!(:edition_old_format) do
      create(
        :edition,
        document: document,
        title: "Time period (old format)",
        details: { "date_range" => {
          "start" => { "date" => "2025-04-06", "time" => "00:00" },
          "end" => { "date" => "2026-04-05", "time" => "23:59" },
        } },
      )
    end

    it "the edition with the old format is converted to the new datetime form" do
      task.invoke

      expect(edition_old_format.reload.details).to eq(
        { "date_range" => {
          "start" => "2025-04-06T00:00:00+01:00",
          "end" => "2026-04-05T23:59:00+01:00",
        } },
      )
    end

    it "the edition with the new format remains in the new datetime form" do
      task.invoke

      expect(edition_new_format.reload.details).to eq(
        { "date_range" => {
          "start" => "2026-04-06T00:00:00+01:00",
          "end" => "2027-04-05T23:59:00+01:00",
        } },
      )
    end
  end
end
