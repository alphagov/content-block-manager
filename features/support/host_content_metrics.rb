module HostContentMetricsHelpers
  METRICS_TABLE = "[data-testid='host_content_metrics_table']".freeze

  COLUMN_HEADINGS = {
    "organisation" => "Organisation",
    "title" => "Block",
    "block type" => "Block type",
    "embed code" => "Embed code",
    "locations" => "Locations",
    "instances" => "Instances",
    "views" => "Views (30 days)",
    "organisations" => "Orgs",
  }.freeze

  METRIC_KEYS = %w[locations instances views organisations].freeze

  def create_block_with_title(title, block_type:, state: :published, organisation: nil)
    organisation ||= build(:organisation, name: "Ministry of Example")
    stub_organisations(organisation)

    document = create(:document, block_type:, sluggable_string: title.parameterize)
    create(:edition, state, document:, title:, lead_organisation_id: organisation.id)

    @blocks ||= {}
    @blocks[title] = document
  end

  def stub_organisations(organisation)
    @organisations ||= []
    @organisations << organisation unless @organisations.include?(organisation)
    allow(Organisation).to receive(:all).and_return(@organisations)
  end

  def metrics_table_column_index(key)
    heading = COLUMN_HEADINGS.fetch(key)
    headings = all("#{METRICS_TABLE} thead th").map { |th| th.text.strip }
    index = headings.index { |text| text.start_with?(heading) }
    raise "No '#{heading}' column in #{headings.inspect}" unless index

    index
  end

  def metrics_table_row_for(title)
    find("#{METRICS_TABLE} tbody tr", text: title)
  end

  def metrics_table_cell(title, key)
    metrics_table_row_for(title).all("th, td")[metrics_table_column_index(key)]
  end

  def metrics_table_titles
    index = metrics_table_column_index("title")
    all("#{METRICS_TABLE} tbody tr").map { |row| row.all("th, td")[index].text.strip }
  end
end

World(HostContentMetricsHelpers)
