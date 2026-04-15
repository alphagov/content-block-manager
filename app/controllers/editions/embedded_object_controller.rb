class Editions::EmbeddedObjectController < BaseController
  include HasSubschema
  include Workflow::HasSteps

  before_action :initialize_edition
  before_action :set_schema_and_subschema, only: %i[create edit update]

  def new
    @schema = get_schema(@edition.document.block_type)

    @subschema = get_subschema(@schema, params[:object_type])
    @back_link = workflow_path(@edition, step: :edit_draft)

    render :new
  end

  def create
    details = object_params(@subschema)[:details]
    @object = details[@subschema.block_type.to_s]
    converted_object = validate_and_convert_object(@object)
    @back_link = review_path

    @edition.store_sole_object_in_details(@subschema.block_type, converted_object)
    @edition.save!

    flash[:success] = I18n.t(
      "edition.create.embedded_object.created_confirmation",
      object_name: @subschema.name.singularize,
    )

    redirect_to workflow_path(@edition, step: next_step.name)
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_content
  end

  def edit
    @redirect_url = workflow_path(@edition, step: :review)
    @object = @edition.details[params[:object_type]]

    render "errors/not_found", status: :not_found unless @object
  end

  def update
    details = object_params(@subschema)[:details]
    @object = details[@subschema.block_type.to_s]
    converted_object = validate_and_convert_object(@object)

    @redirect_url = params[:redirect_url]
    @edition.store_sole_object_in_details(params[:object_type], converted_object)

    @edition.save!
    flash[:success] = I18n.t(
      "edition.create.embedded_object.updated_confirmation",
      object_name: @subschema.name.singularize,
    )

    redirect_to workflow_path(@edition, step: next_step.name), allow_other_host: false
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_content
  end

private

  def initialize_edition
    @edition = Edition.find(params[:id])
  end

  def set_schema_and_subschema
    @schema, @subschema = get_schema_and_subschema(
      @edition.document.block_type,
      params[:object_type],
    )
  end

  def review_path
    workflow_path(@edition, step: "review")
  end
end
