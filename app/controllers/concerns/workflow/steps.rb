class Workflow::Steps
  include SchemaHelper

  def self.for(edition, schema)
    new(edition, schema).all
  end

  def all
    @all ||= [
      *all_steps[0],
      *group_steps,
      *subschema_steps,
      *all_steps[1..],
    ].compact
  end

private

  def initialize(edition, schema)
    @edition = edition
    @schema = schema
    @subschemas ||= SubschemaCollection.new(@schema.subschemas)
  end

  def is_new_block?
    @edition.document.is_new_block?
  end

  def all_steps
    if is_new_block?
      Workflow::Step::ALL.select { |s| s.included_in_create_journey == true }
    else
      Workflow::Step::ALL
    end
  end

  def skip_subschema?(subschema)
    !is_new_block? && !@edition.has_entries_for_subschema_id?(subschema.id)
  end

  def skip_group?(subschemas)
    subschemas.all? { |subschema| skip_subschema?(subschema) }
  end

  def ungrouped
    @ungrouped ||= @subschemas.ungrouped
  end

  def grouped
    @grouped ||= @subschemas.grouped
  end

  def subschema_steps
    ungrouped.map do |subschema|
      next if skip_subschema?(subschema)

      Workflow::Step.new(
        "#{Workflow::Step::SUBSCHEMA_PREFIX}#{subschema.id}".to_sym,
        "#{Workflow::Step::SUBSCHEMA_PREFIX}#{subschema.id}".to_sym,
        :redirect_to_next_step,
        true,
      )
    end
  end

  def group_steps
    grouped.keys.map do |group|
      next if skip_group?(grouped[group])

      Workflow::Step.new(
        "#{Workflow::Step::GROUP_PREFIX}#{group}".to_sym,
        "#{Workflow::Step::GROUP_PREFIX}#{group}".to_sym,
        :redirect_to_next_step,
        true,
      )
    end
  end
end
