module DiffHelper
  def render_diff(before, after)
    return Nokodiff.diff(before, after) if args_use_valid_html?(before, after)

    Nokodiff.diff(make_valid_html(before), make_valid_html(after))
  end

  def args_use_valid_html?(before, after)
    Nokodiff::HTMLFragmentValidator.validate_html!(before) && Nokodiff::HTMLFragmentValidator.validate_html!(after)
  rescue ArgumentError
    false
  end

private

  def make_valid_html(arg)
    content_tag(:span, arg)
  end
end
