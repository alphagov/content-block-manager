module Block
  class Edition < ApplicationRecord
    include ::Edition::HasLeadOrganisation

    belongs_to :document, class_name: "Block::Document", foreign_key: :block_document_id

    validates :title, presence: true

    # Abstract method to be implemented by subclasses
    # Returns a hash representation of the edition's details
    def to_details
      raise NotImplementedError, "Subclasses must implement #to_details method"
    end
  end
end
