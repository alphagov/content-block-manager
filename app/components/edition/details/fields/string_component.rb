class Edition::Details::Fields::StringComponent < ViewComponent::Base
  def initialize(context)
    @context = context
  end

private

  attr_reader :context

  delegate :label, :name, :id, :value, :error_items, :hint_text, :input_prefix, to: :context
end
