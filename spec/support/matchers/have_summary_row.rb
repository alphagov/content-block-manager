RSpec::Matchers.define :have_summary_row do
  match do |page|
    @page = page
    @row = find_matching_row
    @row.present? && key_matches? && value_matches? && css_matches? && css_does_not_match?
  end

  chain :with_key do |key_text|
    @expected_key = key_text
  end

  chain :with_value do |value_text|
    @expected_value = value_text
  end

  chain :with_css do |css, args = {}|
    @expected_css = css
    @expected_css_args = args
  end

  chain :not_with_css do |css, args = {}|
    @negated_css = css
    @negated_css_args = args
  end

  failure_message do
    if @row.nil?
      "expected to find a summary row with key #{@expected_key.inspect}, but no matching row was found"
    elsif !key_matches?
      "expected summary row to have key #{@expected_key.inspect}, but found #{actual_key_text.inspect}"
    elsif !value_matches?
      "expected summary row to have value #{@expected_value.inspect}, but found #{actual_value_text.inspect}"
    elsif !css_matches?
      "expected summary row to have css selector #{@expected_css.inspect}, but found #{@row.native}"
    elsif !css_does_not_match?
      "expected summary row to NOT have css selector #{@expected_css.inspect}, but found #{@row.native}"
    end
  end

  failure_message_when_negated do
    "expected not to find a summary row with the specified attributes, but one was found"
  end

  description do
    desc = "have a summary row"
    desc += " with key #{@expected_key.inspect}" if @expected_key
    desc += " with value #{@expected_value.inspect}" if @expected_value
    desc += " with css #{@expected_css.inspect}" if @expected_css
    desc
  end

private

  def find_matching_row
    rows = @page.all(".govuk-summary-list__row")

    return rows.first if rows.one? && @expected_key.nil?

    rows.find do |row|
      next false if @expected_key.nil?

      key_element = row.first(".govuk-summary-list__key")
      next false unless key_element

      text_matches?(key_element.text, @expected_key)
    end
  end

  def key_matches?
    return true if @expected_key.nil?

    key_element = @row.first(".govuk-summary-list__key")
    return false unless key_element

    text_matches?(key_element.text, @expected_key)
  end

  def value_matches?
    return true if @expected_value.nil?

    value_element = @row.first(".govuk-summary-list__value")
    return false unless value_element

    text_matches?(value_element.text, @expected_value)
  end

  def text_matches?(actual, expected)
    case expected
    when Regexp
      actual.match?(expected)
    when String
      actual.strip == expected.strip
    else
      actual == expected.to_s
    end
  end

  def css_matches?
    return true if @expected_css.nil?

    result = @row.all(@expected_css, **@expected_css_args)

    !result.empty?
  end

  def css_does_not_match?
    return true if @negated_css.nil?

    result = @row.all(@negated_css, **@negated_css_args)

    result.empty?
  end

  def actual_key_text
    @row&.first(".govuk-summary-list__key")&.text
  end

  def actual_value_text
    @row&.first(".govuk-summary-list__value")&.text
  end
end
