RSpec.describe Document::Show::DocumentTimeline::TimelineItemComponent, type: :component do
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper

  let(:user) { create(:user) }
  let(:schema) { double(:schema, subschemas: []) }

  let(:edition) do
    build(:edition,
          :pension,
          change_note: nil,
          internal_change_note: nil,
          review_outcome: ReviewOutcome.new,
          fact_check_outcome: FactCheckOutcome.new)
  end

  let(:version) do
    build(
      :content_block_version,
      event: "created",
      whodunnit: user.id,
      state: "published",
      created_at: 4.days.ago,
      item: edition,
    )
  end

  let(:is_latest) { false }
  let(:is_first_published_version) { false }

  let(:table_stub) { double("table_component") }

  let(:component) do
    described_class.new(
      version:,
      schema:,
      is_first_published_version:,
      is_latest:,
    )
  end

  describe "when not the latest or first published" do
    before do
      render_inline component
    end

    it "renders a timeline item component" do
      expect(page).to have_css ".timeline__title", text: "Published"
      page.find ".timeline__byline" do |byline|
        assert_includes byline.native.to_s, "by #{linked_author(user, { class: 'govuk-link' })}"
      end
      expect(page).to have_css "time[datetime='#{version.created_at.iso8601}']", text: version.created_at.to_fs(:long_ordinal_with_at)
    end

    it "does not show the latest tag" do
      expect(page).to_not have_css ".timeline__latest", text: "Latest"
    end

    it "does not show the table component" do
      expect(page).to_not have_css ".timeline__diff-table"
    end
  end

  describe "when the version is the first published version" do
    let(:is_latest) { false }
    let(:is_first_published_version) { true }

    before do
      render_inline component
    end

    it "returns a created title" do
      expect(page).to have_css(
        ".timeline__title",
        text: I18n.t("timeline_item.title.published", block_type: "Pension"),
      )
    end

    context "and its edition indicates that the review was performed" do
      before do
        edition.fact_check_outcome.skipped = false
      end

      it "shows the review outcome" do
        render_inline component

        expect(page).to have_css(".timeline__review-outcome") do
          expect(page).to have_content("Fact check performed")
        end
      end
    end

    context "and its edition indicates that the review was skipped" do
      before do
        edition.fact_check_outcome.skipped = true
      end

      it "shows the review outcome" do
        render_inline component

        expect(page).to have_css(".timeline__review-outcome") do
          expect(page).to have_content("Fact check skipped")
        end
      end
    end
  end

  describe "when the version is the latest version" do
    let(:is_latest) { true }
    let(:is_first_published_version) { false }

    before do
      render_inline component
    end

    it "shows the latest tag" do
      expect(page).to have_css ".timeline__latest", text: "Latest"
    end
  end

  describe "when external changenotes are present" do
    let(:edition) { build(:edition, :pension, change_note: "changed a to b", internal_change_note: nil) }

    before do
      render_inline component
    end

    it "shows the change note" do
      expect(page).to have_css ".timeline__note--public p", text: "changed a to b"
    end
  end

  describe "when internal changenotes are present" do
    let(:edition) { build(:edition, :pension, change_note: nil, internal_change_note: "changed x to y") }

    before do
      render_inline component
    end

    it "shows the change note" do
      expect(page).to have_css ".timeline__note--internal p", text: "changed x to y"
    end
  end

  describe "when field diffs are present" do
    let(:field_diffs) { { "foo" => DiffItem.new(previous_value: "previous value", new_value: "new value") } }
    let(:version) do
      build_stubbed(
        :content_block_version,
        event: "created",
        whodunnit: user.id,
        state: "published",
        created_at: 4.days.ago,
        item: edition,
        field_diffs:,
      )
    end

    let!(:table_component) do
      Document::Show::DocumentTimeline::FieldChangesTableComponent.new(
        version:,
        schema:,
      )
    end

    before do
      expect(Document::Show::DocumentTimeline::FieldChangesTableComponent)
        .to receive(:new)
        .with(version:, schema:)
        .and_return(table_component)

      expect(component)
        .to receive(:render)
        .with(table_component)
        .once
        .and_return("TABLE COMPONENT")
    end

    it "renders the table component unopened" do
      expect(component).to receive(:render)
                             .with("govuk_publishing_components/components/details", { title: "Details of changes", open: false, summary_aria_attributes: { label: "Details of changes - Published" } })

      render_inline component
    end

    describe "when the version is the latest version" do
      let(:is_latest) { true }

      it "renders the details as open" do
        expect(component)
          .to receive(:render)
          .with("govuk_publishing_components/components/details", { title: "Details of changes", open: true, summary_aria_attributes: { label: "Details of changes - Published" } })

        render_inline component
      end
    end
  end

  describe "when there are embedded objects" do
    let(:subschema1) { double(:subschema, id: "embedded_schema") }
    let(:subschema2) { double(:subschema, id: "other_embedded_schema") }
    let(:schema) { double(:schema, subschemas: [subschema1, subschema2]) }

    describe "when there are field diffs" do
      let(:field_diffs) do
        {
          "details" => {
            "embedded_schema" => {
              "something" => {
                "field1" => DiffItem.new(previous_value: "before", new_value: "after"),
                "field2" => DiffItem.new(previous_value: "before", new_value: "after"),
              },
            },
          },
        }
      end

      let(:version) do
        build_stubbed(
          :content_block_version,
          event: "created",
          whodunnit: user.id,
          state: "published",
          created_at: 4.days.ago,
          item: edition,
          field_diffs:,
        )
      end

      it "renders the embedded table component" do
        table_component = double("table_component")

        expect(Document::Show::DocumentTimeline::EmbeddedObject::FieldChangesTableComponent)
          .to receive(:new)
          .with(
            object_id: "something",
            field_diff: {
              "field1" => DiffItem.new(previous_value: "before", new_value: "after"),
              "field2" => DiffItem.new(previous_value: "before", new_value: "after"),
            },
            subschema_id: "embedded_schema",
            edition:,
          )
          .and_return(table_component)

        expect(component)
          .to receive(:render)
          .with("govuk_publishing_components/components/details", { title: "Details of changes", open: false, summary_aria_attributes: { label: "Details of changes - Published" } })

        expect(component)
          .to receive(:render)
          .with(table_component)
          .once
          .and_return("TABLE COMPONENT 1")

        expect(component)
          .to receive(:render)
          .with(anything)
          .once
          .and_return("TABLE COMPONENT 2")

        render_inline component

        # We expect the table component to only be rendered with the details component, not anywhere else.
        expect(page).to_not have_content "TABLE COMPONENT 1"
      end
    end

    describe "when there are no field diffs for the embedded object" do
      let(:field_diffs) { { "foo" => DiffItem.new(previous_value: "previous value", new_value: "new value") } }

      let(:version) do
        build_stubbed(
          :content_block_version,
          event: "created",
          whodunnit: user.id,
          state: "published",
          created_at: 4.days.ago,
          item: edition,
          field_diffs:,
        )
      end

      let!(:table_component) do
        Document::Show::DocumentTimeline::FieldChangesTableComponent.new(
          version:,
          schema:,
        )
      end

      it "renders the table component" do
        expect(Document::Show::DocumentTimeline::FieldChangesTableComponent)
          .to receive(:new)
          .with(version:, schema:)
          .and_return(table_component)

        expect(component)
          .to receive(:render)
          .with(table_component)
          .once
          .and_return("TABLE COMPONENT")

        expect(component)
          .to receive(:render)
          .with("govuk_publishing_components/components/details", { title: "Details of changes", open: false, summary_aria_attributes: { label: "Details of changes - Published" } })

        render_inline component
      end
    end
  end

  context "when version has the 'awaiting_review' state" do
    before do
      version.state = "awaiting_review"
      render_inline component
    end

    it "sets the #title to be 'Sent to review" do
      expect(page).to have_css(".timeline__title") do
        expect(page).to have_content(I18n.t("timeline_item.title.awaiting_review"))
      end
    end
  end

  context "when version has the 'draft_complete' state" do
    before do
      version.state = "draft_complete"
    end

    it "sets the #title to be 'Draft completed'" do
      render_inline component

      expect(page).to have_css(".timeline__title") do
        expect(page).to have_content(I18n.t("timeline_item.title.draft_complete"))
      end
    end
  end

  context "when version has the 'awaiting_factcheck' state" do
    before do
      version.state = "awaiting_factcheck"
    end

    it "sets the #title to be 'Sent to fact check'" do
      render_inline component

      expect(page).to have_css(".timeline__title") do
        expect(page).to have_content(I18n.t("timeline_item.title.awaiting_factcheck"))
      end
    end

    context "and its edition indicates that the review was performed" do
      before do
        edition.review_outcome.skipped = false
      end

      it "shows the review outcome" do
        render_inline component

        expect(page).to have_css(".timeline__review-outcome") do
          expect(page).to have_content("2i review performed")
        end
      end
    end

    context "and its edition indicates that the review was skipped" do
      before do
        edition.review_outcome.skipped = true
      end

      it "shows the review outcome" do
        render_inline component

        expect(page).to have_css(".timeline__review-outcome") do
          expect(page).to have_content("2i review skipped")
        end
      end
    end
  end

  describe "when the version has an outcome" do
    context "and the outcome has a performer" do
      let(:user) { build(:user, name: "Dave", email: "dave@example.com") }
      let(:review_outcome) { ReviewOutcome.new.tap { |o| o.performer = user.name } }
      let(:fact_check_outcome) { FactCheckOutcome.new.tap { |o| o.performer = user.email } }
      let(:edition) { build(:edition, review_outcome: review_outcome, fact_check_outcome: fact_check_outcome) }

      context "and the version is in the 'awaiting_factcheck' state" do
        before { version.state = "awaiting_factcheck" }

        it "should show the Review outcome performer" do
          render_inline component

          expect(page).to have_css(".timeline__review-outcome .govuk-body") do |element|
            expect(element).to have_content("2i review performed by Dave")
          end
        end
      end

      context "and the version is in the 'published' state" do
        before { version.state = "published" }

        it "should show the fact check outcome performer" do
          render_inline component

          expect(page).to have_css(".timeline__review-outcome .govuk-body") do |element|
            expect(element).to have_content("Fact check performed by dave@example.com", exact: true)
          end
        end
      end
    end

    context "and the outcome **does not** have a performer" do
      let(:review_outcome) { ReviewOutcome.new }
      let(:fact_check_outcome) { FactCheckOutcome.new }
      let(:edition) { build(:edition, review_outcome: review_outcome, fact_check_outcome: fact_check_outcome) }

      context "and the version is in the 'awaiting_factcheck' state" do
        before { version.state = "awaiting_factcheck" }

        it "should show the Review outcome performer" do
          render_inline component

          expect(page).to have_css(".timeline__review-outcome .govuk-body") do |element|
            expect(element).to have_content("2i review performed", exact: true)
          end
        end
      end

      context "and the version is in the 'published' state" do
        before { version.state = "published" }

        it "should not show the fact check outcome performer" do
          render_inline component

          expect(page).to have_css(".timeline__review-outcome .govuk-body") do |element|
            expect(element).to have_text("Fact check performed", exact: true)
          end
        end
      end
    end
  end

  describe "when the version **does not** have an outcome" do
    let(:edition) { build(:edition, review_outcome: nil, fact_check_outcome: nil) }

    context "and the version is in the 'awaiting_factcheck' state" do
      before { version.state = "awaiting_factcheck" }

      it "should not show any outcome" do
        render_inline component

        expect(page).not_to have_css(".timeline__review-outcome")
      end
    end

    context "and the version is in the 'published' state" do
      before { version.state = "published" }

      it "should not show any outcome" do
        render_inline component

        expect(page).not_to have_css(".timeline__review-outcome")
      end
    end
  end

  context "when the version is in the 'scheduled' state" do
    before do
      version.state = "scheduled"
      edition.scheduled_publication = Time.zone.parse("2026-01-01 13:05")
    end

    it "sets the #title to be 'Scheduled for publishing on {string}'" do
      render_inline component

      expect(page).to have_css(".timeline__title") do
        expect(page).to have_content(
          I18n.t("timeline_item.title.scheduled", datetime_string: "1 January 2026 at 1:05pm"),
        )
      end
    end
  end
end
