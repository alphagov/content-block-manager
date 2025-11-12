RSpec.describe Document::Show::HostEditionsRollupComponent, type: :component do
  let(:described_class) { Document::Show::HostEditionsRollupComponent }

  before do
    expect(I18n).to receive(:t).with("rollup.locations.title", default: "Locations").and_return("Locations translated")
    expect(I18n).to receive(:t).with("rollup.instances.title", default: "Instances").and_return("Instances translated")
    expect(I18n).to receive(:t).with("rollup.views.title", default: "Views").and_return("Views translated")
    expect(I18n).to receive(:t).with("rollup.organisations.title", default: "Organisations").and_return("Organisations translated")

    expect(I18n).to receive(:t).with("rollup.locations.context", default: nil).and_return("Locations context")
    expect(I18n).to receive(:t).with("rollup.instances.context", default: nil).and_return("Instances context")
    expect(I18n).to receive(:t).with("rollup.views.context", default: nil).and_return("Views context")
    expect(I18n).to receive(:t).with("rollup.organisations.context", default: nil).and_return("Organisations context")
  end

  it "returns rolled up data with small numbers" do
    rollup = build(:rollup, views: 12, locations: 2, instances: 3, organisations: 1)

    render_inline(described_class.new(rollup:))

    metrics = page.find_all(".rollup-details__rollup-metric")

    expect(metrics.count).to eq(4)

    expect(metrics[0][:class]).to include("locations")
    expect(page).to have_css ".gem-c-glance-metric__heading", text: "Locations translated"
    expect(page).to have_css ".gem-c-glance-metric__figure", text: "2"
    expect(page).to have_css ".gem-c-glance-metric__context", text: "Locations context"

    expect(metrics[1][:class]).to include("instances")
    expect(page).to have_css ".gem-c-glance-metric__heading", text: "Instances translated"
    expect(page).to have_css ".gem-c-glance-metric__figure", text: "3"
    expect(page).to have_css ".gem-c-glance-metric__context", text: "Instances context"

    expect(metrics[2][:class]).to include("views")
    expect(page).to have_css ".gem-c-glance-metric__heading", text: "Views translated"
    expect(page).to have_css ".gem-c-glance-metric__figure", text: "12"
    expect(page).to have_css ".gem-c-glance-metric__context", text: "Views context"

    expect(metrics[3][:class]).to include("organisations")
    expect(page).to have_css ".gem-c-glance-metric__heading", text: "Organisations translated"
    expect(page).to have_css ".gem-c-glance-metric__figure", text: "1"
    expect(page).to have_css ".gem-c-glance-metric__context", text: "Organisations context"
  end

  it "returns rolled up data with larger numbers" do
    rollup = build(:rollup, views: 12_000_000, locations: 15_000)

    render_inline(described_class.new(rollup:))

    expect(page).to have_css ".rollup-details__rollup-metric.views .gem-c-glance-metric__heading", text: "Views"
    expect(page).to have_css ".rollup-details__rollup-metric.views .gem-c-glance-metric__figure", text: "12"
    expect(page).to have_css ".rollup-details__rollup-metric.views .gem-c-glance-metric__display-label", text: "m"
    expect(page).to have_css ".rollup-details__rollup-metric.views .gem-c-glance-metric__explicit-label", text: "Million"

    expect(page).to have_css ".rollup-details__rollup-metric.locations .gem-c-glance-metric__figure", text: "15"
    expect(page).to have_css ".rollup-details__rollup-metric.locations .gem-c-glance-metric__display-label", text: "k"
    expect(page).to have_css ".rollup-details__rollup-metric.locations .gem-c-glance-metric__explicit-label", text: "Thousand"
  end
end
