RSpec.describe Edition::WorkflowCompletion do
  let(:organisation) { build(:organisation) }
  let(:schema) { build(:schema, block_type: "content_block_type", body: { "properties" => { "foo" => "", "bar" => "" } }) }
  let(:document) { create(:document, :pension, id: 567) }
  let(:edition) do
    build(:edition,
          id: 123,
          document: document,
          lead_organisation_id: organisation.id)
  end

  before do
    allow(Schema).to receive(:find_by_block_type).and_return(schema)
    allow(Organisation).to receive(:all).and_return([organisation])
    allow(Services.publishing_api).to receive(:put_content)
    allow(Services.publishing_api).to receive(:publish)
  end

  describe "#call" do
    describe "when called with invalid save_actions" do
      it "should raise an error" do
        aggregate_failures do
          expect { described_class.new(edition, "foobar").call }.to raise_error(described_class::UnhandledSaveActionError)
          expect { described_class.new(edition, "").call }.to raise_error(described_class::UnhandledSaveActionError)
        end
      end
    end

    describe "when the save_action is 'publish'" do
      let(:service) { double(PublishEditionService) }

      it "should call the PublishEditionService with the Edition" do
        allow(PublishEditionService).to receive(:new).and_return(service)
        allow(service).to receive(:call).and_return(edition)

        described_class.new(edition, "publish").call

        expect(service).to have_received(:call).with(edition)
      end

      it "should return the edition's confirmation page path to redirect to" do
        path = described_class.new(edition, "publish").call
        expect(path).to eq("/editions/123/workflow/confirmation")
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
        path = described_class.new(edition, "publish").call
        expect(path).to eq("/editions/123/workflow/confirmation")
      end
    end

    describe "when the save_action is 'save_as_draft'" do
      it "should return the document's view page path to redirect to" do
        path = described_class.new(edition, "save_as_draft").call
        expect(path).to eq("/567")
      end
    end
  end
end
