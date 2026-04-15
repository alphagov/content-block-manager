RSpec.describe DateRangeValidator do
  let(:edition) { build(:edition, :time_period) }

  describe "#validate_and_convert" do
    context "with valid date range params" do
      let(:params) do
        {
          "start(1i)" => "2025",
          "start(2i)" => "04",
          "start(3i)" => "06",
          "start(4i)" => "09",
          "start(5i)" => "30",
          "end(1i)" => "2026",
          "end(2i)" => "04",
          "end(3i)" => "05",
          "end(4i)" => "17",
          "end(5i)" => "00",
        }
      end

      it "returns ISO 8601 formatted start and end datetimes" do
        result = DateRangeValidator.new(edition, params).validate_and_convert

        expect(result["start"]).to match(/\A2025-04-06T09:30:00[+-]\d{2}:\d{2}\z/)
        expect(result["end"]).to match(/\A2026-04-05T17:00:00[+-]\d{2}:\d{2}\z/)
      end

      it "does not add any errors" do
        DateRangeValidator.new(edition, params).validate_and_convert

        expect(edition.errors).to be_empty
      end

      context "when params include non-datetime fields" do
        let(:params_with_title) do
          params.merge("title" => "Tax Year 2025-26")
        end

        it "preserves non-datetime fields in the result" do
          result = DateRangeValidator.new(edition, params_with_title).validate_and_convert

          expect(result["title"]).to eq("Tax Year 2025-26")
        end

        it "strips multiparameter keys from the result" do
          result = DateRangeValidator.new(edition, params_with_title).validate_and_convert

          expect(result.keys).to contain_exactly("title", "start", "end")
        end
      end
    end

    context "when start date is blank" do
      let(:params) do
        {
          "start(1i)" => "",
          "start(2i)" => "",
          "start(3i)" => "",
          "start(4i)" => "",
          "start(5i)" => "",
          "end(1i)" => "2026",
          "end(2i)" => "04",
          "end(3i)" => "05",
          "end(4i)" => "17",
          "end(5i)" => "00",
        }
      end

      it "raises ActiveRecord::RecordInvalid" do
        expect { DateRangeValidator.new(edition, params).validate_and_convert }
          .to raise_error(ActiveRecord::RecordInvalid)
      end

      it "adds an error for the start field" do
        begin
          DateRangeValidator.new(edition, params).validate_and_convert
        rescue ActiveRecord::RecordInvalid
          # expected
        end

        expect(edition.errors[:details_date_range_start]).to be_present
      end
    end

    context "when start date is invalid (e.g., month 13)" do
      let(:params) do
        {
          "start(1i)" => "2025",
          "start(2i)" => "13",
          "start(3i)" => "06",
          "start(4i)" => "09",
          "start(5i)" => "30",
          "end(1i)" => "2026",
          "end(2i)" => "04",
          "end(3i)" => "05",
          "end(4i)" => "17",
          "end(5i)" => "00",
        }
      end

      it "raises ActiveRecord::RecordInvalid" do
        expect { DateRangeValidator.new(edition, params).validate_and_convert }
          .to raise_error(ActiveRecord::RecordInvalid)
      end

      it "adds an error for the start field" do
        begin
          DateRangeValidator.new(edition, params).validate_and_convert
        rescue ActiveRecord::RecordInvalid
          # expected
        end

        expect(edition.errors[:details_date_range_start]).to be_present
      end
    end

    context "when end datetime is not after start datetime" do
      let(:params) do
        {
          "start(1i)" => "2026",
          "start(2i)" => "04",
          "start(3i)" => "06",
          "start(4i)" => "09",
          "start(5i)" => "30",
          "end(1i)" => "2025",
          "end(2i)" => "04",
          "end(3i)" => "05",
          "end(4i)" => "17",
          "end(5i)" => "00",
        }
      end

      it "raises ActiveRecord::RecordInvalid" do
        expect { DateRangeValidator.new(edition, params).validate_and_convert }
          .to raise_error(ActiveRecord::RecordInvalid)
      end

      it "adds an error indicating end must be after start" do
        begin
          DateRangeValidator.new(edition, params).validate_and_convert
        rescue ActiveRecord::RecordInvalid
          # expected
        end

        expect(edition.errors[:details_date_range_end].first)
          .to include("must be after")
      end
    end

    context "when end datetime equals start datetime" do
      let(:params) do
        {
          "start(1i)" => "2025",
          "start(2i)" => "04",
          "start(3i)" => "06",
          "start(4i)" => "09",
          "start(5i)" => "30",
          "end(1i)" => "2025",
          "end(2i)" => "04",
          "end(3i)" => "06",
          "end(4i)" => "09",
          "end(5i)" => "30",
        }
      end

      it "raises ActiveRecord::RecordInvalid (end must be strictly after start)" do
        expect { DateRangeValidator.new(edition, params).validate_and_convert }
          .to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when time fields are blank" do
      let(:params) do
        {
          "start(1i)" => "2025",
          "start(2i)" => "04",
          "start(3i)" => "06",
          "start(4i)" => "",
          "start(5i)" => "",
          "end(1i)" => "2026",
          "end(2i)" => "04",
          "end(3i)" => "05",
          "end(4i)" => "",
          "end(5i)" => "",
        }
      end

      it "defaults time to 00:00 and returns valid ISO 8601" do
        result = DateRangeValidator.new(edition, params).validate_and_convert

        expect(result["start"]).to match(/\A2025-04-06T00:00:00[+-]\d{2}:\d{2}\z/)
        expect(result["end"]).to match(/\A2026-04-05T00:00:00[+-]\d{2}:\d{2}\z/)
      end
    end
  end
end
