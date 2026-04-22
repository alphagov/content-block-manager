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

  describe "#id_for" do
    it "returns the field name combined with the field part" do
      expect(component.id_for(:year)).to eq("start_year")
      expect(component.id_for(:month)).to eq("start_month")
      expect(component.id_for(:day)).to eq("start_day")
      expect(component.id_for(:hour)).to eq("start_hour")
      expect(component.id_for(:minute)).to eq("start_minute")
    end
  end

  describe "#name_for" do
    it "returns the Rails multiparameter attribute format" do
      expect(component.name_for(:year)).to eq("edition[details][date_range][start(1i)]")
      expect(component.name_for(:month)).to eq("edition[details][date_range][start(2i)]")
      expect(component.name_for(:day)).to eq("edition[details][date_range][start(3i)]")
      expect(component.name_for(:hour)).to eq("edition[details][date_range][start(4i)]")
      expect(component.name_for(:minute)).to eq("edition[details][date_range][start(5i)]")
    end
  end

  describe "#label_for" do
    it "returns the human-readable label for each field part" do
      expect(component.label_for(:year)).to eq("Year")
      expect(component.label_for(:month)).to eq("Month")
      expect(component.label_for(:day)).to eq("Day")
      expect(component.label_for(:hour)).to eq("Hour")
      expect(component.label_for(:minute)).to eq("Minute")
    end
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

  describe "when there are existing values in ISO 8601 format" do
    let(:details) { { "date_range" => { "start" => "2001-02-03T04:05:00+00:00" } } }

    it "populates the form fields from the ISO 8601 datetime" do
      inputs = page.find_all("input")
      expect(inputs[2].value).to eq("2001")
      expect(inputs[1].value).to eq("2")
      expect(inputs[0].value).to eq("3")

      selects = page.find_all("select")
      expect(selects[0].value).to eq("04")
      expect(selects[1].value).to eq("05")
    end
  end

  describe "when there are existing values in legacy nested format" do
    let(:details) { { "date_range" => { "start" => { "date" => "2001-02-03", "time" => "04:05" } } } }

    it "populates the form fields from the nested hash" do
      inputs = page.find_all("input")
      expect(inputs[2].value).to eq("2001")
      expect(inputs[1].value).to eq("2")
      expect(inputs[0].value).to eq("3")

      selects = page.find_all("select")
      expect(selects[0].value).to eq("04")
      expect(selects[1].value).to eq("05")
    end
  end

  describe "when context.details contains Rails multiparameter format (validation failure re-render)" do
    let(:context) do
      Edition::Details::Fields::Context
        .new(
          edition:,
          field: Schema::Field.new("start", schema),
          schema:,
          details: {
            "start(1i)" => "2001",
            "start(2i)" => "2",
            "start(3i)" => "3",
            "start(4i)" => "04",
            "start(5i)" => "05",
          },
        )
    end

    it "populates the form fields from multiparameter params" do
      inputs = page.find_all("input")
      expect(inputs[2].value).to eq("2001")
      expect(inputs[1].value).to eq("2")
      expect(inputs[0].value).to eq("3")

      selects = page.find_all("select")
      expect(selects[0].value).to eq("04")
      expect(selects[1].value).to eq("05")
    end
  end

  describe "when there is a validation error on the field" do
    let(:edition) do
      build(:edition, :time_period, details:).tap do |e|
        e.errors.add(:details_date_range_start, "Start is invalid")
      end
    end

    it "applies error styling to the datetime fields wrapper" do
      expect(page).to have_css(".app-c-datetime-fields.govuk-form-group--error")
    end
  end

  describe "when re-rendering after validation failure" do
    describe "with an invalid date (e.g., Feb 30)" do
      let(:context) do
        Edition::Details::Fields::Context
          .new(
            edition:,
            field: Schema::Field.new("start", schema),
            schema:,
            details: {
              "start(1i)" => "2025",
              "start(2i)" => "2",
              "start(3i)" => "30",
              "start(4i)" => "09",
              "start(5i)" => "30",
            },
          )
      end

      it "preserves the user's original day value without normalizing to March 2" do
        inputs = page.find_all("input")
        expect(inputs[0].value).to eq("30")
      end
    end

    describe "with leading zeros in input" do
      let(:context) do
        Edition::Details::Fields::Context
          .new(
            edition:,
            field: Schema::Field.new("start", schema),
            schema:,
            details: {
              "start(1i)" => "2025",
              "start(2i)" => "02",
              "start(3i)" => "03",
              "start(4i)" => "04",
              "start(5i)" => "05",
            },
          )
      end

      it "preserves leading zeros in input values" do
        inputs = page.find_all("input")
        expect(inputs[2].value).to eq("2025")
        expect(inputs[1].value).to eq("02")
        expect(inputs[0].value).to eq("03")

        selects = page.find_all("select")
        expect(selects[0].value).to eq("04")
        expect(selects[1].value).to eq("05")
      end
    end

    describe "with non-numeric input" do
      let(:context) do
        Edition::Details::Fields::Context
          .new(
            edition:,
            field: Schema::Field.new("start", schema),
            schema:,
            details: {
              "start(1i)" => "abc",
              "start(2i)" => "2",
              "start(3i)" => "3",
              "start(4i)" => "09",
              "start(5i)" => "30",
            },
          )
      end

      it "preserves the invalid input for display" do
        inputs = page.find_all("input")
        expect(inputs[2].value).to eq("abc")
      end
    end
  end
end
