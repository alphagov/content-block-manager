class Edition::StateTransitionErrorReport
  def initialize(error:, edition:)
    @error = error
    @edition = edition
  end

  def call
    record_error_in_exception_handling_service
    log_error
  end

private

  def record_error_in_exception_handling_service
    GovukError.notify(
      @error,
      extra: { edition_id: @edition.id, document_id: @edition.document.id },
      level: :warn,
    )
  end

  def log_error
    Rails.logger.error(@error.message)
  end
end
