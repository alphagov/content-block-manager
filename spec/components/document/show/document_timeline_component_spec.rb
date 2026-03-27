RSpec.describe Document::Show::DocumentTimelineComponent, type: :component do
  let(:user) { build_stubbed(:user) }
  let(:schema) { build(:schema) }

  it "renders components for each event" do
    item = build_stubbed(:edition, :pension, change_note: nil, internal_change_note: nil)
    scheduled_item = build_stubbed(
      :edition,
      :pension,
      change_note: nil,
      internal_change_note: nil,
      scheduled_publication: 2.days.from_now,
    )
    version_1 = build_stubbed(
      :content_block_version,
      event: "created",
      whodunnit: user.id,
      created_at: 4.days.ago,
      item:,
    )
    version_2 = build_stubbed(
      :content_block_version,
      event: "updated",
      whodunnit: user.id,
      state: "published",
      created_at: 3.days.ago,
      item:,
    )
    version_3 = build_stubbed(
      :content_block_version,
      event: "updated",
      whodunnit: user.id,
      state: "published",
      created_at: 2.days.ago,
      item:,
    )
    version_4 = build_stubbed(
      :content_block_version,
      event: "updated",
      whodunnit: user.id,
      state: "scheduled",
      created_at: 1.day.ago,
      item: scheduled_item,
    )
    superseded_version = build_stubbed(
      :content_block_version,
      event: "updated",
      state: "superseded",
      item:,
    )
    domain_event_0 = build_stubbed(:domain_event, version: superseded_version, created_at: superseded_version.created_at)
    domain_event_1 = build_stubbed(:domain_event, version: version_1, created_at: version_1.created_at)
    domain_event_2 = build_stubbed(:domain_event, version: version_2, created_at: version_2.created_at)
    domain_event_3 = build_stubbed(:domain_event, version: version_3, created_at: version_3.created_at)
    domain_event_4 = build_stubbed(:domain_event, version: version_4, created_at: version_4.created_at)

    component = described_class.new(
      document_domain_events: [domain_event_4, domain_event_3, domain_event_2, domain_event_1, domain_event_0],
      schema:,
    )

    version_2_component_stub = double("timeline_item_component")
    version_3_component_stub = double("timeline_item_component")
    version_4_component_stub = double("timeline_item_component")

    expect(Document::Show::DocumentTimeline::TimelineItemComponent).to receive(:new)
      .with(
        domain_event: domain_event_4,
        schema:,
        is_first_published_version: false,
        is_latest: true,
      ).and_return(version_4_component_stub)

    expect(Document::Show::DocumentTimeline::TimelineItemComponent).to receive(:new)
      .with(
        domain_event: domain_event_3,
        schema:,
        is_first_published_version: false,
        is_latest: false,
      ).and_return(version_3_component_stub)

    expect(Document::Show::DocumentTimeline::TimelineItemComponent).to receive(:new)
      .with(
        domain_event: domain_event_2,
        schema:,
        is_first_published_version: true,
        is_latest: false,
      ).and_return(version_2_component_stub)

    expect(component).to receive(:render).with(version_4_component_stub).and_return("version 4")
    expect(component).to receive(:render).with(version_3_component_stub).and_return("version 3")
    expect(component).to receive(:render).with(version_2_component_stub).and_return("version 2")

    render_inline component

    expect(page).to have_text("version 4\n    version 3\n    version 2")
  end

  context "where there is no published version" do
    let(:item) do
      build_stubbed(
        :edition,
        :pension,
        document: build_stubbed(:document, :pension),
        change_note: nil,
        internal_change_note: nil,
      )
    end

    let(:versions) do
      [
        build_stubbed(
          :content_block_version,
          event: "created",
          whodunnit: 34,
          created_at: 4.days.ago,
          item:,
        ),
        build_stubbed(
          :content_block_version,
          event: "updated",
          whodunnit: 34,
          state: "awaiting_review",
          created_at: 3.days.ago,
          item:,
        ),
      ]
    end

    let(:domain_events) do
      versions.map do |version|
        build_stubbed(:domain_event, edition: item, version:, created_at: version.created_at)
      end
    end

    let(:component) do
      Document::Show::DocumentTimelineComponent.new(
        document_domain_events: domain_events,
        schema:,
      )
    end

    it "handles the lack of 'first_published_version'" do
      expect { render_inline component }.to_not raise_error
    end
  end
end
