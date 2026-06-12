RSpec.describe "data_migration:remove_pound_symbol_prefix_from_pension_amount_value" do
  let(:task) { Rake::Task["data_migration:remove_pound_symbol_prefix_from_pension_amount_value"] }

  let!(:document) { create(:document, block_type: :pension) }

  after do
    task.reenable
  end

  describe "when there is an edition with #amounts both with and without prefixes" do
    let!(:pension_edition) do
      create(
        :edition,
        document: document,
        title: "Pension",
        details: { "rates" => {
          "rate_with_prefix" => { "amount" => "£221.20", "frequency" => "per week" },
          "rate_without_prefix" => { "amount" => "132.50", "frequency" => "per week" },
        } },
      )
    end

    it "removes the pound symbol prefix from values that contain it" do
      task.invoke

      expect(pension_edition.reload.details["rates"]["rate_with_prefix"]).to eq(
        { "amount" => "221.20", "frequency" => "per week" },
      )
    end

    it "does not change values that do not contain the pound symbol prefix" do
      task.invoke

      expect(pension_edition.reload.details["rates"]["rate_without_prefix"]).to eq(
        { "amount" => "132.50", "frequency" => "per week" },
      )
    end
  end
end
