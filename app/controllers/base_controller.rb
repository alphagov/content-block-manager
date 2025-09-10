class BaseController < ApplicationController
  def scheduled_publication_params
    params.require(:scheduled_at).permit("scheduled_publication(1i)",
                                         "scheduled_publication(2i)",
                                         "scheduled_publication(3i)",
                                         "scheduled_publication(4i)",
                                         "scheduled_publication(5i)")
  end

  def edition_params
    params.require("edition")
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
end
