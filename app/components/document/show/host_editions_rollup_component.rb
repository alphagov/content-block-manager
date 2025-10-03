class Document::Show::HostEditionsRollupComponent < ViewComponent::Base
  METRICS = %i[locations instances views organisations].freeze

  def initialize(rollup:)
    @rollup = rollup
  end

private

  attr_reader :rollup

  def metrics
    METRICS.index_with do |metric|
      abbreviate(rollup.send(metric))
    end
  end

  def abbreviate(number)
    {
      figure: number_to_human(number, format: "%n"),
      display_label: number_to_human(number, format: "%u", units: { unit: "", thousand: "k", million: "m", billion: "b" }),
      explicit_label: number_to_human(number, format: "%u"),
    }
  end

  def title(metric)
    I18n.t("rollup.#{metric}.title", default: metric.to_s.titleize)
  end
end
