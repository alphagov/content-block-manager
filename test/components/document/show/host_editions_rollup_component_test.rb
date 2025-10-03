require "test_helper"

class Document::Show::HostEditionsRollupComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:described_class) { Document::Show::HostEditionsRollupComponent }

  it "returns rolled up data with small numbers" do
    rollup = build(:rollup, views: 12, locations: 2, instances: 3, organisations: 1)

    render_inline(described_class.new(rollup:))

    metrics = page.find_all(".rollup-details__rollup-metric")

    assert_equal 4, metrics.count

    assert metrics[0][:class].include?("locations")
    metrics[0].assert_selector ".gem-c-glance-metric__heading", text: "Locations"
    metrics[0].assert_selector ".gem-c-glance-metric__figure", text: "2"

    assert metrics[1][:class].include?("instances")
    metrics[1].assert_selector ".gem-c-glance-metric__heading", text: "Instances"
    metrics[1].assert_selector ".gem-c-glance-metric__figure", text: "3"

    assert metrics[2][:class].include?("views")
    metrics[2].assert_selector ".gem-c-glance-metric__heading", text: "Views"
    metrics[2].assert_selector ".gem-c-glance-metric__figure", text: "12"

    assert metrics[3][:class].include?("organisations")
    metrics[3].assert_selector ".gem-c-glance-metric__heading", text: "Organisations"
    metrics[3].assert_selector ".gem-c-glance-metric__figure", text: "1"
  end

  it "returns rolled up data with larger numbers" do
    rollup = build(:rollup, views: 12_000_000, locations: 15_000)

    render_inline(described_class.new(rollup:))

    assert_selector ".rollup-details__rollup-metric.views .gem-c-glance-metric__heading", text: "Views"
    assert_selector ".rollup-details__rollup-metric.views .gem-c-glance-metric__figure", text: "12"
    assert_selector ".rollup-details__rollup-metric.views .gem-c-glance-metric__display-label", text: "m"
    assert_selector ".rollup-details__rollup-metric.views .gem-c-glance-metric__explicit-label", text: "Million"

    assert_selector ".rollup-details__rollup-metric.locations .gem-c-glance-metric__figure", text: "15"
    assert_selector ".rollup-details__rollup-metric.locations .gem-c-glance-metric__display-label", text: "k"
    assert_selector ".rollup-details__rollup-metric.locations .gem-c-glance-metric__explicit-label", text: "Thousand"
  end
end
