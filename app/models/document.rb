class Document < ApplicationRecord
  include Scopes::SearchableByKeyword
  include Scopes::SearchableByLeadOrganisation
  include Scopes::SearchableByUpdatedDate

  include SoftDeletable
  include HideableFromSearchIndex

  extend FriendlyId
  friendly_id :sluggable_string, use: :slugged, slug_column: :content_id_alias, routes: :default

  has_many :editions,
           -> { order(created_at: :asc, id: :asc) },
           inverse_of: :document

  enum :block_type, Schema.valid_schemas.index_with(&:to_s)
  attr_readonly :block_type

  validates :block_type, :sluggable_string, presence: true

  has_many :versions, through: :editions, source: :versions

  has_one :latest_published_edition,
          -> { published.most_recent_first }, class_name: "Edition"

  has_one :most_recent_edition,
          -> { most_recent_first }, class_name: "Edition"

  scope :live, -> { joins(:editions).merge(Edition.published.most_recent_first) }

  def built_embed_code
    "#{embed_code_prefix}}}"
  end

  def embed_code_for_field(field_path)
    "#{embed_code_prefix}/#{field_path}}}"
  end

  def title
    @title ||= most_recent_edition&.title
  end

  def is_new_block?
    editions.count == 1
  end

  def has_published_edition?
    editions.published.any?
  end

  def latest_draft
    editions.where(state: :draft).order(created_at: :asc).last
  end

  def schema
    @schema ||= Schema.find_by_block_type(block_type)
  end

private

  def embed_code_prefix
    "{{embed:content_block_#{block_type}:#{content_id_alias}"
  end
end
