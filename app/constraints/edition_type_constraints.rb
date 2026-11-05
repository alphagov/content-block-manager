class EditionTypeConstraints
  def initialize(type)
    @type = type
  end

  def matches?(request)
    type = (request.env["edition.type"] ||= set_type(request))
    type == @type
  end

private

  def set_type(request)
    params = request.path_parameters

    if params[:document_id] && (!params[:edition_id] & !params[:id])
      # Routes where no edition is specified: /v2/documents/:document_id/editions/action
      V2::Document.find(params[:document_id]).most_recent_edition.type
    else
      # Routes where an edition is specified: /v2/documents/:document_id/editions/:edition_id/action
      id = params[:edition_id] || params[:id]
      V2::Edition.where(id: id).pick(:type)
    end
  end
end
