class Shared::ContinueOrCancelButtonGroup < ViewComponent::Base
  def initialize(form_id:, edition:, button_text: "Save and continue")
    @button_text = button_text
    @form_id = form_id
    @edition = edition
  end

private

  attr_reader :button_text, :form_id, :edition
end
