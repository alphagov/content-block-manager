module V2
  class BaseController < ApplicationController
    helper_method :document_id_in_params?

    def edition_params
      params.require("edition").permit(
        :description,
        :lead_organisation_id,
        :instructions_to_publishers,
        :title,
      ).merge(creator: current_user)
    end

    def document_id_in_params?
      params[:document_id].present?
    end
  end
end
