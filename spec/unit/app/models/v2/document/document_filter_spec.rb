RSpec.describe V2::Document::DocumentFilter do
  subject(:filter) { described_class.new(params).call }

  let(:params) { {} }
  let(:document_scope_spy) { spy }

  before do
    allow(V2::Document).to receive(:all).and_return(document_scope_spy)
    allow(document_scope_spy).to receive_messages(
      where_block_type: document_scope_spy,
      where_lead_organisation: document_scope_spy,
      where_where_last_updated_after: document_scope_spy,
      where_where_last_updated_before: document_scope_spy,
      by_most_recently_created_edition: document_scope_spy,
      where: document_scope_spy,
      page: document_scope_spy,
      per: document_scope_spy,
    )
  end

  describe "#call" do
    context "when no filters are given" do
      it "returns documents with default pagination and scopes applied" do
        allow(V2::Document).to receive(:where_keyword)

        filter

        expect(V2::Document).not_to have_received(:where_keyword)
        expect(document_scope_spy).not_to have_received(:where).with(id: anything)
        expect(document_scope_spy).to have_received(:where_block_type).with(nil)
        expect(document_scope_spy).to have_received(:where_lead_organisation).with(nil)
        expect(document_scope_spy).to have_received(:by_most_recently_created_edition)
        expect(document_scope_spy).to have_received(:page).with(1)
        expect(document_scope_spy).to have_received(:per).with(10)
      end
    end

    context "when filtering by keyword" do
      let(:keyword_relation) { instance_double(ActiveRecord::Relation) }
      let(:ids) { [1, 2, 3] }

      before do
        allow(V2::Document).to receive(:where_keyword).and_return(keyword_relation)
        allow(keyword_relation).to receive(:pluck).with(:id).and_return(ids)
      end

      context "with standard text" do
        let(:params) { { keyword: "ministry of example" } }

        it "filters documents matching the target IDs" do
          filter

          expect(V2::Document).to have_received(:where_keyword).with("ministry of example")
          expect(document_scope_spy).to have_received(:where).with(id: ids)
        end
      end

      context "with an embed code containing an attribute reference" do
        let(:params) { { keyword: "{{embed:content_block_pension:basic-state-pension/rates/full-basic-state-pension-amount/amount}}" } }

        it "strips the attribute reference before searching" do
          filter

          expect(V2::Document).to have_received(:where_keyword).with("{{embed:content_block_pension:basic-state-pension}}")
          expect(document_scope_spy).to have_received(:where).with(id: ids)
        end
      end

      context "with an embed code without an attribute reference" do
        let(:params) { { keyword: "{{embed:content_block_pension:basic-state-pension}}" } }

        it "searches with the embed code intact" do
          filter

          expect(V2::Document).to have_received(:where_keyword).with("{{embed:content_block_pension:basic-state-pension}}")
          expect(document_scope_spy).to have_received(:where).with(id: ids)
        end
      end
    end

    context "when filtering by block_type" do
      let(:params) { { block_type: %w[time_period] } }

      it "delegates block_type filter to the query scope" do
        filter

        expect(document_scope_spy).to have_received(:where_block_type).with(%w[time_period])
      end
    end

    context "when filtering by page" do
      let(:params) { { page: 2 } }

      it "passes the page parameter with default per-page size" do
        filter

        expect(document_scope_spy).to have_received(:page).with(2)
        expect(document_scope_spy).to have_received(:per).with(10)
      end
    end

    context "when filtering by last_updated dates" do
      it "applies starting date filter correctly" do
        described_class.new(last_updated_from: { "1i" => "2025", "2i" => "2", "3i" => "1" }).call

        expect(document_scope_spy).to have_received(:where_last_updated_after).with(Time.zone.local(2025, 2, 1))
      end

      it "applies ending date filter to end of day" do
        described_class.new(last_updated_to: { "1i" => "2026", "2i" => "4", "3i" => "3" }).call

        expect(document_scope_spy).to have_received(:where_last_updated_before).with(Time.zone.local(2026, 4, 3).end_of_day)
      end
    end

    context "when filtering by organisation" do
      let(:params) { { lead_organisation: "cd9316d5-93a9-4aa9-9698-c9112cf17639" } }

      it "delegates lead organisation filter to the query scope" do
        filter

        expect(document_scope_spy).to have_received(:where_lead_organisation).with("cd9316d5-93a9-4aa9-9698-c9112cf17639")
      end
    end

    context "when filtering by block type, keyword, organisation and last updated dates" do
      let(:keyword_relation) { instance_double(ActiveRecord::Relation) }
      let(:ids) { [1, 2, 3] }

      let(:params) do
        {
          block_type: %w[time_period],
          keyword: "ministry of example",
          lead_organisation: "cd9316d5-93a9-4aa9-9698-c9112cf17639",
          last_updated_from: { "1i" => "2025", "2i" => "2", "3i" => "1" },
          last_updated_to: { "1i" => "2026", "2i" => "4", "3i" => "3" },
        }
      end

      before do
        allow(V2::Document).to receive(:where_keyword).and_return(keyword_relation)
        allow(keyword_relation).to receive(:pluck).with(:id).and_return(ids)
      end

      it "applies all filters to the query" do
        filter

        expect(V2::Document).to have_received(:where_keyword).with("ministry of example")
        expect(document_scope_spy).to have_received(:where).with(id: ids)
        expect(document_scope_spy).to have_received(:where_block_type).with(%w[time_period])
        expect(document_scope_spy).to have_received(:where_lead_organisation).with("cd9316d5-93a9-4aa9-9698-c9112cf17639")
        expect(document_scope_spy).to have_received(:where_last_updated_after).with(Time.zone.local(2025, 2, 1))
        expect(document_scope_spy).to have_received(:where_last_updated_before).with(Time.zone.local(2026, 4, 3).end_of_day)
      end
    end

    describe "validations" do
      context "with lead organisation filter" do
        it "permits a nil value" do
          expect { described_class.new(lead_organisation: nil).call }.not_to raise_error
        end

        it "permits an empty string value" do
          expect { described_class.new(lead_organisation: "").call }.not_to raise_error
        end

        it "permits a valid UUID" do
          expect { described_class.new(lead_organisation: "d6b3028f-ea57-4cd2-878d-29b73089a3ae").call }.not_to raise_error
        end

        it "raises InvalidFiltersError for malformed string" do
          expect { described_class.new(lead_organisation: "HMRC").call }
            .to raise_error(described_class::InvalidFiltersError) do |error|
              expect(error.errors).to contain_exactly(
                have_attributes(
                  attribute: "lead_organisation",
                  full_message: I18n.t("document.index.errors.lead_organisation.invalid"),
                ),
              )
            end
        end
      end

      context "with date inputs" do
        %i[last_updated_from last_updated_to].each do |attribute|
          it "raises InvalidFiltersError when #{attribute} contains non-numeric strings" do
            invalid_params = { attribute => { "1i" => "ffff", "2i" => "ffsdfsd", "3i" => "ddddd" } }

            expect { described_class.new(invalid_params).call }
              .to raise_error(described_class::InvalidFiltersError) do |error|
                expect(error.errors).to contain_exactly(
                  have_attributes(
                    attribute: "#{attribute}_3i",
                    full_message: I18n.t("document.index.errors.date.invalid", attribute: attribute.to_s.humanize),
                  ),
                )
              end
          end

          it "raises InvalidFiltersError when #{attribute} missing required components" do
            invalid_params = { attribute => { "1i" => "2026", "2i" => "3", "3i" => "" } }

            expect { described_class.new(invalid_params).call }
              .to raise_error(described_class::InvalidFiltersError) do |error|
                expect(error.errors).to contain_exactly(
                  have_attributes(
                    attribute: "#{attribute}_3i",
                    full_message: I18n.t("document.index.errors.date.invalid", attribute: attribute.to_s.humanize),
                  ),
                )
              end
          end
        end

        it "raises InvalidFiltersError when start date is after end date" do
          invalid_range = {
            last_updated_from: { "1i" => "2026", "2i" => "2", "3i" => "3" },
            last_updated_to: { "1i" => "2025", "2i" => "1", "3i" => "1" },
          }

          expect { described_class.new(invalid_range).call }
            .to raise_error(described_class::InvalidFiltersError) do |error|
              expect(error.errors).to contain_exactly(
                have_attributes(
                  attribute: "last_updated_from_3i",
                  full_message: I18n.t("document.index.errors.date.range.invalid"),
                ),
              )
            end
        end
      end
    end
  end
end
