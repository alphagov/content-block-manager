RSpec::Matchers.define :have_error_for do |key|
  match do |model|
    @model = model
    @error = model.errors[key]
    @error.present? && has_expected_message?
  end

  chain :with_error_message_for do |opts, **_args|
    type = opts.delete(:type)
    @expected_message = I18n.t("activerecord.errors.models.edition.#{type}", **opts)
  end

private

  def has_expected_message?
    return true if @expected_message.nil?

    @error.include?(@expected_message)
  end
end
