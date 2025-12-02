RSpec.describe DestroyEditionService do
  describe "#call" do
    let(:document) { create(:document, :pension) }
    let!(:draft_edition) { create(:edition, :pension, document:, state: :draft) }

    describe "when there is only one draft edition on a document" do
      it "deletes the draft edition and its document" do
        expect {
          DestroyEditionService.new.call(draft_edition)
        }.to change { Document.count }.by(-1)
         .and change { Edition.count }.by(-1)
      end
    end

    describe "when the edition is not a draft" do
      let!(:scheduled_edition) { create(:edition, :pension, document:, state: :published) }

      it "does not delete the document" do
        expect {
          expect { DestroyEditionService.new.call(scheduled_edition) }.to raise_error(ArgumentError)
        }.not_to(change { Document.count })
      end

      it "does not delete the edition" do
        expect {
          expect { DestroyEditionService.new.call(scheduled_edition) }.to raise_error(ArgumentError)
        }.not_to(change { Edition.count })
      end
    end

    describe "when there is more than one draft edition on a document" do
      let!(:other_edition) { create(:edition, :pension, document:, state: :draft) }

      it "does not delete the document" do
        expect {
          DestroyEditionService.new.call(draft_edition)
        }.not_to(change { Document.count })
      end

      it "does not delete the other draft edition" do
        expect {
          DestroyEditionService.new.call(draft_edition)
        }.not_to(change { Edition.exists?(other_edition.id) })
      end

      it "deletes the given edition" do
        expect {
          DestroyEditionService.new.call(draft_edition)
        }.to(change { Edition.exists?(draft_edition.id) })
      end
    end
  end
end
