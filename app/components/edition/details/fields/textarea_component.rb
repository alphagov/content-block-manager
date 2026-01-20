class Edition::Details::Fields::TextareaComponent < ViewComponent::Base
  def initialize(context)
    @context = context
  end

private

  attr_reader :context

  delegate :field, :label, :name, :id, :value, :error_items, :hint_text, to: :context

  def govspeak_enabled?
    field.govspeak_enabled?
  end

  def character_limit
    field.config["character_limit"]
  end

  def aria_described_by
    "#{id}-hint"
  end
end
