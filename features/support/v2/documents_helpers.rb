module DocumentsHelpers
  def create_document_with_state(state:, type: "Time period")
    edition_type = "v2_#{type}_edition".parameterize.underscore.to_sym
    @document = FactoryBot.create(edition_type).document # rubocop:disable Rails/SaveBang

    # When workflow implemented, apply state properly. For now, store as variable
    @document_state = state.parameterize.underscore
  end

  def should_see_title_of_document_contains(title)
    expect(page).to have_css(".govuk-heading-xl", text: title)
  end

  def should_see_status_of_document(status)
    expect(page).to have_css(".govuk-tag", text: status)
  end

  def should_see_block_type_of_document(type)
    expect(page).to have_css(".govuk-caption-xl", text: type)
  end

  def should_see_document_button(button, href: nil)
    if href
      expect(page).to have_css("a.govuk-button[href='#{href}']", text: button)
    else
      expect(page).to have_css("a.govuk-button", text: button)
    end
  end

  def should_see_document_link(link, href: nil)
    if href
      expect(page).to have_css("a.govuk-link[href='#{href}']", text: link)
    else
      expect(page).to have_css("a.govuk-link", text: link)
    end
  end
end

World(DocumentsHelpers)
