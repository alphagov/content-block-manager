class Shared::DocumentStatusTagComponent < ViewComponent::Base
  class UnexpectedStatusError < RuntimeError; end

  COLOURS = {
    draft: "yellow",
    awaiting_review: "turquoise",
    scheduled: "light-blue",
    published: "green",
    superseded: "orange",
    deleted: "red",
  }.freeze

  def initialize(edition:)
    @edition = edition
  end

  def status
    I18n.t("edition.states.label.#{@edition.state}")
  end

  def colour
    COLOURS.fetch(@edition.state.to_sym) do
      raise UnexpectedStatusError, "No colour mapped for state '#{@edition.state}'"
    end
  end
end
