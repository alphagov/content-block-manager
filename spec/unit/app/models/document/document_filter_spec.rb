RSpec.describe Document::DocumentFilter do
  let(:user) { create(:user) }
  let(:is_e2e_user) { false }

  before do
    allow(user).to receive(:is_e2e_user?).and_return(is_e2e_user)
    allow(Current).to receive(:user).and_return(user)
  end
  describe "paginated_documents" do
    let(:document_scope_mock) { double }

    before do
      allow(Document).to receive(:where)
              .with(block_type: Schema.valid_schemas)
              .and_return(document_scope_mock)
      allow(document_scope_mock).to receive(:live).and_return(document_scope_mock)
      allow(document_scope_mock).to receive(:joins).with(:latest_edition).and_return(document_scope_mock)
      allow(document_scope_mock).to receive(:order).with("editions.updated_at DESC").and_return(document_scope_mock)
      allow(document_scope_mock).to receive(:per).with(Document::DocumentFilter::DEFAULT_PAGE_SIZE).and_return([])
    end

    describe "when a user is not an e2e user" do
      before do
        allow(document_scope_mock)
          .to receive(:where)
          .with(testing_artefact: false)
          .and_return(document_scope_mock)
      end

      describe "when no filters are given" do
        it "returns live documents" do
          expect(document_scope_mock).to receive(:page).with(1).and_return(document_scope_mock)

          expect(document_scope_mock).to receive(:with_keyword).never
          expect(document_scope_mock).to receive(:where).with(id: anything).never
          expect(document_scope_mock).to receive(:with_lead_organisation).never

          Document::DocumentFilter.new({}).paginated_documents
        end
      end

      describe "when a keyword filter is given" do
        it "returns live documents with keyword" do
          ids = [1, 2, 3]
          keyword_stub = double
          allow(Document).to receive(:with_keyword)
                  .with("ministry of example")
                  .and_return(keyword_stub)
          allow(keyword_stub).to receive(:pluck).with(:id).and_return(ids)

          expect(document_scope_mock).to receive(:page).with(1).and_return(document_scope_mock)

          expect(document_scope_mock).to receive(:where).with(id: ids).and_return(document_scope_mock)
          Document::DocumentFilter.new({ keyword: "ministry of example" }).paginated_documents
        end
      end

      describe "when a block type is given" do
        it "returns live documents of the type given" do
          allow(document_scope_mock).to receive(:page).with(1).and_return(document_scope_mock)

          expect(document_scope_mock).to receive(:where).with(block_type: %w[email_address]).and_return(document_scope_mock)
          Document::DocumentFilter.new({ block_type: %w[email_address] }).paginated_documents
        end
      end

      describe "when a lead organisation id is given" do
        it "returns live documents with lead org given" do
          allow(document_scope_mock).to receive(:page).with(1).and_return(document_scope_mock)

          expect(document_scope_mock).to receive(:with_lead_organisation).with("123").and_return(document_scope_mock)
          Document::DocumentFilter.new({ lead_organisation: "123" }).paginated_documents
        end
      end

      describe "when block types, keyword and organisation is given" do
        it "returns live documents with the filters given" do
          allow(document_scope_mock).to receive(:page).with(1).and_return(document_scope_mock)

          ids = [1, 2, 3]
          keyword_stub = double
          allow(Document).to receive(:with_keyword)
                  .with("ministry of example")
                  .and_return(keyword_stub)
          allow(keyword_stub).to receive(:pluck).with(:id).and_return(ids)

          expect(document_scope_mock).to receive(:where).with(id: ids).and_return(document_scope_mock)
          expect(document_scope_mock).to receive(:where).with(block_type: %w[email_address]).and_return(document_scope_mock)
          expect(document_scope_mock).to receive(:with_lead_organisation).with("123").and_return(document_scope_mock)
          Document::DocumentFilter.new(
            { block_type: %w[email_address], keyword: "ministry of example", lead_organisation: "123" },
          ).paginated_documents
        end
      end

      describe "when a page is given" do
        it "passes the page to the query" do
          expect(document_scope_mock).to receive(:page).with(2).and_return(document_scope_mock)
          Document::DocumentFilter.new({ page: 2 }).paginated_documents
        end
      end

      describe "last updated dates" do
        describe "when dates are missing" do
          it "does not filter by date if one or more date element is missing" do
            expect(document_scope_mock).to receive(:page).with(1).and_return(document_scope_mock)

            Document::DocumentFilter.new(
              {
                last_updated_from: { "3i" => "", "2i" => "2", "1i" => "2025" },
                last_updated_to: { "3i" => "", "2i" => "", "1i" => ""  },
              },
            ).paginated_documents
          end
        end

        describe "when dates are valid" do
          it "filters using last updated from date" do
            allow(document_scope_mock).to receive(:page).with(1).and_return(document_scope_mock)

            expected_date_time = Time.zone.local(2025, 2, 1)

            expect(document_scope_mock).to receive(:last_updated_after).with(expected_date_time).and_return(document_scope_mock)
            Document::DocumentFilter.new(
              {
                last_updated_from: { "3i" => "1", "2i" => "2", "1i" => "2025" },
              },
            ).paginated_documents
          end

          it "filters using last updated to date" do
            allow(document_scope_mock).to receive(:page).with(1).and_return(document_scope_mock)

            expected_date_time = Time.zone.local(2026, 4, 3).end_of_day

            expect(document_scope_mock).to receive(:last_updated_before).with(expected_date_time).and_return(document_scope_mock)
            Document::DocumentFilter.new(
              {
                last_updated_to: { "3i" => "3", "2i" => "4", "1i" => "2026" },
              },
            ).paginated_documents
          end
        end
      end
    end

    describe "when a user is an e2e user" do
      let(:is_e2e_user) { true }

      it "does not filter by testing_artefact" do
        allow(document_scope_mock).to receive(:page).with(1).and_return(document_scope_mock)

        expect(document_scope_mock)
          .to receive(:where)
          .with(testing_artefact: false)
          .never

        Document::DocumentFilter.new({}).paginated_documents
      end
    end

    describe "date validation" do
      let(:document_filter) { Document::DocumentFilter.new(filters) }

      %i[last_updated_from last_updated_to].each do |attribute|
        describe "when #{attribute} contains non-date values" do
          let(:filters) do
            {
              "#{attribute}": { "3i" => "ddddd", "2i" => "ffsdfsd", "1i" => "ffff" },
            }
          end

          it "returns invalid" do
            expect(document_filter.valid?).to be false
          end

          it "returns errors" do
            errors = document_filter.errors
            expect(errors.count).to eq(1)
            expect(errors.first.attribute).to eq(attribute.to_s)
            expect(errors.first.full_message).to eq(I18n.t("document.index.errors.date.invalid", attribute: attribute.to_s.humanize))
          end
        end

        describe "when #{attribute} contains has missing values" do
          let(:filters) do
            {
              "#{attribute}": { "3i" => "", "2i" => "3", "1i" => "2026" },
            }
          end

          it "returns invalid" do
            expect(document_filter.valid?).to be false
          end

          it "returns errors" do
            errors = document_filter.errors
            expect(errors.count).to eq(1)
            expect(errors.first.attribute).to eq(attribute.to_s)
            expect(errors.first.full_message).to eq(I18n.t("document.index.errors.date.invalid", attribute: attribute.to_s.humanize))
          end
        end
      end

      describe "when last_updated_from is after last_updated_to" do
        let(:filters) do
          {
            last_updated_from: { "3i" => "3", "2i" => "2", "1i" => "2026" },
            last_updated_to: { "3i" => "1", "2i" => "1", "1i" => "2025" },
          }
        end

        it "returns invalid" do
          expect(document_filter.valid?).to be false
        end

        it "returns errors" do
          errors = document_filter.errors
          expect(errors.count).to eq(1)
          expect(errors.first.attribute).to eq("last_updated_from")
          expect(errors.first.full_message).to eq(I18n.t("document.index.errors.date.range.invalid"))
        end
      end
    end
  end
end
