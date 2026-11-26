RSpec.describe V2::Document::Show::DocumentTimeline::TimelineItemComponent, type: :component do
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper

  let(:user) { create(:user) }

  let(:edition) do
    create(:v2_time_period_edition, change_note: nil, internal_change_note: nil)
  end

  let(:version) do
    build(
      :v2_version,
      event: "created",
      whodunnit: user.id,
      state: "published",
      created_at: 4.days.ago,
      item: edition,
    )
  end

  let(:domain_event) { build(:v2_domain_event, edition:, user:, version:, created_at: version.created_at) }

  let(:is_latest) { false }
  let(:is_first_published_version) { false }

  let(:component) do
    described_class.new(
      domain_event:,
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
        text: I18n.t("timeline_item.title.published", block_type: "Time period"),
      )
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
    let(:edition) { build(:v2_time_period_edition, change_note: "changed a to b", internal_change_note: nil) }

    before do
      render_inline component
    end

    it "shows the change note" do
      expect(page).to have_css ".timeline__note--public p", text: "changed a to b"
    end
  end

  describe "when internal changenotes are present" do
    let(:edition) { build(:v2_time_period_edition, change_note: nil, internal_change_note: "changed x to y") }

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
        :v2_version,
        event: "created",
        whodunnit: user.id,
        state: "published",
        created_at: 4.days.ago,
        item: edition,
        field_diffs:,
      )
    end

    let!(:table_component) do
      V2::Document::Show::DocumentTimeline::FieldChangesTableComponent.new(
        version:,
      )
    end

    before do
      expect(V2::Document::Show::DocumentTimeline::FieldChangesTableComponent)
        .to receive(:new)
        .with(version:)
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

  describe "when there are nested fields in the to_details hash" do
    context "when some of the fields have diffs" do
      let(:field_diffs) do
        {
          "title" => DiffItem.new(previous_value: "old title", new_value: "new title"),
          "details" => {
            "description" => DiffItem.new(previous_value: "the old description", new_value: "the new description"),
            "date_range" => {
              "start" => DiffItem.new(previous_value: "2025-02-01", new_value: "2027-02-01"),
            },
          },
        }
      end

      let(:version) do
        build(
          :v2_version,
          event: "updated",
          whodunnit: user.id,
          state: "published",
          field_diffs: field_diffs,
          item: edition,
          created_at: 4.days.ago,
        )
      end

      let(:is_latest) { true }

      it "includes the nested fields in the field changes table" do
        render_inline component

        expect(page).to have_css "tbody tr:nth-child(1) th:nth-child(1)", text: "Time period name"
        expect(page).to have_css "tbody tr:nth-child(1) td:nth-child(2)", text: "old title"
        expect(page).to have_css "tbody tr:nth-child(1) td:nth-child(3)", text: "new title"

        expect(page).to have_css "tbody tr:nth-child(2) th:nth-child(1)", text: "Description"
        expect(page).to have_css "tbody tr:nth-child(2) td:nth-child(2)", text: "the old description"
        expect(page).to have_css "tbody tr:nth-child(2) td:nth-child(3)", text: "the new description"

        expect(page).to have_css "tbody tr:nth-child(3) th:nth-child(1)", text: "Date range start"
        expect(page).to have_css "tbody tr:nth-child(3) td:nth-child(2)", text: "2025-02-01"
        expect(page).to have_css "tbody tr:nth-child(3) td:nth-child(3)", text: "2027-02-01"
      end

      it "does not include unchanges fields in the field changes table" do
        render_inline component

        expect(page).to_not have_css("tbody th", text: "Date range end")
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

  context "when the version is in the 'scheduled' state" do
    before do
      version.state = "scheduled"
    end

    context "when scheduled_for_publication_at is present in DomainEvent" do
      before do
        edition.scheduled_for_publication_at = nil
        allow_any_instance_of(V2::DomainEvent).to receive(:metadata).and_return({ "scheduled_for_publication_at" => Time.zone.parse("2026-01-01 13:05").to_fs(:long_ordinal_with_at) })
      end

      it "sets the #title to be 'Scheduled for publishing {string}'" do
        render_inline component

        expect(page).to have_css(".timeline__title") do
          expect(page).to have_content(
            I18n.t("timeline_item.title.scheduled", datetime_string: "on 1 January 2026 at 1:05pm"),
          )
        end
      end
    end

    context "when scheduled_for_publication_at is present in the Edition" do
      before do
        edition.scheduled_for_publication_at = Time.zone.parse("2026-01-01 13:05")
      end

      it "sets the #title to be 'Scheduled for publishing {string}'" do
        render_inline component

        expect(page).to have_css(".timeline__title") do
          expect(page).to have_content(
            I18n.t("timeline_item.title.scheduled", datetime_string: "on 1 January 2026 at 1:05pm"),
          )
        end
      end
    end

    context "when scheduled_for_publication_at is not present" do
      before do
        edition.scheduled_for_publication_at = nil
        edition.scheduled_for_publication_at = nil
        allow_any_instance_of(V2::DomainEvent).to receive(:metadata).and_return({})
      end

      it "sets the #title to be 'Scheduled for publishing'" do
        render_inline component

        expect(page).to have_css(".timeline__title") do
          expect(page).to have_content(
            I18n.t("timeline_item.title.scheduled", datetime_string: nil),
          )
        end
      end
    end
  end

  context "when the domain event does not have a version" do
    let(:version) { nil }
    let(:domain_event) do
      build(:v2_domain_event,
            edition:,
            name: "edition.review.performed",
            user:,
            version:,
            created_at: 4.days.ago)
    end

    it "should not throw an error" do
      expect { render_inline component }.not_to raise_error
    end

    it "should show the title based on the domain event" do
      render_inline component

      expect(page).to have_css(".timeline__title", text: I18n.t("domain_event.title.#{domain_event.name}"))
    end
  end
end
