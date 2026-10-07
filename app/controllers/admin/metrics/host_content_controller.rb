class Admin::Metrics::HostContentController < ApplicationController
  before_action { authorise_user!(User::Permissions::VIEW_METRICS) }

  rescue_from GDS::SSO::PermissionDeniedError do
    render "errors/forbidden", status: :forbidden
  end

  def index
    @documents = Document.includes(:rollup_metric, :most_recent_edition).order(:id)
  end
end
