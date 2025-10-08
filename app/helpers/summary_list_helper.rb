module SummaryListHelper
  include TranslationHelper
  def first_class_items(input)
    result = {}

    input.each do |key, value|
      case value
      when String
        result[key] = value
      when Array
        value.each_with_index do |item, index|
          result["#{key}/#{index}"] = item if item.is_a?(String)
        end
      end
    end

    result
  end

  def nested_items(input)
    input.select do |_key, value|
      value.is_a?(Hash) || value.is_a?(Array) && value.all? { |item| item.is_a?(Hash) }
    end
  end

  def key_to_label(key, schema_name, object_type = nil)
    relative_key = parse_key(key)
    humanized_label(schema_name:, relative_key:, root_object: object_type)
  end

  def key_to_title(key, schema_name, object_type = nil)
    relative_key = parse_key(key)
    humanized_title(schema_name:, relative_key:, root_object: object_type)
  end

private

  def parse_key(key)
    subject, count = key.split("/")
    count ? "#{subject.singularize} #{count.to_i + 1}" : subject
  end
end
