module Edition::Documentable
  extend ActiveSupport::Concern

  included do
    belongs_to :document, touch: true
    validates :document, presence: true

    before_validation :ensure_presence_of_document, on: :create
    after_validation :set_content_id_alias_and_embed_code, on: :create

    accepts_nested_attributes_for :document

    delegate :block_type, :content_id, to: :document, allow_nil: true
  end

  def ensure_presence_of_document
    if document.new_record?
      document.content_id = create_random_id if document.content_id.blank?
      document.sluggable_string = title if document.sluggable_string.blank?
    end
  end

  def set_content_id_alias_and_embed_code
    document.content_id_alias = document.friendly_id
    document.embed_code = document.built_embed_code
  end

  def create_random_id
    SecureRandom.uuid
  end
end
