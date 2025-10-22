# A form object to reuse the same form partial for creating and editing a content block edition
# - Creating an object requires dynamic attributes from a schema
# # - Editing an object requires attributes from the object itself
class EditionForm
  include Rails.application.routes.url_helpers

  attr_reader :schema

  def self.for(edition:, schema:)
    edition.document&.latest_edition_id ? Update.new(edition:, schema:) : Create.new(edition:, schema:)
  end

  def initialize(edition:, schema:)
    @edition = edition
    @schema = schema
  end

  def edition
    @edition.errors.delete("document.sluggable_string")
    @edition
  end

  def attributes
    @schema.fields.each_with_object({}) do |field, hash|
      hash[field.name] = nil
      hash
    end
  end

  def form_method
    :post
  end

  class Create < EditionForm
    def title
      I18n.t("edition.create.title", block_type: schema.name.downcase)
    end

    def url
      editions_path
    end

    def back_path
      new_document_path
    end
  end

  class Update < EditionForm
    def title
      I18n.t("edition.update.title", block_type: schema.name.downcase)
    end

    def url
      document_editions_path(document_id: @edition.document.id)
    end

    def back_path
      document_path(@edition.document)
    end
  end

  class Edit < EditionForm
    def title
      action = @edition.document.is_new_block? ? "create" : "update"
      I18n.t("edition.#{action}.title", block_type: schema.name.downcase)
    end

    def url
      workflow_path(@edition, step: "edit_draft")
    end

    def back_path
      @edition.document.is_new_block? ? new_document_path : document_path(@edition.document)
    end

    def form_method
      :put
    end
  end
end
