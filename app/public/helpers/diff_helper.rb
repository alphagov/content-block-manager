module DiffHelper
  delegate :diff, to: Nokodiff
  delegate :validate_html!, to: Nokodiff::HTMLFragmentValidator

  def render_diff(before, after)
    return diff(before, after) if args_use_valid_html?(before, after)

    diff(make_valid_html(before), make_valid_html(after))
  end

  def args_use_valid_html?(before, after)
    validate_html!(before) && validate_html!(after)
  rescue ArgumentError
    false
  end

private

  def make_valid_html(arg)
    content_tag(:span, arg)
  end
end
