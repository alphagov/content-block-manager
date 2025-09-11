class DeleteEditionService
  def call(edition)
    if edition.draft?
      document = edition.document
      document.with_lock do
        edition.destroy!
        if document_has_no_more_editions?(document)
          document.destroy!
        end
      end
    else
      raise ArgumentError, "Could not delete Content Block Edition #{edition.id} because it is not in draft"
    end
  end

private

  def document_has_no_more_editions?(document)
    document.editions.count.zero?
  end
end
