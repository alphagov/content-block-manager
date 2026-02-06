class PairedContent
  def initialize(content_a, content_b)
    @content_a = content_a || []
    @content_b = content_b || []
  end

  attr_reader :content_a, :content_b

  def to_ary
    content_pairs = []
    (0..[content_a.size, content_b.size].max - 1).each do |i|
      content_pairs << PairedContent.new(content_a[i], content_b[i])
    end
    content_pairs
  end
end
