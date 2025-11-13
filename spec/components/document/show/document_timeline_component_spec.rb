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

    component = described_class.new(
      content_block_versions: [version_4, version_3, version_2, version_1, superseded_version],
      schema:,
    )

    version_2_component_stub = double("timeline_item_component")
    version_3_component_stub = double("timeline_item_component")
    version_4_component_stub = double("timeline_item_component")

    allow(Document::Show::DocumentTimeline::TimelineItemComponent)
      .to receive(:new)
      .with(
        version: version_4,
        schema:,
        is_first_published_version: false,
        is_latest: true,
      ).and_return(version_4_component_stub)

    allow(Document::Show::DocumentTimeline::TimelineItemComponent)
      .to receive(:new)
      .with(
        version: version_3,
        schema:,
        is_first_published_version: false,
        is_latest: false,
      ).and_return(version_3_component_stub)

    allow(Document::Show::DocumentTimeline::TimelineItemComponent)
      .to receive(:new)
      .with(
        version: version_2,
        schema:,
        is_first_published_version: true,
        is_latest: false,
      ).and_return(version_2_component_stub)

    expect(component).to receive(:render).with(version_4_component_stub).and_return("version 4")
    expect(component).to receive(:render).with(version_3_component_stub).and_return("version 3")
    expect(component).to receive(:render).with(version_2_component_stub).and_return("version 2")

    render_inline component

    have_text "version 4\n    version 3\n    version 2"
  end
end
