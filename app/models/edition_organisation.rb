class EditionOrganisation < ApplicationRecord
  belongs_to :edition, class_name: "Edition"
  belongs_to :organisation
end
