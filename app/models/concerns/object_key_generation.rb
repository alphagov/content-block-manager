module ObjectKeyGeneration
  extend ActiveSupport::Concern

private

  # Take an object type and a title and return a key that can be used to
  # store the object in the details hash.
  #
  # If the title is already present in the details hash, a counter will be
  # appended to the key.
  def key_for_object(object_type, title)
    base_key = convert_to_valid_key(title, object_type)
    key = base_key
    counter = 1

    while details.dig(object_type, key).present?
      key = "#{base_key}-#{counter}"
      counter += 1
    end

    key
  end

  def convert_to_valid_key(str, fallback)
    sanitized = sanitize_string(str)
    return sanitized if valid_sanitized_string?(sanitized)

    sanitize_string(fallback)
  end

  def sanitize_string(str)
    str&.parameterize&.dasherize&.singularize
  end

  # NOTE: This regex is lifted from the publishing api schemas and possibly should be shared somehow.
  def valid_sanitized_string?(sanitized)
    sanitized.present? && sanitized.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
  end
end
