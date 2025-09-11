module Workflow::ShowMethods
  extend ActiveSupport::Concern

  def edit_draft
    @edition = Edition.find(params[:id])
    @schema = Schema.find_by_block_type(@edition.document.block_type)
    @form = EditionForm::Edit.new(edition: @edition, schema: @schema)

    @title = @edition.document.is_new_block? ? "Create #{@form.schema.name}" : "Change #{@form.schema.name}"
    @back_path = @edition.document.is_new_block? ? new_document_path : @form.back_path

    render :edit_draft
  end

  # This handles the optional embedded objects and groups in the flow, delegating to `embedded_objects`
  # or `embedded_group_objects` as appropriate
  def method_missing(method_name, *arguments, &block)
    if method_name.to_s =~ /#{Workflow::Step::SUBSCHEMA_PREFIX}(.*)/
      embedded_objects(::Regexp.last_match(1))
    elsif method_name.to_s =~ /#{Workflow::Step::GROUP_PREFIX}(.*)/
      group_objects(::Regexp.last_match(1))
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?(Workflow::Step::SUBSCHEMA_PREFIX) || super
  end

  def review_links
    @document = @edition.document
    @order = params[:order]
    @page = params[:page]

    @host_content_items = HostContentItem.for_document(
      @document,
      order: @order,
      page: @page,
    )

    if @host_content_items.empty?
      referred_from_next_step = request.referer && URI.parse(request.referer).path&.end_with?(next_step.name.to_s)

      redirect_to workflow_path(
        id: @edition.id,
        step: referred_from_next_step ? previous_step.name : next_step.name,
      )
    else
      render :review_links
    end
  end

  def schedule_publishing
    @document = @edition.document

    render :schedule_publishing
  end

  def internal_note
    @document = @edition.document

    render :internal_note
  end

  def change_note
    @document = @edition.document

    render :change_note
  end

  def review
    @edition = Edition.find(params[:id])

    render :review
  end

  def confirmation
    @edition = Edition.find(params[:id])

    @confirmation_copy = ConfirmationCopyPresenter.new(@edition)

    render :confirmation
  end

  def back_path
    workflow_path(
      @edition,
      step: previous_step.name,
    )
  end
  included do
    helper_method :back_path
  end

private

  def embedded_objects(subschema_name)
    @subschema = @schema.subschema(subschema_name)
    @step_name = current_step.name
    @action = @edition.document.is_new_block? ? "Add" : "Edit"
    @add_button_text = has_embedded_objects ? "Add another #{subschema_name.humanize.singularize.downcase}" : "Add #{helpers.add_indefinite_article @subschema.name.humanize.singularize.downcase}"

    if @subschema
      render :embedded_objects
    else
      raise ActionController::RoutingError, "Subschema #{subschema_name} does not exist"
    end
  end

  def group_objects(group_name)
    @group_name = group_name
    @subschemas = @schema.subschemas_for_group(group_name)
    @step_name = current_step.name
    @action = @edition.document.is_new_block? ? "Add" : "Edit"

    if @subschemas.any?
      if @subschemas.none? { |subschema| has_embedded_objects(subschema) }
        @group = group_name
        @back_link = back_path
        @redirect_path = new_embedded_objects_options_redirect_edition_path(@edition)
        @context = @title

        render "shared/embedded_objects/select_subschema"
      else
        render :group_objects
      end
    else
      raise ActionController::RoutingError, "Subschema group #{group_name} does not exist"
    end
  end

  def has_embedded_objects(subschema = @subschema)
    @edition.details[subschema.block_type].present?
  end
end
