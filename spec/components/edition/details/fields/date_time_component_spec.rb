RSpec.describe Edition::Details::Fields::DateTimeComponent, type: :component do
  let(:schema_body) do
    {
      "properties" => {
        "start" => {
          "type" => "object",
          "properties" => {
            "date" => { "type" => "string", "format" => "date" },
            "time" => { "type" => "string", "format" => "time" },
          },
        },
      },
    }
  end

  let(:schema) { build(:embedded_schema, block_type: :date_range, body: schema_body) }
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
  let(:params) { {} }

  before do
    allow(I18n).to receive(:t).and_call_original
    allow(I18n).to receive(:t).with("edition.titles.travel_advice.start").and_return("Start date")
    allow_any_instance_of(described_class).to receive(:params).and_return(params)

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
      let(:schema) { build(:embedded_schema, block_type: :travel_advice, body: schema_body) }

      it "should contain the block_type of the Schema" do
        expect(page).to have_css('*[name^="edition[details][travel_advice]"]', count: 5)
      end
    end

    it "should use the rails multiparameter_attribute format for the field names" do
      expect(page).to have_css('*[name="edition[details][date_range][start][date(1i)]"]') # year
      expect(page).to have_css('*[name="edition[details][date_range][start][date(2i)]"]') # month
      expect(page).to have_css('*[name="edition[details][date_range][start][date(3i)]"]') # day
      expect(page).to have_css('*[name="edition[details][date_range][start][time(4i)]"]') # hour
      expect(page).to have_css('*[name="edition[details][date_range][start][time(5i)]"]') # minute
    end
  end

  describe "pre-populating values from existing edition details" do
    context "when the edition has stored date and time values" do
      let(:details) { { "date_range" => { "start" => { "date" => "2001-02-03", "time" => "04:05" } } } }

      it "pre-populates the date inputs" do
        inputs = page.find_all("input")
        expect(inputs[2].value).to eq("2001") # year
        expect(inputs[1].value).to eq("2")    # month
        expect(inputs[0].value).to eq("3")    # day
      end

      it "pre-populates the time selects" do
        selects = page.find_all("select")
        expect(selects[0].value).to eq("04") # hour
        expect(selects[1].value).to eq("05") # minute
      end
    end

    context "when the edition has invalid date and time values" do
      let(:details) { { "date_range" => { "start" => { "date" => "1111111-34444-99999", "time" => "222222:4444" } } } }
      let(:params) do
        ActionController::Parameters.new({
          "edition" => {
            "details" => {
              "date_range" => {
                "start" => {
                  "date(1i)" => "1111111",
                  "date(2i)" => "34444",
                  "date(3i)" => "99999",
                  "time(4i)" => "222222",
                  "time(5i)" => "4444",
                },
              },
            },
          },
        })
      end

      it "pre-populates the date inputs" do
        inputs = page.find_all("input")
        expect(inputs[2].value).to eq("1111111") # year
        expect(inputs[1].value).to eq("34444")    # month
        expect(inputs[0].value).to eq("99999")    # day
      end

      it "sets the time selects to blank" do
        # We don't expect invalid values to be set, but we do want to ensure that we handle them gracefully.
        selects = page.find_all("select")
        expect(selects[0].value).to eq("") # hour
        expect(selects[1].value).to eq("") # minute
      end
    end

    context "when the edition has no details for this field" do
      let(:details) { {} }

      it "renders blank inputs without raising an error" do
        expect(page).to have_css("input", count: 3)
        expect(page).to have_css("select", count: 2)
        page.find_all("input").each { |input| expect(input.value).to be_blank }
      end
    end

    context "when both stored values and params are present" do
      let(:details) { { "date_range" => { "start" => { "date" => "2001-02-03", "time" => "04:05" } } } }
      let(:params) do
        ActionController::Parameters.new({
          "edition" => {
            "details" => {
              "date_range" => {
                "start" => {
                  "date(1i)" => "2024",
                  "date(2i)" => "10",
                  "date(3i)" => "15",
                  "time(4i)" => "11",
                  "time(5i)" => "45",
                },
              },
            },
          },
        })
      end

      it "prefers params for date inputs" do
        inputs = page.find_all("input")
        expect(inputs[2].value).to eq("2024") # year
        expect(inputs[1].value).to eq("10")   # month
        expect(inputs[0].value).to eq("15")   # day
      end

      it "prefers params for time selects" do
        selects = page.find_all("select")
        expect(selects[0].value).to eq("11") # hour
        expect(selects[1].value).to eq("45") # minute
      end
    end
  end
end
