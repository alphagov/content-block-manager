class Schema
  SCHEMA_PREFIX = "content_block".freeze

  VALID_SCHEMAS = {
    alpha: %w[tax time_period],
    live: %w[contact pension],
  }.freeze

  CONFIG_PATH = Rails.root.join("config/content_block_manager.yml").to_s

  class << self
    def valid_schemas
      show_all_content_block_types? ? VALID_SCHEMAS.values.flatten : VALID_SCHEMAS[:live]
    end

    # Load schemas from the Publishing API (`remote_schemas`) and the app itself (`local_schemas`). Eventually, we
    # will move all of our schemas to the app
    def all
      all_schemas = remote_schemas + local_schemas
      all_schemas.select { |schema| is_valid_schema?(schema.id) }
    end

    def live
      all.select(&:live?)
    end

    def find_by_block_type(block_type)
      all.find { |schema| schema.block_type == block_type } || raise(ArgumentError, "Cannot find schema for #{block_type}")
    end

    def is_valid_schema?(key)
      key.end_with?(*valid_schemas)
    end

    def schema_settings
      @schema_settings ||= YAML.load_file(CONFIG_PATH)
    end

  private

    def show_all_content_block_types?
      Flipflop.show_all_content_block_types? || Current.user&.has_permission?(User::Permissions::SHOW_ALL_CONTENT_BLOCK_TYPES)
    end

    def remote_schemas
      @remote_schemas ||= Public::Services.publishing_api.get_schemas.select { |key, _v|
        key.start_with?(SCHEMA_PREFIX)
      }.map { |id, full_schema|
        full_schema.dig("definitions", "details")&.yield_self { |schema| new(id, schema) }
      }.compact
    end

    def local_schemas
      @local_schemas ||= Dir.glob(Rails.root.join("app/models/schema/definitions/*.json")).map do |path|
        id = "#{SCHEMA_PREFIX}_#{File.basename(path, '.json')}"
        body = JSON.parse(File.open(path).read)
        new(id, body)
      end
    end
  end

  attr_reader :id, :body

  def initialize(id, body)
    @id = id
    @body = body
  end

  def live?
    block_type.in?(VALID_SCHEMAS[:live])
  end

  def name
    I18n.t("schema.title.#{block_type}", default: block_type.humanize)
  end

  def parameter
    block_type.dasherize
  end

  def fields
    field_names.map { |field_name| Field.new(field_name, self) }
  end

  def field(name)
    fields.find(proc { raise "Field '#{name}' not found" }) { |f| f.name == name }
  end

  def subschema(name)
    subschemas.find { |s| s.id == name }
  end

  def subschemas
    @subschemas ||= embedded_objects.map { |object| EmbeddedSchema.new(*object, self) }
  end

  def subschemas_for_group(group)
    subschemas.select { |s| s.group == group }.sort_by(&:group_order)
  end

  def permitted_params
    fields.map(&:permitted_params)
  end

  def block_type
    @block_type ||= id.delete_prefix("#{SCHEMA_PREFIX}_")
  end

  def block_display_fields
    config["block_display_fields"] || []
  end

  def embeddable_as_block?
    config["embeddable_as_block"].present?
  end

  def config
    @config ||= self.class.schema_settings.dig("schemas", @id) || {}
  end

  def field_ordering_rule(field)
    if field_order
      # If a field order is found in the config, order by the index. If a field is not found, put it to the end
      field_order.index(field) || 99
    else
      # By default, order with title first
      field == "title" ? 0 : 1
    end
  end

  def required_fields
    @body["required"] || []
  end

  def is_array?
    !!@is_array
  end

  def html_name_part(index = nil)
    name_part = "[#{block_type}]"
    name_part += "[#{index}]" if is_array?
    name_part
  end

  def html_id_part(index = nil)
    id_part = "_#{block_type}"
    id_part += "_#{index}" if is_array? && index.present?
    id_part
  end

  def value_lookup_parts(index = nil)
    lookup_parts = [block_type]
    lookup_parts << index if is_array? && index.present?
    lookup_parts
  end

private

  def field_names
    sort_fields @body["properties"].keys - properties_to_ignore
  end

  def properties_to_ignore
    [*embedded_objects.keys, "order"]
  end

  def sort_fields(fields)
    fields.sort_by { |field| field_ordering_rule(field) }
  end

  def field_order
    @field_order ||= config["field_order"]
  end

  def embedded_objects
    @body["properties"].select { |_k, v| v["type"] == "object" && v["patternProperties"] }
  end
end
