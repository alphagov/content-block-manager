require "test_helper"

class DeleteEditionServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#call" do
    let(:document) { create(:document, :pension) }
    let!(:draft_edition) { create(:edition, :pension, document:, state: :draft) }

    describe "when there is only one draft edition on a document" do
      it "deletes the draft edition and its document" do
        assert_changes -> { Document.count }, from: 1, to: 0 do
          assert_changes -> { Edition.count }, from: 1, to: 0 do
            DeleteEditionService.new.call(draft_edition)
          end
        end
      end
    end

    describe "when the edition is not a draft" do
      let!(:scheduled_edition) { create(:edition, :pension, document:, state: :published) }

      it "does not delete the edition or document" do
        assert_no_changes -> { Document.count } do
          assert_no_changes -> { Edition.count } do
            assert_raises(ArgumentError) do
              DeleteEditionService.new.call(scheduled_edition)
            end
          end
        end
      end
    end

    describe "when there is more than one draft edition on a document" do
      let!(:other_edition) { create(:edition, :pension, document:, state: :draft) }

      it "only deletes the given edition" do
        assert_no_changes -> { Document.count } do
          assert_no_changes -> { Edition.exists?(other_edition.id) } do
            assert_changes -> { Edition.exists?(draft_edition.id) }, from: true, to: false do
              DeleteEditionService.new.call(draft_edition)
            end
          end
        end
      end
    end
  end
end
