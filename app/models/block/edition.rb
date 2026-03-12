module Block
  class Edition < ApplicationRecord
    self.table_name = "block_editions"

    belongs_to :document, class_name: "Block::Document", foreign_key: :block_document_id, inverse_of: :editions

    validates :title, presence: true

    # Abstract method to be implemented by subclasses
    # Returns a hash representation of the edition's details
    def details
      raise NotImplementedError, "Subclasses must implement #details method"
    end
  end
end
