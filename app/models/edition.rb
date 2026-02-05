class Edition < ApplicationRecord
  validates :title, presence: true
  validates :change_note, presence: true, if: :major_change?, on: :change_note
  validates :major_change, inclusion: [true, false], on: :change_note

  include Cloneable
  include Documentable
  include HasAuditTrail
  include HasAuthBypassToken
  include HasAuthors
  include ValidatesDetails
  include HasLeadOrganisation
  include Workflow

  has_one :review_outcome, dependent: :destroy
  has_one :fact_check_outcome, dependent: :destroy
  has_many :domain_events

  scope :current_versions, lambda {
    published
  }

  scope :published, -> { where(state: "published") }

  scope :most_recent_for_document, lambda {
    where(updated_at: Edition.active.select("MAX(updated_at)").group(:document_id))
  }

  scope :most_recent_first, lambda {
    order(updated_at: :desc)
  }

  scope :active, -> { where.not(state: Edition.inactive_states) }

  def self.most_recent
    most_recent_first.first
  end

  def first_edition?
    document.editions.published.count.zero? ||
      published? && document.editions.published.count == 1
  end

  def show_embed_codes?
    published? || scheduled?
  end

  def render(embed_code = document.embed_code)
    ContentBlockTools::ContentBlock.new(
      document_type: "content_block_#{block_type}",
      content_id: document.content_id,
      title:,
      details:,
      embed_code:,
    ).render
  end

  def add_object_to_details(object_type, body)
    key = ObjectKey.new(details, object_type, body["title"]).to_s

    details[object_type] ||= {}
    details[object_type][key] = remove_destroyed body.to_h
  end

  def update_object_with_details(object_type, object_title, body)
    details[object_type][object_title] = remove_destroyed body.to_h
  end

  def has_entries_for_subschema_id?(subschema_id)
    details[subschema_id].present?
  end

  def has_multiple_subschema_entries?
    schema = document.schema
    subschemas = schema.subschemas

    total_entries = subschemas.inject(0) do |counter, subschema|
      counter + (details[subschema.id].try(:count) || 0)
    end

    total_entries > 1
  end

  def default_order
    document.schema.subschemas.sort_by(&:group_order).map { |subschema|
      item_keys = details[subschema.block_type]&.keys || []
      item_keys.map do |item_key|
        "#{subschema.block_type}.#{item_key}"
      end
    }.flatten
  end

  def is_scheduling?
    scheduled_publication.present?
  end

  def is_deletable?
    can_transition?(:delete)
  end

private

  def remove_destroyed(item)
    item.transform_values { |value|
      case value
      when Hash
        remove_destroyed(value)
      when Array
        value.select { |i| !i.is_a?(Hash) || i.delete("_destroy") != "1" }
      else
        value
      end
    }.to_h
  end
end
