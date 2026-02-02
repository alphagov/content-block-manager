class SubschemaCollection
  def initialize(subschemas)
    @subschemas = subschemas
  end

  def grouped
    @subschemas
      .select { |subschema| subschema.group.present? }
      .group_by(&:group)
  end

  def ungrouped
    @subschemas.select { |subschema| subschema.group.blank? }
  end
end
