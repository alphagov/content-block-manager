class ContentBlockManager::BaseController < ApplicationController
  before_action :set_sentry_tags

  def scheduled_publication_params
    params.require(:scheduled_at).permit("scheduled_publication(1i)",
                                         "scheduled_publication(2i)",
                                         "scheduled_publication(3i)",
                                         "scheduled_publication(4i)",
                                         "scheduled_publication(5i)")
  end

  def edition_params
    params.require("content_block/edition")
          .permit(
            :lead_organisation_id,
            :creator,
            :instructions_to_publishers,
            "scheduled_publication(1i)",
            "scheduled_publication(2i)",
            "scheduled_publication(3i)",
            "scheduled_publication(4i)",
            "scheduled_publication(5i)",
            :title,
            :internal_change_note,
            :change_note,
            :major_change,
            document_attributes: %w[block_type],
            details: @schema.permitted_params,
          )
          .merge!(creator: current_user)
  end

  def set_sentry_tags
    Sentry.set_tags(engine: "content_block_manager")
  end
  delegate :support_url, to: :ContentBlockManager
  helper_method :support_url
end
