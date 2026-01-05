RSpec.describe Edition::WorkflowCompletion do
  let(:organisation) { build(:organisation) }
  let(:schema) { build(:schema, block_type: "content_block_type", body: { "properties" => { "foo" => "", "bar" => "" } }) }
  let(:document) { create(:document, :pension, id: 567) }
  let(:edition) do
    create(:edition,
           id: 123,
           document: document,
           lead_organisation_id: organisation.id)
  end
  let(:published_edition) do
    create(:edition,
           id: 456,
           document: document,
           state: "published",
           lead_organisation_id: organisation.id)
  end

  before do
    allow(Schema).to receive(:find_by_block_type).and_return(schema)
    allow(Organisation).to receive(:all).and_return([organisation])
    allow(Services.publishing_api).to receive(:put_content)
    allow(Services.publishing_api).to receive(:publish)
    allow(edition).to receive(:update_column)
    allow(published_edition).to receive(:update_column)
  end

  describe "#call" do
    describe "when called with invalid save_actions" do
      it "should raise an error" do
        aggregate_failures do
          expect { described_class.new(edition, "foobar").call }.to raise_error(described_class::UnhandledSaveActionError)
          expect { described_class.new(edition, "").call }.to raise_error(described_class::UnhandledSaveActionError)
        end
      end

      it "should NOT mark the edition as 'completed'" do
        described_class.new(edition, "foobar").call
      rescue Edition::WorkflowCompletion::UnhandledSaveActionError
        expect(edition).not_to have_received(:update_column)
      end
    end

    describe "when the save_action is 'publish'" do
      describe "when the edition has not yet been published" do
        let(:service) { double(PublishEditionService) }

        it "should call the PublishEditionService with the Edition" do
          allow(PublishEditionService).to receive(:new).and_return(service)
          allow(service).to receive(:call).and_return(edition)

          described_class.new(edition, "publish").call

          expect(service).to have_received(:call).with(edition)
        end

        it "should return the edition's confirmation page path to redirect to" do
          described_class.new(edition, "publish").call => { path: }
          expect(path).to eq("/editions/123/workflow/confirmation")
        end

        it "should mark the edition as 'completed'" do
          described_class.new(edition, "publish").call

          expect(edition).to have_received(:update_column).with(
            :workflow_completed_at,
            Time.current,
          )
        end
      end
    end

    describe "when the save_action is 'publish'" do
      describe "when the edition has already been published" do
        let(:service) { double(PublishEditionService) }

        it "should not call the PublishEditionService with the Edition" do
          allow(PublishEditionService).to receive(:new).and_return(service)
          allow(service).to receive(:call).and_return(published_edition)

          described_class.new(published_edition, "publish").call

          expect(service).not_to have_received(:call).with(published_edition)
        end

        it "should return the edition's confirmation page path to redirect to" do
          described_class.new(published_edition, "publish").call => { path: }
          expect(path).to eq("/editions/456/workflow/confirmation")
        end

        it "should NOT mark the edition as 'completed' for a second time" do
          allow(published_edition).to receive(:completed?).and_return(true)

          described_class.new(published_edition, "publish").call

          expect(published_edition).not_to have_received(:update_column)
        end
      end
    end

    describe "when the save_action is 'schedule'" do
      let(:service) { double(ScheduleEditionService) }

      it "should call the ScheduleEditionService with the Edition" do
        allow(ScheduleEditionService).to receive(:new).and_return(service)
        allow(service).to receive(:call).and_return(edition)

        described_class.new(edition, "schedule").call

        expect(service).to have_received(:call).with(edition)
      end

      it "should return the edition's confirmation page path to redirect to" do
        described_class.new(edition, "publish").call => { path: }
        expect(path).to eq("/editions/123/workflow/confirmation")
      end

      it "should mark the edition as 'completed'" do
        described_class.new(edition, "publish").call

        expect(edition).to have_received(:update_column).with(
          :workflow_completed_at,
          Time.current,
        )
      end
    end

    describe "when the save_action is 'save_as_draft'" do
      it "attempts to transition the edition with Edition#complete_draft!" do
        allow(edition).to receive(:complete_draft!).and_return(true)

        described_class.new(edition, "save_as_draft").call

        expect(edition).to have_received(:complete_draft!)
      end

      it "should return the document's view page path to redirect to" do
        described_class.new(edition, "save_as_draft").call => { path: }
        expect(path).to eq("/567")
      end

      it "should set a success message to the 'flash'" do
        return_value = described_class.new(edition, "save_as_draft").call

        expect(return_value.fetch(:flash)).to eq(
          {
            notice: I18n.t("edition.confirmation_page.drafted.banner"),
          },
        )
      end

      it "should mark the edition as 'completed'" do
        described_class.new(edition, "publish").call

        expect(edition).to have_received(:update_column).with(
          :workflow_completed_at,
          Time.current,
        )
      end
    end
  end

  describe "when the save_action is 'send_to_review'" do
    it "attempts to transition the edition with Edition#complete_draft!" do
      allow(edition).to receive(:complete_draft!).and_return(true)
      allow(edition).to receive(:ready_for_review!).and_return(true)

      described_class.new(edition, "send_to_review").call

      expect(edition).to have_received(:complete_draft!)
    end

    it "attempts to transition the edition with Edition#ready_for_review!" do
      allow(edition).to receive(:ready_for_review!).and_return(true)

      described_class.new(edition, "send_to_review").call

      expect(edition).to have_received(:ready_for_review!)
    end

    it "should mark the edition as 'completed'" do
      described_class.new(edition, "publish").call

      expect(edition).to have_received(:update_column).with(
        :workflow_completed_at,
        Time.current,
      )
    end

    context "when the transition Edition#ready_for_review! is valid" do
      before { allow(edition).to receive(:ready_for_review!).and_return(true) }

      it "returns :path -> document" do
        return_value = described_class.new(edition, "send_to_review").call

        expect(return_value.fetch(:path)).to eq("/567")
      end

      it "returns :flash -> notice of success" do
        return_value = described_class.new(edition, "send_to_review").call

        expect(return_value.fetch(:flash)).to eq(
          {
            notice: I18n.t("edition.states.transition_message.awaiting_review"),
          },
        )
      end
    end

    context "when the transition Edition#ready_for_review! is NOT valid" do
      let(:error_message) do
        "Can't fire event `ready_for_review` in current state `published` " \
          "for `Edition` with ID 123  (Transitions::InvalidTransition)"
      end

      before do
        allow(edition).to receive(:ready_for_review!).and_raise(
          Transitions::InvalidTransition,
          error_message,
        )
      end

      it "should mark the edition as 'completed'" do
        described_class.new(edition, "publish").call

        expect(edition).to have_received(:update_column).with(
          :workflow_completed_at,
          Time.current,
        )
      end

      it "returns :path -> document" do
        return_value = described_class.new(edition, "send_to_review").call

        expect(return_value.fetch(:path)).to eq("/567")
      end

      it "returns :flash -> error message" do
        return_value = described_class.new(edition, "send_to_review").call

        expect(return_value.fetch(:flash)).to eq(
          {
            error: error_message,
          },
        )
      end
    end
  end
end
