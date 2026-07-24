class BlocksController < ApplicationController
  def edition_params
    params.require("edition").permit(
      :description,
      :lead_organisation_id,
      :instructions_to_publishers,
      :title,
    ).merge(creator: current_user)
  end
end
