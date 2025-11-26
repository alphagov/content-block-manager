class EditionsController < BaseController
  include Workflow::HasSteps

  skip_before_action :initialize_edition_and_schema

  def new
    if params[:document_id]
      @document = Document.find(params[:document_id])
      @title = @document.title
      @schema = Schema.find_by_block_type(@document.block_type)
      edition = @document.most_recent_edition
    else
      @title = "Create content block"
      @schema = Schema.find_by_block_type(params[:block_type].underscore)
      edition = Edition.new
    end
    @form = EditionForm.for(
      edition:,
      schema: @schema,
    )
  end

  def create
    @schema = Schema.find_by_block_type(block_type_param)
    @edition = CreateEditionService.new(@schema).call(edition_params, document_id: params[:document_id])
    redirect_to workflow_path(id: @edition.id, step: steps[1].name)
  rescue ActiveRecord::RecordInvalid => e
    @title = params[:document_id] ? e.record.document.title : "Create content block"
    @form = EditionForm.for(edition: e.record, schema: @schema)
    render "editions/new", status: :unprocessable_content
  end

  def destroy
    edition_to_delete = Edition.find(params[:id])
    DeleteEditionService.new.call(edition_to_delete)
    redirect_to params[:redirect_path] || root_path
  end

  def delete
    @edition = Edition.find(params[:id])
    @form = EditionForm.for(
      edition: @edition,
      schema: @edition.schema,
    )
    @body = I18n.t("edition.delete.body")
  end

  def preview
    @edition = Edition.find(params[:id])
  end

private

  def block_type_param
    params.require("edition").require("document_attributes").require(:block_type)
  end
end
