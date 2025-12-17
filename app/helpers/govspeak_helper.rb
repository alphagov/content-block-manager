module GovspeakHelper
  include ContentBlockTools::Govspeak

  def render_govspeak_if_enabled_for_field(field_name:, value:)
    return value unless field_enabled_for_govspeak?(field_name)

    render_govspeak(value)
  end

  def field_enabled_for_govspeak?(field_name)
    field = subschema.field(field_name)
    field.govspeak_enabled?
  end
end
