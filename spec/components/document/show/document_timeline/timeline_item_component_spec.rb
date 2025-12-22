RSpec.describe Document::Show::DocumentTimeline::TimelineItemComponent, type: :component do
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper

  let(:user) { create(:user) }
  let(:schema) { double(:schema, subschemas: []) }

  let(:edition) { build(:edition, :pension, change_note: nil, internal_change_note: nil, review_outcome: ReviewOutcome.new) }
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
      expect(page).to have_css ".timeline__title", text: "Pension created"
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

  describe "when the version is an embedded update" do
    let(:subschema) { double(:subschema, id: "embedded_schema", name: "Embedded schema") }
    let(:schema) { double(:schema, subschemas: [subschema]) }

    let(:field_diffs) do
      {
        "details" => {
          "embedded_schema" => {
            "something" => {
              "field1" => DiffItem.new(previous_value: nil, new_value: "Field 1 value"),
              "field2" => DiffItem.new(previous_value: nil, new_value: "Field 2 value"),
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
        updated_embedded_object_type: "embedded_schema",
        updated_embedded_object_title: "something",
      )
    end

    before do
      allow(schema).to receive(:subschema).with("embedded_schema").and_return(subschema)
    end

    it "renders the correct title" do
      render_inline component

      expect(page).to have_css ".timeline__title", text: "Embedded schema added"
    end

    it "renders the details of the updated object" do
      render_inline component

      expect(page).to have_css ".timeline__embedded-item-list__item", count: 1
      expect(page).to_not have_css "summary"
      expect(page).to have_css ".timeline__embedded-item-list .timeline__embedded-item-list__item:nth-child(1) .timeline__embedded-item-list__key", text: "Field1:"
      expect(page).to have_css ".timeline__embedded-item-list .timeline__embedded-item-list__item:nth-child(1) .timeline__embedded-item-list__value", text: "Field 1 value"
    end
  end

  describe "when there is no embedded update" do
    it "uses aria-label to distinguish the summary of the details of the changes" do
      allow(version).to receive(:field_diffs).and_return({ "foo" => DiffItem.new(previous_value: "previous value", new_value: "new value") })
      allow(version).to receive(:is_embedded_update?).and_return(false)
      allow(version).to receive(:state).and_return("Fiddled With")
      allow(component).to receive(:main_object_field_changes).and_return("some main object field changes")

      render_inline component

      expect(page).to have_css "summary[aria-label='Details of changes - Pension Fiddled With']"
      expect(page).to have_css "summary", text: "Details of changes"
    end
  end

  context "when version has the 'awaiting_review' state" do
    before do
      version.state = "awaiting_review"
      render_inline component
    end

    it "sets the #title to be 'Sent to review" do
      expect(page).to have_css(".timeline__title") do
        expect(page).to have_content("Sent to review")
      end
    end
  end

  context "when version has the 'awaiting_factcheck' state" do
    before do
      version.state = "awaiting_factcheck"
    end

    it "sets the #title to be 'Sent to factcheck'" do
      render_inline component

      expect(page).to have_css(".timeline__title") do
        expect(page).to have_content("Sent to factcheck")
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
end
