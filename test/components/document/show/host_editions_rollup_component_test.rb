require "test_helper"

class Document::Show::HostEditionsRollupComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:described_class) { Document::Show::HostEditionsRollupComponent }

  before do
    I18n.expects(:t).with("rollup.locations.title", default: "Locations").returns("Locations translated")
    I18n.expects(:t).with("rollup.instances.title", default: "Instances").returns("Instances translated")
    I18n.expects(:t).with("rollup.views.title", default: "Views").returns("Views translated")
    I18n.expects(:t).with("rollup.organisations.title", default: "Organisations").returns("Organisations translated")

    I18n.expects(:t).with("rollup.locations.context", default: nil).returns("Locations context")
    I18n.expects(:t).with("rollup.instances.context", default: nil).returns("Instances context")
    I18n.expects(:t).with("rollup.views.context", default: nil).returns("Views context")
    I18n.expects(:t).with("rollup.organisations.context", default: nil).returns("Organisations context")
  end

  it "returns rolled up data with small numbers" do
    rollup = build(:rollup, views: 12, locations: 2, instances: 3, organisations: 1)

    render_inline(described_class.new(rollup:))

    metrics = page.find_all(".rollup-details__rollup-metric")

    assert_equal 4, metrics.count

    assert metrics[0][:class].include?("locations")
    metrics[0].assert_selector ".gem-c-glance-metric__heading", text: "Locations translated"
    metrics[0].assert_selector ".gem-c-glance-metric__figure", text: "2"
    metrics[0].assert_selector ".gem-c-glance-metric__context", text: "Locations context"

    assert metrics[1][:class].include?("instances")
    metrics[1].assert_selector ".gem-c-glance-metric__heading", text: "Instances translated"
    metrics[1].assert_selector ".gem-c-glance-metric__figure", text: "3"
    metrics[1].assert_selector ".gem-c-glance-metric__context", text: "Instances context"

    assert metrics[2][:class].include?("views")
    metrics[2].assert_selector ".gem-c-glance-metric__heading", text: "Views translated"
    metrics[2].assert_selector ".gem-c-glance-metric__figure", text: "12"
    metrics[2].assert_selector ".gem-c-glance-metric__context", text: "Views context"

    assert metrics[3][:class].include?("organisations")
    metrics[3].assert_selector ".gem-c-glance-metric__heading", text: "Organisations translated"
    metrics[3].assert_selector ".gem-c-glance-metric__figure", text: "1"
    metrics[3].assert_selector ".gem-c-glance-metric__context", text: "Organisations context"
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
