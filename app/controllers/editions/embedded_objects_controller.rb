class Editions::EmbeddedObjectsController < BaseController
  include EmbeddedObjects

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
        render "admin/errors/not_found", status: :not_found
      else
        render "shared/embedded_objects/select_subschema"
      end
    end
  end

  def create
    @schema, @subschema = get_schema_and_subschema(@edition.document.block_type, params[:object_type])
    @object = object_params(@subschema).dig(:details, @subschema.block_type)
    @edition.add_object_to_details(@subschema.block_type, @object)
    @edition.save!

    object_or_group = @subschema.group ? @subschema.group.humanize.singularize : @subschema.name.singularize

    flash[:notice] = I18n.t(
      "edition.create.embedded_objects.added_confirmation",
      object_name: @subschema.name.singularize,
      object_or_group: object_or_group.downcase,
      schema_name: @schema.name.singularize.downcase,
    )
    redirect_to embedded_objects_path
  rescue ActiveRecord::RecordInvalid
    @back_link = embedded_objects_path
    render :new
  end

  def edit
    @schema, @subschema = get_schema_and_subschema(@edition.document.block_type, params[:object_type])
    @redirect_url = params[:redirect_url]
    @object_title = params[:object_title]
    @object = @edition.details.dig(params[:object_type], params[:object_title])

    render "admin/errors/not_found", status: :not_found unless @object
  end

  def update
    @schema, @subschema = get_schema_and_subschema(@edition.document.block_type, params[:object_type])
    @object = object_params(@subschema).dig(:details, @subschema.block_type)
    @edition.update_object_with_details(params[:object_type], params[:object_title], @object)
    @edition.save!

    if params[:redirect_url].present?
      object_or_group = @subschema.group ? @subschema.group.humanize.singularize : @subschema.name.singularize

      flash[:notice] = I18n.t(
        "edition.create.embedded_objects.edited_confirmation",
        object_name: @subschema.name.singularize,
        object_or_group: object_or_group.downcase,
        schema_name: @schema.name.singularize.downcase,
      )
      redirect_to params[:redirect_url], allow_other_host: false
    else
      redirect_to review_embedded_object_edition_path(
        @edition,
        object_type: @subschema.block_type,
        object_title: params[:object_title],
      )
    end
  rescue ActiveRecord::RecordInvalid
    @redirect_url = params[:redirect_url]
    @object_title = params[:object_title]
    render :edit
  end

  def review
    @schema, @subschema = get_schema_and_subschema(@edition.document.block_type, params[:object_type])
    @object_title = params[:object_title]
  end

  def publish
    @schema, @subschema = get_schema_and_subschema(@edition.document.block_type, params[:object_type])
    if params[:is_confirmed].blank?
      flash[:error] = I18n.t("edition.review_page.errors.confirm")
      redirect_path = review_embedded_object_edition_path(
        @edition,
        object_type: @subschema.block_type,
        object_title: params[:object_title],
      )
    else
      @edition.updated_embedded_object_type = @subschema.block_type
      @edition.updated_embedded_object_title = params[:object_title]
      PublishEditionService.new.call(@edition)
      flash[:notice] = "#{@subschema.name.singularize} created"
      redirect_path = document_path(@edition.document)
    end

    redirect_to redirect_path
  end

  def new_embedded_objects_options_redirect
    if params[:object_type].present?
      flash[:back_link] = new_embedded_objects_options_redirect_edition_path(
        @edition,
        group: params.require(:group),
      )
      redirect_to new_embedded_object_edition_path(@edition, object_type: params.require(:object_type))
    else
      redirect_to new_embedded_object_edition_path(@edition, group: params.require(:group)), flash: { error: I18n.t("activerecord.errors.models/document.attributes.block_type.blank") }
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
