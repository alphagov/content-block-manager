RSpec.describe Document::DocumentFilter do
  let(:user) { create(:user) }
  let(:is_e2e_user) { false }
  let(:valid_schemas) do
    [
      build(:schema, :pension),
      build(:schema, :contact),
    ]
  end

  let(:filter) { Document::DocumentFilter.new(valid_schemas:) }

  before do
    allow(user).to receive(:is_e2e_user?).and_return(is_e2e_user)
    allow(Current).to receive(:user).and_return(user)
  end

  describe "paginated_documents" do
    let(:document_scope_spy) { spy }

    before do
      allow(Document).to receive(:where)
              .with(block_type: valid_schemas.map(&:block_type))
              .and_return(document_scope_spy)
    end

    describe "when a user is not an e2e user" do
      it "only returns non-testing artefacts" do
        filter.call({})

        expect(document_scope_spy).to have_received(:where).with(testing_artefact: false)
      end

      describe "when no filters are given" do
        it "returns live documents" do
          allow(Document).to receive(:with_keyword)

          filter.call({})

          expect(Document).to_not have_received(:with_keyword)
          expect(document_scope_spy).to_not have_received(:where).with(id: anything)
          expect(document_scope_spy).to_not have_received(:with_lead_organisation)
        end

        it "filters out inactive editions" do
          filter.call({})

          expect(document_scope_spy).to have_received(:merge).with(Edition.active)
        end
      end

      describe "when a keyword filter is given" do
        let(:keyword_spy) { spy }
        let(:keyword) { "ministry of example" }
        let(:ids) { [1, 2, 3] }

        before do
          allow(Document).to receive(:with_keyword).and_return(keyword_spy)
          allow(keyword_spy).to receive(:pluck).with(:id).and_return(ids)
        end

        it "returns live documents with keyword" do
          filter.call({ keyword: })

          expect(Document).to have_received(:with_keyword).with(keyword)
          expect(document_scope_spy).to have_received(:where).with(id: ids)
          expect(document_scope_spy).to have_received(:page).with(1)
        end

        describe "when a keyword is an embed code with an attribute reference" do
          let(:keyword) { "{{embed:content_block_pension:basic-state-pension/rates/full-basic-state-pension-amount/amount}}" }

          it "searches with the attribute reference stripped from the embed code" do
            filter.call({ keyword: })

            expect(Document).to have_received(:with_keyword).with("{{embed:content_block_pension:basic-state-pension}}")
            expect(document_scope_spy).to have_received(:where).with(id: ids)
            expect(document_scope_spy).to have_received(:page).with(1)
          end
        end

        describe "when a keyword is an embed code without an attribute reference" do
          let(:keyword) { "{{embed:content_block_pension:basic-state-pension}}" }

          it "searches with the embed code intact" do
            filter.call({ keyword: })

            expect(Document).to have_received(:with_keyword).with(keyword)
            expect(document_scope_spy).to have_received(:where).with(id: ids)
            expect(document_scope_spy).to have_received(:page).with(1)
          end
        end
      end

      describe "when a block type is given" do
        it "returns live documents of the type given" do
          filter.call({ block_type: %w[email_address] })

          expect(document_scope_spy).to have_received(:where).with(block_type: %w[email_address])
        end
      end

      describe "when a lead organisation id is given" do
        it "returns live documents with lead org given" do
          filter.call({ lead_organisation: "123" })

          expect(document_scope_spy).to have_received(:with_lead_organisation).with("123")
        end
      end

      describe "when block types, keyword and organisation is given" do
        let(:keyword_spy) { spy }
        let(:keyword) { "ministry of example" }
        let(:ids) { [1, 2, 3] }

        before do
          allow(Document).to receive(:with_keyword).and_return(keyword_spy)
          allow(keyword_spy).to receive(:pluck).with(:id).and_return(ids)
        end

        it "returns live documents with the filters given" do
          filter.call(
            { block_type: %w[email_address], keyword: "ministry of example", lead_organisation: "123" },
          )

          expect(document_scope_spy).to have_received(:where).with(id: ids)
          expect(document_scope_spy).to have_received(:where).with(block_type: %w[email_address])
          expect(document_scope_spy).to have_received(:with_lead_organisation).with("123")
        end
      end

      describe "when a page is given" do
        it "passes the page to the query" do
          filter.call({ page: 2 })

          expect(document_scope_spy).to have_received(:page).with(2)
        end
      end

      describe "last updated dates" do
        describe "when dates are valid" do
          it "filters using last updated from date" do
            expected_date_time = Time.zone.local(2025, 2, 1)

            filter.call(
              {
                last_updated_from: { "3i" => "1", "2i" => "2", "1i" => "2025" },
              },
            )

            expect(document_scope_spy).to have_received(:last_updated_after).with(expected_date_time)
          end

          it "filters using last updated to date" do
            expected_date_time = Time.zone.local(2026, 4, 3).end_of_day

            filter.call(
              {
                last_updated_to: { "3i" => "3", "2i" => "4", "1i" => "2026" },
              },
            )

            expect(document_scope_spy).to have_received(:last_updated_before).with(expected_date_time)
          end
        end
      end
    end

    describe "when a user is an e2e user" do
      let(:is_e2e_user) { true }

      it "does not filter by testing_artefact" do
        filter.call({})

        expect(document_scope_spy).to_not have_received(:where).with(testing_artefact: false)
      end
    end

    describe "date validation" do
      %i[last_updated_from last_updated_to].each do |attribute|
        describe "when #{attribute} contains non-date values" do
          let(:filters) do
            {
              "#{attribute}": { "3i" => "ddddd", "2i" => "ffsdfsd", "1i" => "ffff" },
            }
          end

          it "raises an error" do
            expect { filter.call(filters) }.to raise_error(Document::DocumentFilter::InvalidFiltersError)
          end

          it "returns errors" do
            filter.call(filters)
          rescue Document::DocumentFilter::InvalidFiltersError => e
            errors = e.errors
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

          it "raises an error" do
            expect { filter.call(filters) }.to raise_error(Document::DocumentFilter::InvalidFiltersError)
          end

          it "returns errors" do
            filter.call(filters)
          rescue Document::DocumentFilter::InvalidFiltersError => e
            errors = e.errors
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

        it "raises an error" do
          expect { filter.call(filters) }.to raise_error(Document::DocumentFilter::InvalidFiltersError)
        end

        it "returns errors" do
          filter.call(filters)
        rescue Document::DocumentFilter::InvalidFiltersError => e
          errors = e.errors
          expect(errors.count).to eq(1)
          expect(errors.first.attribute).to eq("last_updated_from")
          expect(errors.first.full_message).to eq(I18n.t("document.index.errors.date.range.invalid"))
        end
      end
    end
  end
end
