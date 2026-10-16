module DocumentsHelpers
  def should_see_title_of_document_contains(title)
    expect(page).to have_css(".govuk-heading-xl", text: title)
  end

  def should_see_status_of_document(status)
    expect(page).to have_css(".govuk-tag", text: status)
  end

  def should_see_block_type_of_document(type)
    expect(page).to have_css(".govuk-caption-xl", text: type)
  end

  def should_see_document_buttons(buttons)
    buttons.each do |button|
      expect(page).to have_css(".govuk-button", text: button)
    end
  end

  def should_see_document_links(links)
    links.each do |link|
      expect(page).to have_css(".govuk-link", text: link)
    end
  end
end

World(DocumentsHelpers)
