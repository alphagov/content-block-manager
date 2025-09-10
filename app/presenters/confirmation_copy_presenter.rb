class ConfirmationCopyPresenter
  def initialize(edition)
    @edition = edition
  end

  def for_panel
    I18n.t("edition.confirmation_page.#{state}.banner", block_type:, date:)
  end

  def for_paragraph
    I18n.t("edition.confirmation_page.#{state}.detail")
  end

  def state
    if edition.scheduled?
      :scheduled
    elsif edition.document.editions.count > 1
      :updated
    else
      :created
    end
  end

private

  attr_reader :edition

  def date
    I18n.l(edition.scheduled_publication, format: :long_ordinal) if edition.scheduled_publication
  end

  def block_type
    edition.block_type.humanize
  end
end
