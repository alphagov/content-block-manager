module Block
  class Edition < ApplicationRecord
    self.table_name = "block_editions"
    self.abstract_class = true

    belongs_to :document, class_name: "Block::Document", foreign_key: :block_document_id

    validates :title, presence: true

    # Abstract method to be implemented by subclasses
    # Returns a hash representation of the edition's details
    def details
      raise NotImplementedError, "Subclasses must implement #details method"
    end
  end
end
