class CombinedEditionDetails
  def initialize(published_details, new_details)
    @content = combine_hashes(published_details, new_details)
  end

  attr_reader :content

private

  def combine_hashes(published, new)
    combined_hash = {}

    all_keys = (published.keys + new.keys).uniq

    all_keys.each do |key|
      pub_val = published[key]
      new_val = new[key]

      if pub_val.is_a?(Hash) || new_val.is_a?(Hash)
        combined_hash[key] = combine_hashes(pub_val || {}, new_val || {})

      elsif pub_val.is_a?(Array) || new_val.is_a?(Array)
        max_array_length = [Array(pub_val).length, Array(new_val).length].max

        combined_hash[key] = (0..max_array_length - 1).map do |index|
          published = Array(pub_val)[index] || {}
          new = Array(new_val)[index] || {}

          if published.is_a?(Hash) && new.is_a?(Hash)
            combine_hashes(published, new)
          else
            {
              "published" => published,
              "new" => new,
            }
          end
        end
      else
        combined_hash[key] = {}
        combined_hash[key]["published"] = pub_val if published.key?(key)
        combined_hash[key]["new"] = new_val if new.key?(key)
      end
    end

    combined_hash
  end
end
