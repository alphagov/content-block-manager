module DiffHelper
  def render_diff(before, after)
    Nokodiff.diff(ensure_valid(before), ensure_valid(after))
  end

  def arg_uses_valid_html?(arg)
    Nokodiff::HTMLFragmentValidator.validate_html!(arg)
  rescue ArgumentError
    false
  end

  def ensure_valid(arg)
    arg_uses_valid_html?(arg) ? arg : make_valid_html(arg)
  end

private

  def make_valid_html(arg)
    content_tag(:span, arg)
  end
end
