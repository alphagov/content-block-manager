RSpec.describe Edition do
  describe ".most_recent_for_document" do
    let(:document) { create(:document) }

    before do
      create(:edition, document: document, updated_at: Time.zone.now - 2.weeks, state: :published)
      create(:edition, document: document, updated_at: Time.zone.now - 12.days, state: :published)
      create(:edition, document: document, updated_at: Time.zone.now - 7.days, state: :published)
    end

    describe "with active states" do
      Edition.active_states.each do |state|
        context "when the most recent edition is #{state}" do
          let!(:most_recent_edition) { create(:edition, state, document: document, updated_at: Time.zone.now - 1.day) }

          it "returns the #{state} edition" do
            expect(Edition.most_recent_for_document).to eq([most_recent_edition])
          end
        end
      end
    end

    describe "with inactive states" do
      Edition.inactive_states.each do |state|
        context "when the most recent edition is #{state}" do
          let!(:most_recent_edition) { create(:edition, state, document: document, updated_at: Time.zone.now - 1.day) }

          Edition.active_states.each do |active_state|
            context "when the most recent active edition is #{active_state}" do
              let!(:most_recent_active_edition) { create(:edition, active_state, document: document, updated_at: Time.zone.now - 2.days) }

              it "returns the #{active_state} edition" do
                expect(Edition.most_recent_for_document).to eq([most_recent_active_edition])
              end
            end
          end
        end
      end
    end
  end
end
