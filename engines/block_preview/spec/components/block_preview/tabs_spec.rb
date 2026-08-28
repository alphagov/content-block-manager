RSpec.describe BlockPreview::TabsComponent, type: :component do
  include BlockPreview::Engine.routes.url_helpers

  let(:block) { build_stubbed(:content_block) }
  let(:preview_content) do
    double(
      :preview_content,
      content_id: SecureRandom.uuid,
      locale: "en",
      state: "draft",
    )
  end

  it "renders links for the instances and preview tabs" do
    render_inline(
      described_class.new(
        snippet_count: 3,
        current_tab: "instances",
        block:,
        preview_content:,
      ),
    )

    instances_link = page.find("a", text: "Preview instances (3)")
    preview_link = page.find("a", text: "Preview document")

    expect(instances_link[:href]).to eq(
      host_content_preview_path(
        edition_id: block.id,
        host_content_id: preview_content.content_id,
        locale: preview_content.locale,
        state: preview_content.state,
        tab: "instances",
      ),
    )

    expect(preview_link[:href]).to eq(
      host_content_preview_path(
        edition_id: block.id,
        host_content_id: preview_content.content_id,
        locale: preview_content.locale,
        state: preview_content.state,
        tab: "preview",
      ),
    )
  end

  it "marks the preview tab as current when current_tab is preview" do
    render_inline(
      described_class.new(
        snippet_count: 1,
        current_tab: "preview",
        block:,
        preview_content:,
      ),
    )

    expect(page).to have_css("li.gem-c-secondary-navigation__list-item--current", text: "Preview document")
    expect(page).to have_css("li", text: "Preview instances (1)")
    expect(page).to have_no_css("li.gem-c-secondary-navigation__list-item--current", text: "Preview instances (1)")
  end
end
