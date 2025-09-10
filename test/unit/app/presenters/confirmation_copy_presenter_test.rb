require "test_helper"

class ConfirmationCopyPresenterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:edition) { build(:edition, :pension) }
  let(:block_type) { edition.block_type.humanize }

  let(:presenter) { ConfirmationCopyPresenter.new(edition) }

  context "when the content block is scheduled" do
    let(:edition) { build(:edition, :pension, scheduled_publication: Time.zone.now, state: :scheduled) }

    describe "#for_panel" do
      it "should return the scheduled text" do
        assert_equal "#{block_type} scheduled to publish on #{I18n.l(edition.scheduled_publication, format: :long_ordinal)}", presenter.for_panel
      end
    end

    describe "#for_paragraph" do
      it "should return the scheduled text" do
        assert_equal "You can now view the updated schedule of the content block.", presenter.for_paragraph
      end
    end
  end

  context "when there is more than one edition for the underlying document" do
    let(:document) { edition.document }

    before do
      document.expects(:editions).returns(
        build_list(:edition, 3, :pension),
      )
    end

    describe "#for_panel" do
      it "should return the published text" do
        assert_equal "#{block_type} published", presenter.for_panel
      end
    end

    describe "#for_paragraph" do
      it "should return the published text" do
        assert_equal "You can now view the updated content block.", presenter.for_paragraph
      end
    end
  end

  context "when there is only one edition for the underlying document" do
    describe "#for_panel" do
      it "should return the created text" do
        assert_equal "#{block_type} created", presenter.for_panel
      end
    end

    describe "#for_paragraph" do
      it "should return the created text" do
        assert_equal "You can now view the content block.", presenter.for_paragraph
      end
    end
  end
end
