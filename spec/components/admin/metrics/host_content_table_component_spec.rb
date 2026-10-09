RSpec.describe Admin::Metrics::HostContentTableComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:measured_document) do
    create(:edition, :pension, :published, title: "New state pension").document.tap do |document|
      create(
        :rollup_metric,
        document:,
        lead_organisation_name: "Department for Work and Pensions",
        locations: 7,
        instances: 20,
        views: 98_731,
        organisations: 1,
      )
    end
  end

  let(:unmeasured_document) { create(:edition, :contact, :draft, title: "CMA press office").document }

  let(:documents) { Document.where(id: [measured_document.id, unmeasured_document.id]).order(:id) }

  let(:headings) do
    ["Organisation", "Block", "Block type", "Embed code", "Locations", "Instances", "Views (30 days)", "Orgs"]
  end

  def table
    page.find("[data-testid='host_content_metrics_table']")
  end

  def cells_for(title)
    table.find("tbody tr", text: title).all("th, td").map { |cell| cell.text.strip }
  end

  let(:order) { "-views" }

  before do
    allow(Organisation).to receive(:all).and_return([])
    render_inline(described_class.new(documents:, order:))
  end

  it "shows a column for each metric" do
    expect(table.all("thead th").map { |th| th.text.strip }).to eq(headings)
  end

  it "shows a row for each block" do
    expect(table).to have_css("tbody tr", count: 2)
  end

  it "shows a measured block's details and abbreviated metrics" do
    expect(cells_for("New state pension")).to eq([
      "Department for Work and Pensions",
      "New state pension",
      "Pension",
      "{{embed:content_block_pension:#{measured_document.content_id_alias}}}",
      "7",
      "20",
      "98.7k",
      "1",
    ])
  end

  it "links each block's title to the block's page" do
    expect(page).to have_link("New state pension", href: document_path(measured_document))
  end

  it "shows a placeholder for the organisation and metrics of a block not yet measured" do
    expect(cells_for("CMA press office")).to eq([
      "–",
      "CMA press office",
      "Contact",
      "{{embed:content_block_contact:#{unmeasured_document.content_id_alias}}}",
      "–",
      "–",
      "–",
      "–",
    ])
  end

  describe "sorting" do
    def sort_link(heading)
      table.find("thead th a", text: heading)
    end

    it "links each sortable column's heading to sort by it" do
      {
        "Organisation" => "lead_organisation_name",
        "Block type" => "block_type",
        "Locations" => "locations",
        "Instances" => "instances",
        "Views (30 days)" => "views",
        "Orgs" => "organisations",
      }.each do |heading, order|
        expect(sort_link(heading)[:href]).to eq(admin_metrics_host_content_path(order:))
      end
    end

    it "doesn't link the block and embed code headings" do
      expect(table).not_to have_css("thead th a", exact_text: "Block")
      expect(table).not_to have_css("thead th a", text: "Embed code")
    end

    it "shows that the table is sorted by views, descending" do
      expect(table).to have_css(
        ".govuk-table__header--active a.app-table__sort-link--descending",
        text: "Views (30 days)",
      )
    end

    describe "when sorted by organisation, ascending" do
      let(:order) { "lead_organisation_name" }

      it "shows that the table is sorted by organisation, ascending" do
        expect(table).to have_css(
          ".govuk-table__header--active a.app-table__sort-link--ascending",
          text: "Organisation",
        )
      end

      it "links the organisation heading to sort by organisation, descending" do
        expect(sort_link("Organisation")[:href])
          .to eq(admin_metrics_host_content_path(order: "-lead_organisation_name"))
      end
    end
  end
end
