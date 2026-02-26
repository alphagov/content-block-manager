RSpec.describe Edition::Details::Fields::DateTimeComponent, type: :component do
  let(:schema) { build(:embedded_schema, block_type: :date_range) }
  let(:details) { {} }
  let(:edition) { build(:edition, :time_period, details:) }
  let(:context) do
    Edition::Details::Fields::Context
      .new(
        edition:,
        field: Schema::Field.new("start", schema),
        schema:,
      )
  end
  let(:component) { described_class.new(context) }

  before do
    allow(I18n).to receive(:t).and_call_original
    allow(I18n).to receive(:t).with("edition.titles.travel_advice.start").and_return("")
    allow(I18n).to receive(:t).with("edition.titles.travel_advice.end").and_return("")
    render_inline(component)
  end

  it "should render the inputs with a title" do
    expect(page).to have_css(".govuk-fieldset__legend", text: I18n.t("edition.titles.date_range.start"))

    expect(page).to have_css(".govuk-fieldset__legend", text: "Date")
    expect(page).to have_css("input", count: 3)

    expect(page).to have_css(".govuk-fieldset__legend", text: "Time")
    expect(page).to have_css("select", count: 2)
  end

  describe "the 'name' of the inputs" do
    context "when working on an Edition with a specific Schema" do
      let(:schema) { build(:embedded_schema, block_type: :travel_advice) }

      it "should contain the block_type of the Schema" do
        expect(page).to have_css('*[name^="edition[details][travel_advice]"]', count: 5)
      end
    end

    it "should use the rails multiparameter_attribute format for the field names" do
      expect(page).to have_css('*[name="edition[details][date_range][start(1i)]"]') # year
      expect(page).to have_css('*[name="edition[details][date_range][start(2i)]"]') # month
      expect(page).to have_css('*[name="edition[details][date_range][start(3i)]"]') # day
      expect(page).to have_css('*[name="edition[details][date_range][start(4i)]"]') # hour
      expect(page).to have_css('*[name="edition[details][date_range][start(5i)]"]') # minute
    end
  end

  describe "when there are existing values" do
    let(:details) { { "date_range" => { "start" => { "date" => "2001-02-03", "time" => "04:05" } } } }

    it "should show existing values" do
      inputs = page.find_all("input")
      expect(inputs[2].value).to eq("2001")
      expect(inputs[1].value).to eq("2")
      expect(inputs[0].value).to eq("3")

      selects = page.find_all("select")
      expect(selects[0].value).to eq("04")
      expect(selects[1].value).to eq("05")
    end
  end
end
