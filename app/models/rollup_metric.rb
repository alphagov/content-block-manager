class RollupMetric < ApplicationRecord
  belongs_to :document

  def self.record!(document:, rollup:)
    find_or_initialize_by(document:).tap do |rollup_metric|
      rollup_metric.update!(
        views: rollup.views.to_i,
        locations: rollup.locations.to_i,
        instances: rollup.instances.to_i,
        organisations: rollup.organisations.to_i,
        lead_organisation_name: document.most_recent_edition&.lead_organisation&.name,
        refreshed_at: Time.current,
      )
    end
  end
end
