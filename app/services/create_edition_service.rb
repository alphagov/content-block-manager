class CreateEditionService
  def initialize(schema)
    @schema = schema
  end

  def call(edition_params, document_id: nil)
    @new_edition = build_edition(edition_params, document_id)
    params = build_params(edition_params, document_id)
    @new_edition.assign_attributes(params)
    @new_edition.save!
    @new_edition
  end

private

  def build_edition(edition_params, document_id)
    if document_id.nil?
      Edition.new(edition_params)
    else
      document = Document.find(document_id)
      new_edition = document.latest_published_edition.dup
      Edition.new(
        document_id:,
        title: edition_params[:title],
        details: new_edition.details,
        document_attributes: edition_params.delete(:document_attributes)
                                           .except(:block_type)
                                           .merge({ id: document_id }),
      )
    end
  end

  def build_params(edition_params, document_id)
    unless document_id.nil?
      document = Document.find(document_id)
      latest_published_edition = document.latest_published_edition
      edition_params[:details] = latest_published_edition.details.merge(edition_params[:details])
    end
    edition_params
  end
end
