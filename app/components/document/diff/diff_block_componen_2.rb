class Document::Diff::DiffBlockComponent < ViewComponent::Base
  def initialize(current_edition:, published_edition:)
    @current_edition = current_edition
    @published_edition = published_edition
    @document = current_edition.document
  end

  # def diffed_edition
  #   edition_copy = @current_edition.dup
  #   edition_copy.details = compute_diff(@published_edition.details, @current_edition.details)
  #   edition_copy
  # end

private

  def compute_diff(old_edition, new_edition)
    puts ("**************")
    puts (old_edition)
    puts ("**************")
    puts (new_edition)
    case old_edition
    when Hash
      old_edition.each_with_object({}) do |(key, old_value), result|
        new_value = new_edition[key]
        result[key] = compute_diff(old_value, new_value)
      end

    when Array
      old_edition.fill({}, old_edition.length..new_edition.length)
      old_edition.map.with_index do |old_value, index|
        compute_diff(old_value, new_edition[index])
      end
    else
      if old_edition == new_edition
        old_edition.to_s
      else
        helpers.diff_html(old_edition.to_s, new_edition.to_s)
      end
    end
  end

  def block_content
    diffed_edition = @current_edition.dup

    diffed_edition.details = compute_diff(@published_edition.details, @current_edition.details)

    content_tag(:div, class: "govspeak compare-editions") do
      puts (diffed_edition)
      diffed_edition.render
    end
  end
end
