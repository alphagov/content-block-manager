RSpec.describe ConfirmationCopyPresenter do
  let(:edition) { build(:edition, :pension) }
  let(:block_type) { edition.block_type.humanize }

  let(:presenter) { ConfirmationCopyPresenter.new(edition) }

  context "when the content block is scheduled" do
    let(:edition) { build(:edition, :pension, scheduled_publication: Time.zone.now, state: :scheduled) }

    describe "#for_panel" do
      it "should return the scheduled text" do
        expect(presenter.for_panel).to eq("#{block_type} scheduled to publish on #{I18n.l(edition.scheduled_publication, format: :long_ordinal)}")
      end
    end

    describe "#for_paragraph" do
      it "should return the scheduled text" do
        expect(presenter.for_paragraph).to eq("You can now view the updated schedule of the content block.")
      end
    end
  end

  context "when there is more than one edition for the underlying document" do
    let(:document) { edition.document }

    before do
      expect(document).to receive(:editions).and_return(
        build_list(:edition, 3, :pension),
      )
    end

    describe "#for_panel" do
      it "should return the published text" do
        expect(presenter.for_panel).to eq("#{block_type} published")
      end
    end

    describe "#for_paragraph" do
      it "should return the published text" do
        expect(presenter.for_paragraph).to eq("You can now view the updated content block.")
      end
    end
  end

  context "when there is only one edition for the underlying document" do
    describe "#for_panel" do
      it "should return the created text" do
        expect(presenter.for_panel).to eq("#{block_type} created")
      end
    end

    describe "#for_paragraph" do
      it "should return the created text" do
        expect(presenter.for_paragraph).to eq("You can now view the content block.")
      end
    end
  end
end
