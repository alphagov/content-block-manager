class Editions::EmbeddedObjectsController < BaseController
  include EmbeddedObjects
  include Workflow::HasSteps

  before_action :initialize_edition

  def new
    @schema = get_schema(@edition.document.block_type)

    if params[:object_type]
      @subschema = get_subschema(@schema, params[:object_type])
      @back_link = embedded_objects_path

      render :new
    else
      @group = params[:group]
      @subschemas = @schema.subschemas_for_group(@group)
      @back_link = workflow_path(
        @edition,
        step: "#{Workflow::Step::GROUP_PREFIX}#{@group}",
      )
      @redirect_path = new_embedded_objects_options_redirect_edition_path(@edition)
      @context = @edition.title

      if @subschemas.blank?
        render "errors/not_found", status: :not_found
      else
        render "shared/embedded_objects/select_subschema"
      end
    end
  end

  def create
    @schema, @subschema = get_schema_and_subschema(@edition.document.block_type, params[:object_type])
    @object = object_params(@subschema).dig(:details, @subschema.block_type)
    @edition.add_object_to_details(@subschema.block_type, @object)
    @back_link = embedded_objects_path

    if params[:add_another]
      render :new
    else
      @edition.save!

      object_or_group = @subschema.group ? @subschema.group.humanize.singularize : @subschema.name.singularize

      if @subschema.relationship_type.one_to_many?
        flash[:success] = I18n.t(
          "edition.create.embedded_objects.added_confirmation",
          object_name: @subschema.name.singularize,
          object_or_group: object_or_group.downcase,
          schema_name: @schema.name.singularize.downcase,
        )
        redirect_to embedded_objects_path
      else
        redirect_to workflow_path(
          id: @edition.id,
          step: next_step&.name,
        )
      end
    end
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_content
  end

  def edit
    @schema, @subschema = get_schema_and_subschema(@edition.document.block_type, params[:object_type])
    @redirect_url = params[:redirect_url]
    @object_title = params[:object_title]
    @object = @edition.details.dig(params[:object_type], params[:object_title])

    render "errors/not_found", status: :not_found unless @object
  end

  def update
    @schema, @subschema = get_schema_and_subschema(@edition.document.block_type, params[:object_type])
    @object = object_params(@subschema).dig(:details, @subschema.block_type)
    @redirect_url = params[:redirect_url]
    @object_title = params[:object_title]

    @edition.update_object_with_details(params[:object_type], params[:object_title], @object)

    if params[:add_another]
      render :edit
    else
      @edition.save!

      object_or_group = @subschema.group ? @subschema.group.humanize.singularize : @subschema.name.singularize
      flash[:success] = I18n.t(
        "edition.create.embedded_objects.edited_confirmation",
        object_name: @subschema.name.singularize,
        object_or_group: object_or_group.downcase,
        schema_name: @schema.name.singularize.downcase,
      )

      redirect_to params[:redirect_url], allow_other_host: false
    end
  rescue ActiveRecord::RecordInvalid
    render :edit
  end

  def new_embedded_objects_options_redirect
    group = params.require(:group)
    if params[:object_type].present?
      flash[:back_link] = new_embedded_objects_options_redirect_edition_path(@edition, group:)
      redirect_to new_embedded_object_edition_path(@edition, object_type: params.require(:object_type))
    else
      redirect_to new_embedded_object_edition_path(@edition, group:),
                  flash: { error: I18n.t("activerecord.errors.models.document.attributes.block_type.#{group}.blank") }
    end
  end

private

  def initialize_edition
    @edition = Edition.find(params[:id])
  end

  def embedded_objects_path
    step = @subschema.group ? "#{Workflow::Step::GROUP_PREFIX}#{@subschema.group}" : "#{Workflow::Step::SUBSCHEMA_PREFIX}#{@subschema.id}"
    workflow_path(@edition, step:)
  end
end
