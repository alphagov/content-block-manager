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

    if no_edition_id_provided?(params)
      V2::Document.find(params[:document_id]).most_recent_edition.type
    else
      id = params[:edition_id] || params[:id]
      V2::Edition.where(id: id).pick(:type)
    end
  end

  def no_edition_id_provided?(params)
    params[:document_id] && (!params[:edition_id] & !params[:id])
  end
end
