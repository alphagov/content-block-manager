class Edition::StateTransitionErrorReport
  def initialize(error:, edition:)
    @error = error
    @edition = edition
  end

  def call
    GovukError.notify(
      @error,
      extra: { edition_id: @edition.id, document_id: @edition.document.id },
      level: :warn,
    )
  end
end
