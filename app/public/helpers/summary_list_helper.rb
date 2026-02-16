module SummaryListHelper
  include TranslationHelper
  def first_class_items(input)
    result = {}

    input.each do |field, value|
      case value
      when String
        result[field] = value
      when Array
        result[field] = value.select { |item| item.is_a?(String) }.presence
      when Hash
        result[field] = value if value["published"] || value["new"]
      end
    end

    result.compact
  end

  def nested_items(input)
    input.select do |_key, value|
      next if value.is_a?(Hash) && (value["published"] || value["new"])

      value.is_a?(Hash) || value.is_a?(Array) && value.all? { |item| item.is_a?(Hash) }
    end
  end
end
