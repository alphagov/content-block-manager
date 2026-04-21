module Edition::HasAuthors
  extend ActiveSupport::Concern
  include Edition::HasCreator

  included do
    has_many :edition_authors, dependent: :destroy, class_name: "EditionAuthor"
  end
end
