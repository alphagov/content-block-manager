class Shared::EmbeddedObjectsComponent < ViewComponent::Base
  def initialize(edition:, subschema:, redirect_url:)
    @edition = edition
    @subschema = subschema
    @redirect_url = redirect_url
  end

private

  attr_reader :edition, :subschema, :redirect_url

  def subschema_name
    subschema.name.humanize.singularize.downcase
  end

  def subschema_keys
    @subschema_keys ||= edition.details[subschema.block_type]&.keys || []
  end

  def show_add_button?
    edition.document.is_new_block?
  end

  def show_title?
    if !edition.document.is_new_block?
      has_embedded_objects?
    else
      true
    end
  end

  def add_button_text
    if has_embedded_objects?
      I18n.t("buttons.add_another", item: subschema_name)
    else
      I18n.t("buttons.add", item: helpers.add_indefinite_article(subschema_name))
    end
  end

  def has_embedded_objects?
    subschema_keys.any?
  end
end
