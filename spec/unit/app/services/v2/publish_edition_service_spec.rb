RSpec.describe V2::PublishEditionService do
  describe "#call" do
    let(:content_id) { "49453854-d8fd-41da-ad4c-f99dbac601c3" }
    let(:document) { create(:v2_document, content_id:, sluggable_string: "some-edition-title") }
    let(:organisation) { build(:organisation) }
    let(:edition) do
      create(
        :v2_time_period_edition,
        document:,
        description: "Foo text",
        date_range: build(:v2_time_period_date_range),
        lead_organisation_id: organisation.id,
        instructions_to_publishers: "instructions",
        title: "Some Edition Title",
      )
    end

    before do
      allow(V2::DomainEvent).to receive(:record)
      allow(V2::Version).to receive(:increment_for_edition)
      allow(Organisation).to receive(:all).and_return([organisation])
      allow(Public::Services.publishing_api).to receive(:put_content)
      allow(Public::Services.publishing_api).to receive(:publish)
      allow(Public::Services.publishing_api).to receive(:discard_draft)
    end

    context "when publishing is successful" do
      it "returns a V2 Edition" do
        result = V2::PublishEditionService.new.call(edition)

        expect(result).to be_a(V2::Edition)
      end

      it "publishes the Edition" do
        expect(SchedulePublishingWorker).to receive(:dequeue).never

        V2::PublishEditionService.new.call(edition)
        expect(edition.state).to eq("published")
      end

      it "creates an Edition in the Publishing API" do
        presenter_stub = double(PublishingApi::V2ContentBlockPresenter)
        presented_hash = double(hash: {})
        expect(PublishingApi::V2ContentBlockPresenter).to receive(:new)
                                                    .with(
                                                      document_type: "content_block_#{document.block_type}",
                                                      content_id_alias: "some-edition-title",
                                                      edition: edition,
                                                    )
                                                    .and_return(presenter_stub)
        expect(presenter_stub).to receive(:present).and_return(presented_hash)

        expect(Public::Services.publishing_api).to receive(:put_content).with(content_id, presented_hash)

        expect(Public::Services.publishing_api).to receive(:publish).with(content_id)

        V2::PublishEditionService.new.call(edition)

        expect(edition.state).to eq("published")
      end

      it "executes the process within an ActiveRecord transaction" do
        expect(ActiveRecord::Base).to receive(:transaction).and_call_original

        V2::PublishEditionService.new.call(edition)
      end
    end

    context "when the Publishing API request fails" do
      let(:gds_api_error) { GdsApi::BaseError.new("An internal error message") }

      context "when put_content fails" do
        before do
          allow(Public::Services.publishing_api).to receive(:put_content).and_raise(gds_api_error)
        end

        it "raises a PublishingFailureError" do
          expect { V2::PublishEditionService.new.call(edition) }
            .to raise_error(V2::PublishEditionService::PublishingFailureError, "Could not publish #{content_id} because: An internal error message")
        end

        it "discards the latest draft" do
          expect(Public::Services.publishing_api).to receive(:discard_draft).with(content_id)

          expect { V2::PublishEditionService.new.call(edition) }
            .to raise_error(V2::PublishEditionService::PublishingFailureError)
        end
      end

      context "when publish fails" do
        before do
          allow(Public::Services.publishing_api).to receive(:put_content)
          allow(Public::Services.publishing_api).to receive(:publish).and_raise(gds_api_error)
        end

        it "raises a PublishingFailureError" do
          expect { V2::PublishEditionService.new.call(edition) }
            .to raise_error(V2::PublishEditionService::PublishingFailureError, "Could not publish #{content_id} because: An internal error message")
        end

        it "discards the latest draft" do
          expect(Public::Services.publishing_api).to receive(:discard_draft).with(content_id)

          expect { V2::PublishEditionService.new.call(edition) }
            .to raise_error(V2::PublishEditionService::PublishingFailureError)
        end

        it "rolls back the database transaction and leaves the edition in a draft state" do
          expect(edition.state).to eq("draft")

          expect { V2::PublishEditionService.new.call(edition) }
            .to raise_error(V2::PublishEditionService::PublishingFailureError)

          expect(edition.state).to eq("draft")
        end
      end

      context "when discarding the draft fails during error recovery" do
        let(:discard_error) { GdsApi::BaseError.new("Discard draft failed") }

        before do
          allow(Public::Services.publishing_api).to receive(:publish).and_raise(gds_api_error)
          allow(Public::Services.publishing_api).to receive(:discard_draft).and_raise(discard_error)
        end

        it "notifies GovukError of the failure to discard" do
          expect(GovukError).to receive(:notify).with(
            discard_error,
            extra: { edition_id: edition.id, document_id: edition.document.id },
            level: :warn,
          )

          expect { V2::PublishEditionService.new.call(edition) }
            .to raise_error(V2::PublishEditionService::PublishingFailureError)
        end

        it "still raises the original PublishingFailureError" do
          expect { V2::PublishEditionService.new.call(edition) }
            .to raise_error(V2::PublishEditionService::PublishingFailureError, "Could not publish #{content_id} because: An internal error message")
        end
      end
    end
  end
end
