module Block
  class Edition < ApplicationRecord
    include ::Edition::HasLeadOrganisation
    include ::Edition::HasAuthors

    belongs_to :document, class_name: "Block::Document", foreign_key: :block_document_id, inverse_of: :editions

    validates :title, presence: true
    validate :title_contains_alphanumeric_chars

    before_validation :set_document_sluggable_string, on: :create

    scope :most_recent_first, -> { order(updated_at: :desc) }

    # Abstract method to be implemented by subclasses
    # Returns a hash representation of the edition's details
    def to_details
      raise NotImplementedError, "Subclasses must implement #to_details method"
    end

    def state
      "draft"
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
