module V2
  class Edition < ApplicationRecord
    include ::Edition::HasLeadOrganisation
    include ::Edition::HasAuthors
    include V2::Edition::Diffable
    include Workflow

    belongs_to :document, class_name: "V2::Document", foreign_key: :v2_document_id, inverse_of: :editions

    validates :title, presence: true
    validate :title_contains_alphanumeric_chars

    before_validation :set_document_sluggable_string, on: :create

    scope :most_recent_first, -> { order(created_at: :desc) }

    scope :published, -> { where(state: "published") }

    # Abstract method to be implemented by subclasses
    # Returns a hash representation of the edition's details
    def to_details
      raise NotImplementedError, "Subclasses must implement #to_details method"
    end

    def render(embed_code = document.embed_code)
      ContentBlockTools::ContentBlock.new(
        document_type: "content_block_#{document.block_type}",
        content_id: document.content_id,
        title:,
        details: to_details,
        embed_code:,
      ).render
    end

    def show_embed_codes?
      published? || scheduled?
    end

  private

    def set_document_sluggable_string
      return unless document.present? && document.new_record?

      document.sluggable_string = title if document.sluggable_string.blank?
    end

    def title_contains_alphanumeric_chars
      if title.present? && title !~ /[a-z0-9]+/i
        errors.add(:title, :alphanumeric)
      end
    end
  end
end
